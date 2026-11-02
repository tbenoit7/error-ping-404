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

# ---------------------------------------------------------------- Vérification du disque
# Le jeu crée des scripts et repose sur chmod +x : la partition doit gérer
# les droits Unix et autoriser l'exécution (pas de FAT/exFAT/NTFS, pas de noexec).
verifier_disque() {
    local test="$JEU_ROOT/.test_droits_$$"
    printf '#!/usr/bin/env bash\nexit 0\n' > "$test" 2> /dev/null || {
        echo "Impossible d'écrire dans $JEU_ROOT."; return 1; }
    chmod 644 "$test"
    if [ -x "$test" ]; then rm -f "$test"; return 1; fi
    chmod 755 "$test"
    if ! "$test" 2> /dev/null; then rm -f "$test"; return 1; fi
    rm -f "$test"
}
if ! verifier_disque; then
    echo "Ce dossier ne gère pas les droits d'exécution (partition FAT/NTFS ou montée en noexec)."
    echo "Le jeu repose sur chmod +x : clone-le ou copie-le dans ton dossier personnel, par exemple :"
    echo "    cp -r \"$JEU_ROOT\" ~ && cd ~/$(basename "$JEU_ROOT") && ./lancer.sh"
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
    echo
    VITESSE=0.01
    echo "$MARGE${FOND_GRIS} Boîte de réception (1) ─────────────────────────────── ${RESET}"
    echo "${MARGE}De      : ████████@█████"
    echo "${MARGE}Objet   : aide"
    echo "${MARGE}Reçu    : il y a 0 minute"
    echo
    narrer "Je ne sais pas si ce message parviendra à quelqu'un."
    narrer "Si c'est le cas, lis-le jusqu'au bout."
    echo
    narrer "Je suis retenu quelque part. Je ne sais pas qui m'a"
    narrer "amené ici, ni pourquoi. Les pièces se répètent. Il y a"
    narrer "un ascenseur qui descend sans fin, et des néons qui ne"
    narrer "s'éteignent jamais."
    echo
    narrer "Je n'ai presque plus de batterie. J'ai réussi à"
    narrer "partager ma position avant que le réseau ne coupe :"
    echo
    echo "$MARGE    ${BLEU}${GRAS}http://10.4.0.4/localiser?id=0017${RESET}"
    echo
    narrer "Je t'en supplie, viens me chercher."
    narrer "Tu es le seul à qui j'ai pu écrire."
    echo
    read -r -p "$MARGE$COUL_PISTE[ Appuie sur Entrée pour ouvrir le lien ]$RESET "
    VITESSE=0.03
    glitch
    clear
    pause 2
    narrer "Tu ouvres les yeux. Une odeur de produits d'entretien, un blanc aveuglant."
    narrer "Un bourdonnement de néon à l'extérieur, un tic d'horloge à l'intérieur."
    pause 1
}

ecran_sombre
[ "$INTRO" = "1" ] && intro

# ---------------------------------------------------------------- Le monde
generer_jusqua "$JEU_ROOT/monde" "$NIVEAU_DEPART"
etat_set debut "$(date +%s)"

case "$NIVEAU_DEPART" in
    0) depart="$JEU_ROOT/monde/salle_attente"; titre="NIVEAU 0 · LA SALLE D'ATTENTE" ;;
    1) depart="$JEU_ROOT/monde/ascenseur";     titre="NIVEAU 1 · L'ASCENSEUR" ;;
    2) depart="$JEU_ROOT/monde/couloir_hotel"; titre="NIVEAU 2 · LE COULOIR D'HÔTEL" ;;
    3) depart="$JEU_ROOT/monde/quai";          titre="NIVEAU 3 · LE QUAI" ;;
esac
bandeau "$titre"

# Le shell de jeu : un bash interactif avec son propre prompt et son timer
( cd "$depart" && bash --rcfile "$JEU_ROOT/lib/shellrc.sh" -i )

# ---------------------------------------------------------------- Après la partie
arreter_brouillage
echo
piste "Merci d'avoir joué à Error Ping 404."
echo
