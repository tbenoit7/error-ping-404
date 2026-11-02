#!/usr/bin/env bash
# Error Ping 404 — génération des niveaux.
# Chaque niveau n'est créé qu'une fois le précédent résolu : impossible de
# tricher avec un simple cd vers la suite.

# Crée un petit script qui délègue à lib/action.sh : creer_action fichier action [executable]
creer_action() {
    local fichier="$1" action="$2" executable="${3:-oui}" entete="${4:-}"
    {
        echo '#!/usr/bin/env bash'
        [ -n "$entete" ] && echo "$entete"
        echo "exec bash \"$JEU_ROOT/lib/action.sh\" $action \"\$@\""
    } > "$fichier"
    if [ "$executable" = "oui" ]; then chmod 755 "$fichier"; else chmod 644 "$fichier"; fi
}

# ---------------------------------------------------------------- Niveau 0
generer_niveau0() {
    local base="$1" d="$1/salle_attente"
    local n h appel i
    n="$(alea 6 15)"
    h="$(etat_get heure)"
    appel="$(etat_get appel)"
    etat_set code0 "$(empreinte "$(( n * h ))$appel")"

    mkdir -p "$d/chaises" "$d/guichet/.tablette" "$d/poubelle"

    cat > "$d/regarder_autour.txt" <<'EOF'
Une salle d'attente d'un blanc aveuglant. Une odeur de produits d'entretien.
Des rangées de chaises en plastique, toutes vides.
L'horloge murale fait tic, tac.
Au-dessus du guichet, l'écran d'appel affiche un numéro.
Personne derrière la vitre. Sur la vitre, quelqu'un a écrit au feutre :
    TOUT EST COMPTÉ ICI.
Au fond, une porte de service, avec un clavier à code.
Une poubelle déborde près de l'entrée.
EOF
    echo "NUMÉRO APPELÉ : $appel" > "$d/ecran_appel.txt"
    echo "Tic. Tac. Les aiguilles tournent, mais reviennent toujours sur $h h." > "$d/horloge.txt"

    for (( i = 1; i <= n; i++ )); do
        printf 'Une chaise vide. Encore tiède.\n' > "$d/chaises/$(printf 'chaise_%02d' "$i")"
    done
    echo "(1/3) ...compte les chaises qui t'attendent..." > "$d/chaises/.morceau_1"

    cat > "$d/guichet/registre.txt" <<'EOF'
REGISTRE DES ENTRÉES
--------------------
~~~~~~~~~~~~  (rayé)
~~~~~~~~~~~~  (rayé)
~~~~~~~~~~~~  (rayé)
~~~~~~~~~~~~  (rayé)
EOF
    echo "(2/3) ...multiplie par l'heure qu'il est toujours..." > "$d/guichet/.morceau_2"
    echo "(3/3) ...et écris juste derrière le numéro qu'on appelle. Présentez-vous à la porte de service." > "$d/poubelle/.morceau_3"
    echo "Des gobelets vides, des tickets froissés. Tous illisibles." > "$d/poubelle/contenu.txt"

    cat > "$d/guichet/.tablette/ecran.txt" <<'EOF'
Une tablette, posée derrière le guichet. L'écran est fissuré.
Le compartiment de la batterie est vide.
EOF
    creer_action "$d/guichet/.tablette/allumer.sh" allumer
    creer_action "$d/porte_service.sh" porte_service
}

