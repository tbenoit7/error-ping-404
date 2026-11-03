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
    local base="$1" d="$1/niveau0_salle_attente"
    local n f h appel i nb_fenetres speciale
    n="$(alea 6 15)"            # nombre de chaises
    f="$(alea 1 9)"             # chiffre caché derrière une fausse fenêtre
    h="$(etat_get heure)"       # heure du lancement
    appel="$(etat_get appel)"   # numéro appelé (17)
    etat_set code0 "$(empreinte "$(( n + f + h ))$appel")"

    mkdir -p "$d/chaises" "$d/fenetres" "$d/guichet/.tablette" "$d/poubelle"

    cat > "$d/regarder_autour.txt" <<'EOF'
Une salle d'attente d'un blanc aveuglant. Une odeur de produits d'entretien.
Des rangées de chaises en plastique, toutes vides.
Aux murs, de grandes fenêtres. Derrière, un ciel parfaitement bleu.
Trop parfait. Ce ne sont pas de vraies fenêtres.
L'horloge murale fait tic, tac.
Au-dessus du guichet, l'écran d'appel affiche un numéro.
Personne derrière la vitre. Sur la vitre, quelqu'un a écrit au feutre :
    TOUT EST COMPTÉ ICI.
Au fond, une porte de service, avec un clavier à code.
Une poubelle déborde près de l'entrée.
Au mur, à côté du guichet, un règlement est affiché.
EOF
    cat > "$d/reglement.txt" <<'EOF'
        RÈGLEMENT INTÉRIEUR DE LA SALLE D'ATTENTE

  Art. 1  Les patients attendent assis, en silence, que leur numéro
          soit appelé. Chaque patient doit connaître son numéro.
  Art. 2  Il est interdit d'entrer (cd) dans le guichet, sous les
          chaises ou dans la poubelle. Ressortez-en aussitôt (cd ..).
  Art. 3  Il est interdit de lire (cat) les papiers qui ne vous
          appartiennent pas.
  Art. 4  Certains objets ne sont pas destinés aux patients : leur nom
          commence par un point et ils n'apparaissent pas à l'affichage
          normal. Il est formellement interdit de les chercher (ls -a).
  Art. 5  Les fenêtres sont décoratives. Ne grattez pas la peinture.
  Art. 6  La porte de service (./porte_service.sh) est réservée au
          personnel. Son code n'est communiqué à personne.

                                                    La Direction
EOF
    echo "NUMÉRO APPELÉ : $appel" > "$d/ecran_appel.txt"
    echo "Tic. Tac. Les aiguilles tournent, mais reviennent toujours sur $h h." > "$d/horloge.txt"

    for (( i = 1; i <= n; i++ )); do
        echo "Une chaise vide. Encore tiède." > "$d/chaises/$(printf 'chaise%02d' "$i")"
    done
    echo "(1/3) ...compte les chaises qui t'attendent..." > "$d/chaises/.morceau1"

    # Les fausses fenêtres : une seule cache un chiffre
    nb_fenetres="$(alea 3 6)"
    speciale="$(alea 1 "$nb_fenetres")"
    for (( i = 1; i <= nb_fenetres; i++ )); do
        if (( i == speciale )); then
            printf 'Un ciel bleu, peint sur la vitre.\nDans un coin, la peinture s'"'"'écaille. Dessous, un chiffre gravé : %s\n' "$f" > "$d/fenetres/fenetre$i"
        else
            echo "Un ciel bleu, peint sur la vitre. Rien d'autre." > "$d/fenetres/fenetre$i"
        fi
    done

    cat > "$d/guichet/registre.txt" <<'EOF'
