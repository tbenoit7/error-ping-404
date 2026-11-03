#!/usr/bin/env bash
# Error Ping 404 — toutes les interactions du jeu (portes, télé, coffre...).
# Les scripts du monde appellent ce fichier : action.sh <action> [arguments]

source "$(dirname "${BASH_SOURCE[0]}")/etat.sh"
source "$JEU_ROOT/lib/effets.sh"
source "$JEU_ROOT/lib/niveaux.sh"
source "$JEU_ROOT/lib/fins.sh"

# Avant toute action : la partie est-elle encore en cours ?
verifier_partie() {
    if [ "$(etat_get fini)" = "1" ]; then
        echo
        piste "La partie est terminée. Relance ./lancer.sh pour rejouer."
        exit 0
    fi
    if (( $(temps_restant) <= 0 )); then
        fin_ratee temps
        exit 0
    fi
}

# Pose une question : demander "texte"
demander() {
    local reponse
    read -r -p "$MARGE$COUL_PISTE$1$RESET " reponse
    printf '%s' "$reponse"
}

action_porte_service() {
    echo
    local code; code="$(demander "Le clavier attend un code :")"
    echo
    if verifier_code code0 "$code"; then
        succes "Un déclic. La porte de service s'ouvre."
        narrer "Derrière, une cabine d'ascenseur. Les portes se referment derrière toi."
        narrer "Le panneau compte de 0 à 99."
        [ -d "$(base_monde)/niveau1_ascenseur" ] || generer_niveau1 "$(base_monde)"
        etat_set niveau 1
        bandeau "NIVEAU 1 · L'ASCENSEUR"
        etat_set aller "$(base_monde)/niveau1_ascenseur"
        piste "(Tu entres dans l'ascenseur : dossier niveau1_ascenseur/)"
        accueil_niveau 1
    else
        echec "Le clavier bipe. Une étiquette : « Le code est sur votre ticket. »"
    fi
}

action_porte_coupe_feu() {
    echo
    local code; code="$(demander "Un clavier, à côté de la poignée. Code :")"
    echo
    if verifier_code code1 "$code"; then
        succes "La porte coupe-feu cède."
        narrer "Derrière, un couloir moquetté. Quelque part, une télévision grésille."
        [ -d "$(base_monde)/niveau2_couloir" ] || generer_niveau2 "$(base_monde)"
        etat_set niveau 2
        bandeau "NIVEAU 2 · LE COULOIR"
        etat_set aller "$(base_monde)/niveau2_couloir"
        piste "(Tu entres dans le couloir : dossier niveau2_couloir/)"
        accueil_niveau 2
    else
        echec "La poignée ne bouge pas."
    fi
}

action_television() {
    echo
    if brouillage_actif; then
        neige
        echo
        echec "Le signal est brouillé. Quelque chose, quelque part, émet en continu."
        return
    fi
    echo "$MARGE${BLEU}══════════════════════════════════════════════════════${RESET}"
    echo "$MARGE${GRAS}   CANAL 0  •  LE JOURNAL DE LA NUIT${RESET}"
    echo "$MARGE${BLEU}══════════════════════════════════════════════════════${RESET}"
    echo
    ecrire "$MARGE Météo des étages : néons stables, humidité élevée." "$CYAN"
    ecrire "$MARGE Trafic : le dernier train n'a pas de terminus." "$CYAN"
    ecrire "$MARGE Avis aux clients : les objets laissés dans les" "$CYAN"
    ecrire "$MARGE coffres seront conservés indéfiniment." "$CYAN"
    echo
    ecrire "$MARGE    >>> TIRAGE DE CE SOIR :  5  2  8  1  <<<" "$JAUNE$GRAS"
    echo
    ecrire "$MARGE Merci de votre patience. Votre attente est importante." "$CYAN"
    pause 1
    # Une ligne qui n'a rien à faire là : le mot de passe de la tablette
    echo
    echo "$MARGE${COUL_MYSTERE}      ▒▒░░ ~ ~ ~ ░░▒▒ ~ ~ ░▒▒░ ~ ~ ~ ▒░░▒${RESET}"
    ecrire "$MARGE         regarde-toi dans le MIROIR" "$COUL_MYSTERE$GRAS"
    echo "$MARGE${COUL_MYSTERE}      ▒░░▒ ~ ~ ░▒▒░ ~ ~ ~ ░░▒▒ ~ ~ ~ ▒▒░░${RESET}"
    echo
    echo "$MARGE${BLEU}══════════════════════════════════════════════════════${RESET}"
    echo "$MARGE${GRIS}                    Fin des programmes.${RESET}"
}

