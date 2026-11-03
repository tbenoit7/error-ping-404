#!/usr/bin/env bash
# Error: Ping 404 — lancement d'une partie.
#
# Utilisation :
#   ./lancer.sh                 partie normale (30 minutes)
#   ./lancer.sh --niveau 2      démo : niveaux 0 à 2 déjà ouverts, départ au niveau 2

DUREE_MINUTES=30
NIVEAU_DEPART=0

source "$(dirname "${BASH_SOURCE[0]}")/lib/etat.sh"
source "$JEU_ROOT/lib/effets.sh"
source "$JEU_ROOT/lib/niveaux.sh"
source "$JEU_ROOT/lib/fins.sh"

while [ $# -gt 0 ]; do
    case "$1" in
        --niveau) NIVEAU_DEPART="$2"; shift ;;
        *) echo "Option inconnue : $1"; exit 1 ;;
    esac
    shift
done

if ! [[ "$NIVEAU_DEPART" =~ ^[0-3]$ ]]; then
    echo "Le niveau de départ doit être entre 0 et 3."
    exit 1
fi

# ---------------------------------------------------------------- Ambiance sombre
# Fond noir et texte gris clair le temps de la partie, puis couleurs d'origine
# restaurées (codes OSC 10/11, gérés par la plupart des terminaux Linux).
ecran_sombre()   { printf '\e]10;#d0d0d0\a\e]11;#0a0a0a\a'; clear; }
ecran_normal()   { printf '\e]110\a\e]111\a'; }
trap 'ecran_normal' EXIT

# ---------------------------------------------------------------- Remise à zéro
arreter_brouillage
rm -rf "$JEU_ROOT/niveaux" "$ETAT_DIR"
mkdir -p "$JEU_ROOT/niveaux" "$ETAT_DIR"
etat_set duree $(( DUREE_MINUTES * 60 ))
etat_set heure $(( 10#$(date +%H) ))
etat_set appel 17
etat_set base "$JEU_ROOT/niveaux"
etat_set fini 0
etat_set tablette 0

# ---------------------------------------------------------------- Intro
intro() {
    clear
    echo
    VITESSE=0.05
    echo "$MARGE${FOND_GRIS} Boîte de réception (1) ─────────────────────────────── ${RESET}"
    echo "${MARGE}De      : ████████@█████"
    echo "${MARGE}Objet   : Error: Ping 404 (run_away.exe)"
    echo "${MARGE}Reçu    : il y a 0 minute"
    echo
    narrer "Je ne sais pas si ce message parviendra à quelqu'un."
    narrer "Mais, si c'est le cas... aidez-moi s'il vous plaît."
    echo
    narrer "Je suis retenu quelque part. Je ne sais pas qui m'a amené"
    narrer "ici, ni pourquoi. Mais cet endroit, il est... bizarre."
    narrer "Quelque chose ou quelqu'un me veut du mal, j'en suis certain."
    echo
    narrer "Rien n'est logique ici, entre :"
    narrer " - cette salle remplie de chaises et de fausses fenêtres"
    narrer " - cet ascenseur infini qui ne mène nulle part"
    narrer " - ce couloir long comme le monde et ses bruits étranges"
    narrer " - ce train qui semble mener à la fin du monde"
    echo
    narrer "Bref, je n'ai presque plus de batterie. J'ai réussi à"
    narrer "partager ma position avant que le réseau ne coupe :"
    echo
    echo "$MARGE    ${BLEU}${GRAS}http://10.4.0.4/localiser?id=0017${RESET}"
    echo
    narrer "Je t'en supplie, viens me chercher."
    narrer "Tu es le seul à qui j'ai pu écrire !"
    echo
    read -r -p "$MARGE$COUL_PISTE[ Appuie sur Entrée pour ouvrir le lien ]$RESET "
    VITESSE=0.05
    glitch
    clear
    pause 2
    narrer "..."
    pause 2
    narrer "Tu ouvres lentement les yeux, et c'est alors que..."
    pause 1
    echo
    narrer "Tu sens, comme une odeur de produits d'entretien..."
    pause 1
    narrer "Tu vois, comme un blanc aveuglant..."
    pause 1
    narrer "Tu entends, comme un tic d'horloge..."
    pause 1
    echo
    narrer "Tu regardes autour de toi et tu réalises une chose :"
    pause 2
    echo
    echo
    VITESSE=0.1
    narrer "$MARGE    Tu n'es pas en sécurité ici."
    pause 1
    VITESSE=0.2
    narrer "$MARGE              ${ROUGE}${GRAS}FUIS${RESET} "
    pause 1
    VITESSE=0.05
}

ecran_sombre
intro

# ---------------------------------------------------------------- Les niveaux
generer_jusqua "$JEU_ROOT/niveaux" "$NIVEAU_DEPART"
etat_set debut "$(date +%s)"

case "$NIVEAU_DEPART" in
    0) depart="$JEU_ROOT/niveaux/niveau0_salle_attente"; titre="NIVEAU 0 · LA SALLE D'ATTENTE" ;;
    1) depart="$JEU_ROOT/niveaux/niveau1_ascenseur";     titre="NIVEAU 1 · L'ASCENSEUR" ;;
    2) depart="$JEU_ROOT/niveaux/niveau2_couloir"; titre="NIVEAU 2 · LE COULOIR" ;;
    3) depart="$JEU_ROOT/niveaux/niveau3_metro";   titre="NIVEAU 3 · LE MÉTRO" ;;
esac
bandeau "$titre"

# Le shell de jeu : un bash interactif avec son propre prompt et son timer
( cd "$depart" && bash --rcfile "$JEU_ROOT/lib/shellrc.sh" -i )

# ---------------------------------------------------------------- Après la partie
arreter_brouillage
echo
piste "Merci d'avoir joué à Error Ping 404."
echo
read -r -p "$MARGE$COUL_PISTE[ Appuie sur Entrée pour quitter ]$RESET "