REGISTRE DES ENTRÉES
--------------------
~~~~~~~~~~~~  (rayé)
~~~~~~~~~~~~  (rayé)
~~~~~~~~~~~~  (rayé)
~~~~~~~~~~~~  (rayé)
EOF
    echo "(2/3) ...ajoute ce que cachent les fausses fenêtres, puis l'heure qu'il est toujours..." > "$d/guichet/.morceau2"
    echo "(3/3) ...et écris juste derrière le numéro qu'on appelle. Présentez-vous à la porte de service." > "$d/poubelle/.morceau3"
    echo "Des gobelets vides, des tickets froissés. Tous illisibles." > "$d/poubelle/contenu.txt"

    cat > "$d/guichet/.tablette/ecran.txt" <<'EOF'
Une tablette, posée derrière le guichet. L'écran est fissuré.
Le compartiment de la batterie est vide.
Au dos, quelqu'un a gravé à la pointe d'un couteau :
    « Je l'ai laissée là où l'on m'a appelé. »
Sur la tranche, un bouton d'allumage (./allumer.sh).
Une fois la batterie dans la tablette, il suffira d'appuyer dessus.
EOF
    creer_action "$d/guichet/.tablette/allumer.sh" allumer
    creer_action "$d/porte_service.sh" porte_service
}