# ---------------------------------------------------------------- Niveau 1
generer_niveau1() {
    local base="$1" d="$1/ascenseur"
    local m1 m2 x y i nom
    m1="$(alea 10 99)"
    m2="$(alea 10 99)"
    while [ "$m2" = "$m1" ]; do m2="$(alea 10 99)"; done
    (( m1 > m2 )) && { i="$m1"; m1="$m2"; m2="$i"; }
    etat_set code1 "$(empreinte "$m1$m2")"

    x="$(alea 1 99)"
    while [ "$x" = "$m1" ] || [ "$x" = "$m2" ]; do x="$(alea 1 99)"; done
    y="$(alea 1 99)"
    while [ "$y" = "$m1" ] || [ "$y" = "$m2" ] || [ "$y" = "$x" ]; do y="$(alea 1 99)"; done

    mkdir -p "$d"
    for (( i = 0; i <= 99; i++ )); do
        [ "$i" = "$m1" ] || [ "$i" = "$m2" ] && continue
        if (( i == 0 )); then nom="etage_0"; else nom="$(printf 'etage_-%02d' "$i")"; fi
        mkdir -p "$d/$nom"
        echo "Ici, rien." > "$d/$nom/mur.txt"
        echo "Une porte coupe-feu. Verrouillée." > "$d/$nom/porte.txt"
    done

    # L'étage habité : un mur couvert d'écriture, et la seule porte qui s'ouvre
    local habite; habite="$(printf 'etage_-%02d' "$x")"
    local graffitis=(
        "je suis déjà passé ici" "ne remonte pas" "IIII IIII IIII IIII" "combien de temps ?"
        "la musique ne s'arrête jamais" "j'ai compté les étages. ils changent." "qui a écrit ça ?"
        "ne réponds pas au message" "ils sont tous pareils" "j'entends l'ascenseur bouger seul"
        "IIII IIII II" "je ne dors plus" "le néon grésille toujours au même rythme"
        "il y a un bouton sans numéro" "on m'a appelé" "pourquoi moi"
    )
    local ligne_code; ligne_code="$(alea 40 160)"
    : > "$d/$habite/mur.txt"
    for (( i = 1; i <= 200; i++ )); do
        if (( i == ligne_code )); then
            echo "Le code n'est pas écrit. Il manque, comme les boutons du panneau." >> "$d/$habite/mur.txt"
        else
            echo "${graffitis[RANDOM % ${#graffitis[@]}]}" >> "$d/$habite/mur.txt"
        fi
    done
    echo "Une porte coupe-feu. Celle-ci n'est pas tout à fait fermée." > "$d/$habite/porte.txt"
    creer_action "$d/$habite/porte_coupe_feu.sh" porte_coupe_feu

    # La batterie, oubliée sur un autre étage
    echo "Une batterie de tablette. Elle semble encore un peu chargée." > "$d/$(printf 'etage_-%02d' "$y")/batterie"

    cat > "$d/regarder_autour.txt" <<'EOF'
Une cabine d'ascenseur aux parois en miroir.
Une musique d'attente tourne en boucle, toujours la même mesure.
Le panneau compte de 0 à -99, mais certains boutons ont été arrachés,
laissant des trous noirs.
Chaque fois que les portes s'ouvrent, c'est le même palier :
moquette grise, néon qui grésille, porte coupe-feu.
Tout en bas du panneau, sous le -99, un bouton sans aucun numéro.
Il ne s'allume pas.
(Pour aller à un étage : cd etage_-42)
EOF
    cat > "$d/panneau.txt" <<'EOF'
Boutons de 0 à -99. Certains ont été arrachés.
Tout en bas, un bouton sans numéro.
EOF
    cat > "$d/plaque.txt" <<'EOF'
Une plaque de cuivre, vissée au-dessus des boutons :

    « Un seul étage a été habité.
      Ses murs ont trop parlé. »
EOF
    cat > "$d/indices_mode_facile.txt" <<'EOF'
Lis un indice à la fois. Arrête-toi dès que tu as compris.

INDICE 1
L'étage habité est celui dont le mur est le plus lourd.
ls sait trier par taille.



INDICE 2
Le code se cache dans les boutons qui manquent.
Regarde bien la liste des étages.



INDICE 3
Mets les boutons manquants bout à bout, du plus haut au plus bas.
EOF
    creer_action "$d/bouton_sans_numero.sh" bouton
}

# L'étage secret, créé par le bouton sans numéro
generer_etage_404() {
    local d; d="$(base_monde)/ascenseur/.etage_-404"
    mkdir -p "$d"
    cat > "$d/regarder_autour.txt" <<'EOF'
Les portes s'ouvrent sur un étage qui n'est pas sur le panneau.
Pas de moquette. Pas de néon. Juste une chaise orange au milieu du noir,
et une caméra posée dessus.
À côté, un fichier. Il refuse de s'ouvrir tant qu'on ne lui en donne pas le droit.
EOF
    creer_action "$d/verite.sh" verite non
}

# ---------------------------------------------------------------- Niveau 2
generer_niveau2() {
    local base="$1" d="$1/couloir_hotel" i
    mkdir -p "$d/porte_metro"
    etat_set coffre "$(empreinte 5281)"
    etat_set mdp "$(empreinte miroir)"

    for (( i = 201; i <= 299; i++ )); do
        mkdir -p "$d/chambre_$i"
        echo "Ne pas déranger." > "$d/chambre_$i/porte.txt"
    done
    cat > "$d/regarder_autour.txt" <<'EOF'
Un couloir d'hôtel. Moquette bordeaux à motifs, appliques murales jaunâtres.
Les chambres 201 à 299 sont toutes fermées,
un panneau « Ne pas déranger » sur chaque poignée.
Dans le petit salon du couloir, une vieille télévision allumée.
Elle ne montre que de la neige. Le bruit remplit tout.
Quelque chose brouille le signal.
À côté, un coffre mural.
Au bout du couloir, une porte marquée MÉTRO, avec une serrure.
EOF
    creer_action "$d/television.sh" television
    creer_action "$d/coffre.sh" coffre
    echo "Une serrure. Il faudrait y mettre une clé." > "$d/porte_metro/serrure.txt"
    creer_action "$d/porte_metro/ouvrir.sh" ouvrir
    demarrer_brouillage
}

