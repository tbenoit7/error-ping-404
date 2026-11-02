#!/usr/bin/env bash
# Error Ping 404 — lancement d'une partie.
#
# Utilisation :
#   ./lancer.sh                 partie normale (15 minutes)
#   ./lancer.sh --duree 10      durée en minutes
#   ./lancer.sh --niveau 2      démo : niveaux 0 à 2 déjà ouverts, départ au niveau 2
#   ./lancer.sh --sans-intro    passe le mail et le glitch
#   ./lancer.sh --rapide        désactive l'effet machine à écrire

DUREE_MINUTES=15
NIVEAU_DEPART=0
INTRO=1

source "$(dirname "${BASH_SOURCE[0]}")/lib/etat.sh"
source "$JEU_ROOT/lib/effets.sh"
source "$JEU_ROOT/lib/niveaux.sh"
source "$JEU_ROOT/lib/fins.sh"

while [ $# -gt 0 ]; do
    case "$1" in
        --duree)      DUREE_MINUTES="$2"; shift ;;
        --niveau)     NIVEAU_DEPART="$2"; shift ;;
        --sans-intro) INTRO=0 ;;
        --rapide)     export ECRITURE_RAPIDE=1 ;;
        *) echo "Option inconnue : $1"; exit 1 ;;
    esac
    shift
done

if ! [[ "$NIVEAU_DEPART" =~ ^[0-3]$ ]]; then
    echo "Le niveau de départ doit être entre 0 et 3."
    exit 1
fi

# ---------------------------------------------------------------- Remise à zéro
arreter_brouillage
rm -rf "$JEU_ROOT/monde" "$ETAT_DIR"
mkdir -p "$JEU_ROOT/monde" "$ETAT_DIR"
etat_set duree $(( DUREE_MINUTES * 60 ))
etat_set heure $(( 10#$(date +%H) ))
etat_set appel 17
etat_set base "$JEU_ROOT/monde"
etat_set fini 0
etat_set tablette 0

# ---------------------------------------------------------------- Intro
intro() {
    clear
    VITESSE=0.01
    echo "${FOND_GRIS}${BLANC} Boîte de réception (1) ─────────────────────────────── ${RESET}"
    echo "De      : ████████@█████"
    echo "Objet   : aide"
    echo "Reçu    : il y a 0 minute"
    echo
    ecrire "Je ne sais pas si ce message parviendra à quelqu'un."
    ecrire "Si c'est le cas, lis-le jusqu'au bout."
    echo
    ecrire "Je suis retenu quelque part. Je ne sais pas qui m'a"
    ecrire "amené ici, ni pourquoi. Les pièces se répètent. Il y a"
    ecrire "un ascenseur qui descend sans fin, et des néons qui ne"
    ecrire "s'éteignent jamais."
    echo
    ecrire "Je n'ai presque plus de batterie. J'ai réussi à"
    ecrire "partager ma position avant que le réseau ne coupe :"
    echo
    echo "    ${BLEU}http://10.4.0.4/localiser?id=0017${RESET}"
    echo
    ecrire "Je t'en supplie, viens me chercher."
    ecrire "Tu es le seul à qui j'ai pu écrire."
    echo
    read -r -p "[ Appuie sur Entrée pour ouvrir le lien ] "
    VITESSE=0.03
    glitch
    clear
    pause 2
    ecrire "Tu ouvres les yeux. Une odeur de produits d'entretien, un blanc aveuglant." "$GRIS"
    ecrire "Un bourdonnement de néon à l'extérieur, un tic d'horloge à l'intérieur." "$GRIS"
    pause 1
}

[ "$INTRO" = "1" ] && intro

# ---------------------------------------------------------------- Le monde
generer_jusqua "$JEU_ROOT/monde" "$NIVEAU_DEPART"
etat_set debut "$(date +%s)"

case "$NIVEAU_DEPART" in
    0) depart="$JEU_ROOT/monde/salle_attente" ;;
    1) depart="$JEU_ROOT/monde/ascenseur" ;;
    2) depart="$JEU_ROOT/monde/couloir_hotel" ;;
    3) depart="$JEU_ROOT/monde/quai" ;;
esac

# Le shell de jeu : un bash interactif avec son propre prompt et son timer
( cd "$depart" && bash --rcfile "$JEU_ROOT/lib/shellrc.sh" -i )

# ---------------------------------------------------------------- Après la partie
arreter_brouillage
echo
echo "${GRIS}Merci d'avoir joué à Error Ping 404.${RESET}"
