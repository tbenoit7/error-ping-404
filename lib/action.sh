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
        echo "La partie est terminée. Relance ./lancer.sh pour rejouer."
        exit 0
    fi
    if (( $(temps_restant) <= 0 )); then
        fin_ratee temps
        exit 0
    fi
}

demander() {
    local reponse
    read -r -p "$1" reponse
    printf '%s' "$reponse"
}

action_porte_service() {
    local code; code="$(demander "Le clavier attend un code : ")"
    if verifier_code code0 "$code"; then
        echo
        ecrire "La porte s'ouvre sur une cabine d'ascenseur. Les portes se referment derrière toi." "$BLANC"
        ecrire "Le panneau compte jusqu'à -99." "$BLANC"
        [ -d "$(base_monde)/ascenseur" ] || generer_niveau1 "$(base_monde)"
        etat_set niveau 1
        echo "${GRIS}(La cabine t'attend : ../ascenseur)${RESET}"
    else
        echo "Le clavier bipe. Une étiquette : « Le code est sur votre ticket. »"
    fi
}

action_porte_coupe_feu() {
    local code; code="$(demander "Un clavier, à côté de la poignée. Code : ")"
    if verifier_code code1 "$code"; then
        echo
        ecrire "La porte cède. Derrière, un couloir moquetté." "$BLANC"
        ecrire "Quelque part, une télévision grésille." "$BLANC"
        [ -d "$(base_monde)/couloir_hotel" ] || generer_niveau2 "$(base_monde)"
        etat_set niveau 2
        echo "${GRIS}(Le couloir : ../../couloir_hotel)${RESET}"
    else
        echo "La poignée ne bouge pas."
    fi
}

action_television() {
    if brouillage_actif; then
        neige
        echo "${GRIS}Le signal est brouillé. Quelque chose, quelque part, émet en continu.${RESET}"
        return
    fi
    clear
    echo "${BLEU}══════════════════════════════════════════════════════${RESET}"
    echo "${BLANC}${GRAS}   CANAL 0  •  LE JOURNAL DE LA NUIT${RESET}"
    echo "${BLEU}══════════════════════════════════════════════════════${RESET}"
    ecrire " Météo des étages : néons stables, humidité élevée." "$CYAN"
    ecrire " Trafic : le dernier train n'a pas de terminus." "$CYAN"
    ecrire " Avis aux clients : les objets laissés dans les" "$CYAN"
    ecrire " coffres seront conservés indéfiniment." "$CYAN"
    echo
    ecrire "    >>> TIRAGE DE CE SOIR :  5  2  8  1  <<<" "$JAUNE$GRAS"
    echo
    ecrire " Merci de votre patience. Votre attente est importante." "$CYAN"
    pause 1
    # Une ligne qui n'a rien à faire là, une demi-seconde
    printf '%s' "${ROUGE}${GRAS}        regarde-toi dans le MIROIR${RESET}"
    if [ "${ECRITURE_RAPIDE:-0}" = "1" ]; then echo; else sleep 0.5; printf '\r%60s\r' ''; fi
    echo "${BLEU}══════════════════════════════════════════════════════${RESET}"
    ecrire "                        Fin des programmes." "$GRIS"
}

action_coffre() {
    local d; d="$(base_monde)/couloir_hotel"
    if [ -f "$d/cle" ] || [ -f "$d/porte_metro/cle" ]; then
        echo "Le coffre est ouvert. Il est vide."
        return
    fi
    local code; code="$(demander "Le coffre a un cadran à 4 chiffres. Code : ")"
    if verifier_code coffre "$code"; then
        echo "Clic. Le coffre s'ouvre. Une clé tombe à tes pieds."
        echo "Une clé en laiton. L'étiquette dit : MÉTRO." > "$d/cle"
    else
        echo "Le cadran revient à zéro."
    fi
}

action_ouvrir() {
    local d; d="$(base_monde)/couloir_hotel"
    if [ ! -f "$d/porte_metro/cle" ]; then
        echo "La porte est verrouillée. Il faudrait mettre une clé dans la serrure."
        return
    fi
    echo
    ecrire "La serrure cède. Un escalier mécanique à l'arrêt descend vers un quai." "$BLANC"
    ecrire "Une rame attend, portes ouvertes." "$BLANC"
    [ -d "$(base_monde)/quai" ] || generer_niveau3 "$(base_monde)"
    etat_set niveau 3
    echo "${GRIS}(Le quai : ../../quai)${RESET}"
}

action_billet() {
    local lettre="$1" voie="${2:-}"
    if [ "$(empreinte "$lettre")" != "$(etat_get billet)" ]; then
        echo "Le composteur rejette ton billet. Il est périmé."
        return
    fi
    if [ -z "$voie" ]; then
        echo "Quelle voie ? (exemple : ./billet_$lettre.sh voie_1)"
        return
    fi
    voie="$(basename "$voie")"
    if [ "$(empreinte "$voie")" = "$(etat_get voie)" ]; then
        fin_normale
    elif [ -f "$(base_monde)/quai/voies/$voie" ]; then
        fin_ratee train
    else
        echo "Il n'y a pas de $voie ici."
    fi
}

action_allumer() {
    local d; d="$(base_monde)/salle_attente/guichet/.tablette"
    if [ ! -f "$d/batterie" ]; then
        echo "L'écran reste noir. Le compartiment de la batterie est vide."
        return
    fi
    if [ "$(etat_get tablette)" != "1" ]; then
        ecrire "L'écran s'allume, d'un blanc éclatant. Un champ de saisie clignote." "$BLANC"
        local mdp; mdp="$(demander "Mot de passe : ")"
        if ! verifier_code mdp "$mdp"; then
            echo "L'écran s'éteint."
            return
        fi
        etat_set tablette 1
    fi
    echo
    ecrire "La tablette n'affiche qu'un mot :" "$GRIS"
    echo
    echo "                ${VERT}${GRAS}E T I R E V${RESET}"
    echo
}

action_bouton() {
    local mot
    echo "Un clavier apparaît sous le bouton."
    mot="$(demander "> ")"
    if [ "$(normaliser "$mot")" = "verite" ]; then
        echo
        ecrire "Le bouton s'allume. L'ascenseur descend, longtemps. Bien plus bas que -99." "$BLANC"
        ecrire "Les portes s'ouvrent sur un étage qui n'est pas sur le panneau." "$BLANC"
        generer_etage_404
        echo "${GRIS}(Quelque chose est apparu dans l'ascenseur. Regarde partout.)${RESET}"
    else
        echo "Rien ne se passe."
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
        echo "Rien ne se passe." ;;
esac