action_coffre() {
    local d; d="$(base_monde)/niveau2_couloir"
    echo
    if [ -f "$d/cle" ] || [ -f "$d/porte_metro/cle" ]; then
        narrer "Le coffre est ouvert. Il est vide."
        return
    fi
    local code; code="$(demander "Le coffre a un cadran à 4 chiffres. Code :")"
    echo
    if verifier_code coffre "$code"; then
        succes "Clic. Le coffre s'ouvre. Une clé tombe à tes pieds."
        piste "(Un fichier « cle » vient d'apparaître dans le couloir.)"
        echo "Une clé en laiton. L'étiquette dit : MÉTRO." > "$d/cle"
    else
        echec "Le cadran revient à zéro."
    fi
}

action_ouvrir() {
    local d; d="$(base_monde)/niveau2_couloir"
    echo
    if [ ! -f "$d/porte_metro/cle" ]; then
        echec "La porte est verrouillée. Il faudrait mettre une clé dans la serrure."
        return
    fi
    succes "La serrure cède."
    narrer "Un escalier mécanique à l'arrêt descend vers un quai. Une rame attend, portes ouvertes."
    [ -d "$(base_monde)/niveau3_metro" ] || generer_niveau3 "$(base_monde)"
    etat_set niveau 3
    bandeau "NIVEAU 3 · LE MÉTRO"
    etat_set aller "$(base_monde)/niveau3_metro"
    piste "(Tu descends sur le quai : dossier niveau3_metro/)"
    accueil_niveau 3
}

action_billet() {
    local lettre="$1" voie="${2:-}"
    echo
    if [ "$(empreinte "$lettre")" != "$(etat_get billet)" ]; then
        echec "Ce billet n'est pas à ton numéro. Les portes refusent de s'ouvrir."
        return
    fi
    if [ -z "$voie" ]; then
        piste "Quelle voie ? (exemple : ./billet$lettre.sh voie1)"
        return
    fi
    voie="$(basename "$voie")"
    if [ "$(empreinte "$voie")" = "$(etat_get voie)" ]; then
        fin_normale
    elif [ -f "$(base_monde)/niveau3_metro/voies/$voie" ]; then
        fin_ratee train
    else
        echec "Il n'y a pas de $voie ici."
    fi
}

action_allumer() {
    local d; d="$(base_monde)/niveau0_salle_attente/guichet/.tablette"
    echo
    if [ ! -f "$d/.batterie" ] && [ ! -f "$d/batterie" ]; then
        echec "L'écran reste noir. Le compartiment de la batterie est vide."
        return
    fi
    if [ "$(etat_get tablette)" != "1" ]; then
        mystere "L'écran s'allume, d'un blanc éclatant. Un champ de saisie clignote."
        echo
        local mdp; mdp="$(demander "Mot de passe :")"
        echo
        if ! verifier_code mdp "$mdp"; then
            echec "L'écran s'éteint."
            return
        fi
        etat_set tablette 1
    fi
    mystere "La tablette n'affiche qu'un mot :"
    echo
    echo "$MARGE              ${MAGENTA}${GRAS}E T I R E V${RESET}"
}

action_bouton() {
    local mot
    echo
    narrer "Un clavier apparaît sous le bouton."
    echo
    mot="$(demander ">")"
    echo
    if [ "$(normaliser "$mot")" = "verite" ]; then
        mystere "Le bouton s'allume. L'ascenseur monte, longtemps. Bien plus haut que 99."
        mystere "Les portes s'ouvrent sur un étage qui n'est pas sur le panneau."
        generer_etage_404
        bandeau "NIVEAU ? · ???" "$COUL_MYSTERE"
        etat_set aller "$(base_monde)/niveau1_ascenseur/.etage404"
        piste "(Tu sors de la cabine : dossier .etage404/)"
        accueil_niveau 404
    else
        narrer "Rien ne se passe."
    fi
}

action_verite() {
    fin_secrete
}

# ---------------------------------------------------------------- Aiguillage
action="${1:-}"
shift || true
verifier_partie
case "$action" in
    porte_service|porte_coupe_feu|television|coffre|ouvrir|billet|allumer|bouton|verite)
        "action_$action" "$@" ;;
    *)
        echo; narrer "Rien ne se passe." ;;
esac