demarrer_brouillage() {
    arreter_brouillage
    mkdir -p "$ETAT_DIR"
    printf '#!/usr/bin/env bash\n# Brouillage du signal télé\nwhile true; do sleep 1 & wait $!; done\n' > "$ETAT_DIR/brouillage"
    nohup bash "$ETAT_DIR/brouillage" > /dev/null 2>&1 &
    etat_set brouillage_pid "$!"
}

arreter_brouillage() {
    local pid; pid="$(etat_get brouillage_pid)"
    [ -n "$pid" ] && kill "$pid" 2> /dev/null
    return 0
}

brouillage_actif() {
    local pid; pid="$(etat_get brouillage_pid)"
    [ -n "$pid" ] && kill -0 "$pid" 2> /dev/null
}

# ---------------------------------------------------------------- Niveau 3
generer_niveau3() {
    local base="$1" d="$1/quai" bonne_voie bon_billet l i maintenant tmp
    mkdir -p "$d/voies"
    bonne_voie="$(alea 1 3)"
    etat_set voie "$(empreinte "voie_$bonne_voie")"

    cat > "$d/regarder_autour.txt" <<'EOF'
Un quai de métro désert, carrelage blanc fissuré.
Trois rames à l'arrêt, portes ouvertes, aucun conducteur.
Le panneau d'affichage clignote sans rien afficher.
Près d'un guichet fermé, un bac d'objets trouvés, scellé.
À côté, un composteur.
Une annonce sonore commence, puis s'arrête au milieu d'un mot.
EOF
    cat > "$d/panneau.txt" <<'EOF'
—— HORS SERVICE ——

(griffonné au marqueur, en dessous)
Seul le dernier train arrivé repart. Les autres attendent.
EOF
    cat > "$d/composteur.txt" <<'EOF'
Le composteur est en panne. Une étiquette jaunie :
« En cas de panne, donnez vous-même à votre billet le droit de voyager. »
EOF

    # Trois voies, arrivées à des heures différentes : la plus récente est la bonne
    maintenant="$(date +%s)"
    local ages=(7200 5400 3600) ordre=()
    for i in 1 2 3; do [ "$i" != "$bonne_voie" ] && ordre+=("$i"); done
    echo "Une rame, portes ouvertes." > "$d/voies/voie_${ordre[0]}"
    echo "Une rame, portes ouvertes." > "$d/voies/voie_${ordre[1]}"
    echo "Une rame, portes ouvertes. Le moteur tourne encore." > "$d/voies/voie_$bonne_voie"
    touch -d "@$(( maintenant - ages[0] ))" "$d/voies/voie_${ordre[0]}"
    touch -d "@$(( maintenant - ages[1] ))" "$d/voies/voie_${ordre[1]}"
    touch -d "@$(( maintenant - 60 ))" "$d/voies/voie_$bonne_voie"

    # Les objets trouvés : six billets dont un seul valable
    tmp="$(mktemp -d)"
    bon_billet="$(echo A B C D E F | tr ' ' '\n' | sed -n "$(alea 1 6)p")"
    etat_set billet "$(empreinte "$bon_billet")"
    for l in A B C D E F; do
        if [ "$l" = "$bon_billet" ]; then
            creer_action "$tmp/billet_$l.sh" "billet $l" non "# Validité : valable"
        else
            creer_action "$tmp/billet_$l.sh" "billet $l" non "# Validité : périmé"
        fi
    done
    echo "Un parapluie noir. Sec. Il ne pleut jamais ici." > "$tmp/parapluie.txt"
    tar -cf "$d/objets_trouves.tar" -C "$tmp" .
    rm -rf "$tmp"
}

# Génère tous les niveaux jusqu'à N (mode démo)
generer_jusqua() {
    local base="$1" n="$2" i
    for (( i = 0; i <= n; i++ )); do
        "generer_niveau$i" "$base"
    done
    etat_set niveau "$n"
}