# ---------------------------------------------------------------- Niveau 1
generer_niveau1() {
    local base="$1" d="$1/niveau1_ascenseur"
    local m1 m2 x y i
    # y : l'étage de la batterie = le numéro appelé (17 à la première partie)
    y="$(etat_get appel)"
    # Deux boutons arrachés, entre 10 et 99 : le code, ce sont leurs numéros bout à bout
    m1="$(alea 10 99)"
    while [ "$m1" = "$y" ]; do m1="$(alea 10 99)"; done
    m2="$(alea 10 99)"
    while [ "$m2" = "$m1" ] || [ "$m2" = "$y" ]; do m2="$(alea 10 99)"; done
    (( m1 > m2 )) && { i="$m1"; m1="$m2"; m2="$i"; }
    etat_set code1 "$(empreinte "$m1$m2")"

    # x : l'étage habité (la seule porte qui s'ouvre)
    x="$(alea 1 99)"
    while [ "$x" = "$m1" ] || [ "$x" = "$m2" ] || [ "$x" = "$y" ]; do x="$(alea 1 99)"; done

    # Étages etage00 à etage99 (deux chiffres, pour que ls les range dans l'ordre)
    mkdir -p "$d"
    for (( i = 0; i <= 99; i++ )); do
        [ "$i" = "$m1" ] || [ "$i" = "$m2" ] && continue
        mkdir -p "$d/$(printf 'etage%02d' "$i")"
        echo "Ici, rien." > "$d/$(printf 'etage%02d' "$i")/mur.txt"
        echo "Une porte coupe-feu. Verrouillée." > "$d/$(printf 'etage%02d' "$i")/porte.txt"
    done

    # L'étage habité : un mur couvert d'écriture, et la seule porte qui s'ouvre
    local habite; habite="$(printf 'etage%02d' "$x")"
    local graffitis=(
        "je suis déjà passé ici" "ne redescends pas" "IIII IIII IIII IIII" "combien de temps ?"
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
    cat > "$d/$habite/porte.txt" <<'EOF'
Une porte coupe-feu. Celle-ci n'est pas tout à fait fermée.
À côté de la poignée, un clavier à code (./porte_coupe_feu.sh).

Sur le chambranle, quelqu'un a écrit, tout petit :
  « Ce mur a trop parlé. Deux cents phrases, et une seule parle du code.
    Inutile de tout lire : grep sait retrouver un mot au milieu du bruit.
    grep mot fichier »
EOF
    creer_action "$d/$habite/porte_coupe_feu.sh" porte_coupe_feu

    # La batterie, cachée (fichier caché) à l'étage du numéro appelé
    echo "Une batterie de tablette. Elle semble encore un peu chargée." > "$d/$(printf 'etage%02d' "$y")/.batterie"

    cat > "$d/regarder_autour.txt" <<'EOF'
Une cabine d'ascenseur aux parois en miroir.
Une musique d'attente tourne en boucle, toujours la même mesure.
Le panneau compte de 0 à 99, mais deux boutons ont été arrachés,
laissant des trous noirs.
Chaque fois que les portes s'ouvrent, c'est le même palier :
moquette grise, néon qui grésille, porte coupe-feu.
Tout en haut du panneau, au-dessus du 99, un bouton sans aucun numéro.
Il ne s'allume pas.
Une plaque de cuivre est vissée au-dessus des boutons.
Sur le miroir, des inscriptions ont été gravées. L'écriture te dit vaguement quelque chose.

(Pour aller à un étage : cd etage42)
EOF
    cat > "$d/panneau.txt" <<'EOF'
Boutons de 0 à 99. Deux ont été arrachés.
Tout en haut, un bouton sans numéro.
EOF
    cat > "$d/plaque.txt" <<'EOF'
Une plaque de cuivre, vissée au-dessus des boutons :

    « Un seul étage a été habité.
      Ses murs ont trop parlé. »
EOF
    cat > "$d/graffitis.txt" <<'EOF'
Gravé sur le miroir de la cabine, à hauteur d'yeux :

  « un mur qui parle trop, ça pèse lourd.
    ls -l donne le poids de chaque fichier. ls -S les trie, du plus lourd au plus léger.
    les deux ensemble : ls -lS
    et | head -3 pour ne garder que les trois premiers.
    exemple : ls -lS dossier*/fichier.txt | head -3 »
  « grep trouve un mot au milieu de mille »
  « compte les boutons. ls ne ment pas : ce qui manque n'apparaît pas »
  « je suis sorti à mon numéro. j'y ai caché ce qui manque à la tablette.
    ce qui est caché commence par un point, ici comme en bas »
  « pour emporter quelque chose : mv quoi où »
  « le bouton du haut attend un mot. je ne l'ai jamais trouvé »
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
Mets les deux boutons manquants bout à bout, du plus petit au plus grand.
EOF
    creer_action "$d/bouton_sans_numero.sh" bouton
}

# L'étage secret, créé par le bouton sans numéro
generer_etage_404() {
    local d; d="$(base_monde)/niveau1_ascenseur/.etage404"
    mkdir -p "$d"
    cat > "$d/regarder_autour.txt" <<'EOF'
Les portes s'ouvrent sur un étage qui n'est pas sur le panneau.
Pas de moquette. Pas de néon. Juste une chaise orange au milieu du noir,
et une caméra posée dessus.
À côté, un fichier : verite.sh. Il refuse de s'ouvrir.
Peut-être faut-il lui donner le droit de s'exécuter (chmod +x).
EOF
    creer_action "$d/verite.sh" verite non
}

# ---------------------------------------------------------------- Niveau 2
generer_niveau2() {
    local base="$1" d="$1/niveau2_couloir" i chambre
    mkdir -p "$d/porte_metro"
    chambre="chambre$(alea 201 299)"   # la chambre d'où émet le brouillage
    etat_set coffre "$(empreinte 5281)"
    etat_set mdp "$(empreinte miroir)"

    for (( i = 201; i <= 299; i++ )); do
        mkdir -p "$d/chambre$i"
        echo "Ne pas déranger." > "$d/chambre$i/porte.txt"
    done
    # La chambre de l'émetteur
    echo "La porte est entrouverte. Derrière, un grésillement continu." > "$d/$chambre/porte.txt"
    cat > "$d/$chambre/regarder_autour.txt" <<EOF
Une chambre d'hôtel. Le lit n'a jamais été défait.
Sur la table de nuit, un petit boîtier noir clignote : l'émetteur.
C'est lui qui brouille la télévision du couloir.
Au pied du lit, une valise. Étiquette : « Passager n° $(etat_get appel) ».
EOF
    cat > "$d/$chambre/valise.txt" <<'EOF'
Dans la valise, rien d'autre qu'une feuille pliée en quatre.
L'écriture te dit vaguement quelque chose :

  « La télé ne dit la vérité qu'un instant, juste avant la fin.
    Ce qu'elle dit à ce moment-là allume la tablette du guichet.
    Ne pars pas sans l'avoir écoutée jusqu'au bout. »
EOF
    cat > "$d/regarder_autour.txt" <<'EOF'
Un couloir d'hôtel. Moquette bordeaux à motifs, appliques murales jaunâtres.
Les chambres 201 à 299 sont toutes fermées,
un panneau « Ne pas déranger » sur chaque poignée.
Dans le petit salon du couloir, une vieille télévision allumée.
Elle ne montre que de la neige. Le bruit remplit tout.
Quelque chose brouille le signal.
À côté, un coffre mural.
Au bout du couloir, une porte marquée MÉTRO, avec une serrure.
Sous la télévision, une notice plastifiée est scotchée au meuble.
Une des chambres a sa porte entrouverte. Il en sort un grésillement.
EOF
    cat > "$d/notice_tv.txt" <<'EOF'
        HÔTEL — NOTICE DU TÉLÉVISEUR D'ÉTAGE

  Image brouillée ?
    Un appareil de l'étage émet sans doute en continu.
    La liste des appareils en fonctionnement s'affiche avec : ps aux
    Elle est longue : filtrez-la avec | grep suivi d'un mot-clé.
    La dernière colonne indique aussi d'où l'appareil émet.
    Chaque appareil porte un numéro (PID, 2e colonne).
    kill suivi de ce numéro met l'appareil hors tension.

  Programmes
    Ne zappez pas avant la fin : certaines informations passent très vite.
    Vous pouvez relancer le téléviseur autant de fois que nécessaire.

  Coffre mural
    Le code est communiqué chaque soir aux clients, à la télévision.

  Clés
    Une clé ne s'utilise que dans sa serrure (mv clé serrure).
EOF
    creer_action "$d/television.sh" television
    creer_action "$d/coffre.sh" coffre
    echo "Une serrure. Il faudrait y mettre une clé." > "$d/porte_metro/serrure.txt"
    creer_action "$d/porte_metro/ouvrir.sh" ouvrir
    demarrer_brouillage "$d/$chambre/emetteur"
}

# Lance l'émetteur en arrière-plan : demarrer_brouillage chemin_du_script
demarrer_brouillage() {
    arreter_brouillage
    printf '#!/usr/bin/env bash\n# Émetteur de brouillage\nwhile true; do sleep 1 & wait $!; done\n' > "$1"
    chmod 755 "$1"
    nohup bash "$1" > /dev/null 2>&1 &
    etat_set brouillage_pid "$!"
}

arreter_brouillage() {
    local pid; pid="$(etat_get brouillage_pid)"
    [ -n "$pid" ] && kill "$pid" 2> /dev/null
    return 0
}

# Vrai si le processus de brouillage tourne encore (un processus « zombie » compte comme arrêté)
brouillage_actif() {
    local pid etat_proc
    pid="$(etat_get brouillage_pid)"
    [ -n "$pid" ] || return 1
    etat_proc="$(ps -p "$pid" -o stat= 2> /dev/null)"
    [ -n "$etat_proc" ] && [[ "$etat_proc" != Z* ]]
}

# ---------------------------------------------------------------- Niveau 3
generer_niveau3() {
    local base="$1" d="$1/niveau3_metro" bonne_voie bon_billet l i maintenant tmp
    mkdir -p "$d/voies"
    bonne_voie="$(alea 1 3)"
    etat_set voie "$(empreinte "voie$bonne_voie")"

    cat > "$d/regarder_autour.txt" <<'EOF'
Un quai de métro désert, carrelage blanc fissuré.
Trois rames à l'arrêt sur trois voies, portes ouvertes, aucun conducteur.
Une seule partira. Le panneau d'affichage devrait dire laquelle.
Il te faudra un billet. Les seuls billets ici sont dans le bac
d'objets trouvés (objets_trouves.tar), scellé comme une archive.
Près des voies, un composteur, et une borne d'information encore allumée.
Une annonce sonore commence, puis s'arrête au milieu d'un mot.
EOF
    cat > "$d/borne_info.txt" <<'EOF'
        RÉSEAU SOUTERRAIN — BORNE D'INFORMATION

  1. OBJETS TROUVÉS
     Les objets trouvés sont conservés dans une archive scellée.
     Ouverture : tar -xvf suivi du nom de l'archive.

  2. BILLETS
     Tous les billets sont nominatifs : chacun porte le numéro de son
     passager. Votre numéro vous a été attribué dès votre arrivée.
     Un billet qui n'est pas à votre numéro ne vous mènera nulle part.
     Astuce : grep cherche un texte dans plusieurs fichiers à la fois.

  3. COMPOSTAGE
     Composteur hors service. Un billet non composté n'a pas le droit
     d'être exécuté. Compostez-le vous-même : chmod +x suivi du billet.

  4. DÉPARTS
     Panneau en panne. Rappel : seul le dernier train arrivé repart.
     Chaque voie garde la date d'arrivée de sa rame (ls -lt la montre).

  5. EMBARQUEMENT
     Lancez votre billet en indiquant la voie : ./billet voie

  ⚠ AVIS AUX VOYAGEURS
     Des voyageurs signalent un étage absent des plans, au-dessus du
     99, accessible depuis l'ascenseur. L'accès répondrait à un mot.
     Une tablette retrouvée derrière un guichet le connaîtrait.
     Le réseau décline toute responsabilité.

  Nous vous remercions de votre patience.
EOF
    cat > "$d/panneau.txt" <<'EOF'
—— HORS SERVICE ——

(griffonné au marqueur, en dessous)
Seul le dernier train arrivé repart. Les autres attendent.
EOF
    # Trois voies, arrivées à des heures différentes : la plus récente est la bonne
    maintenant="$(date +%s)"
    local ages=(7200 5400 3600) ordre=()
    for i in 1 2 3; do [ "$i" != "$bonne_voie" ] && ordre+=("$i"); done
    echo "Une rame, portes ouvertes." > "$d/voies/voie${ordre[0]}"
    echo "Une rame, portes ouvertes." > "$d/voies/voie${ordre[1]}"
    echo "Une rame, portes ouvertes. Le moteur tourne encore." > "$d/voies/voie$bonne_voie"
    touch -d "@$(( maintenant - ages[0] ))" "$d/voies/voie${ordre[0]}"
    touch -d "@$(( maintenant - ages[1] ))" "$d/voies/voie${ordre[1]}"
    touch -d "@$(( maintenant - 60 ))" "$d/voies/voie$bonne_voie"

    # Les objets trouvés : six billets nominatifs, un seul au numéro du joueur
    local appel numeros=() num deja
    appel="$(etat_get appel)"
    tmp="$(mktemp -d)"
    bon_billet="$(echo A B C D E F | tr ' ' '\n' | sed -n "$(alea 1 6)p")"
    etat_set billet "$(empreinte "$bon_billet")"
    for l in A B C D E F; do
        if [ "$l" = "$bon_billet" ]; then
            num="$appel"
        else
            # un autre numéro à deux chiffres, différent de celui du joueur et des autres
            while :; do
                num="$(alea 10 99)"
                deja=0
                for i in "${numeros[@]}" "$appel"; do [ "$i" = "$num" ] && deja=1; done
                [ "$deja" = 0 ] && break
            done
        fi
        numeros+=("$num")
        creer_action "$tmp/billet$l.sh" "billet $l" non "# Billet nominatif — Passager n° $num"
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
