#!/usr/bin/env bash
# Error Ping 404 — effets visuels : couleurs, machine à écrire, glitch.

RESET=$'\e[0m'
GRAS=$'\e[1m'
GRIS=$'\e[90m'
ROUGE=$'\e[31m'
VERT=$'\e[32m'
JAUNE=$'\e[33m'
BLEU=$'\e[34m'
CYAN=$'\e[36m'
MAGENTA=$'\e[35m'
BLANC=$'\e[39m'          # couleur de texte par défaut du terminal
FOND_GRIS=$'\e[100m'

# ---------------------------------------------------------------- Code couleur
# Chaque type de texte a sa couleur, pour que le joueur s'y retrouve :
#   narration (ce qu'on voit, ce qu'il se passe)  -> couleur normale
#   réussite (une porte s'ouvre)                  -> vert
#   échec (mauvais code, rien ne se passe)        -> jaune
#   piste (où aller ensuite, aide)                -> cyan
#   mystère (fin secrète, détails étranges)       -> magenta
#   danger (fin ratée, temps presque écoulé)      -> rouge
COUL_NARRATION="$BLANC"
COUL_SUCCES="$VERT$GRAS"
COUL_ECHEC="$JAUNE"
COUL_PISTE="$CYAN"
COUL_MYSTERE="$MAGENTA"
COUL_DANGER="$ROUGE$GRAS"
MARGE="  "

# Vitesse de la machine à écrire (secondes par caractère), pour tout le jeu.
# lancer.sh la modifie seulement pendant l'intro.
VITESSE=0.03

# Affiche un texte lettre par lettre : ecrire "texte" [couleur]
ecrire() {
    local texte="$1" couleur="${2:-}" i
    printf '%s' "$couleur"
    for (( i = 0; i < ${#texte}; i++ )); do
        printf '%s' "${texte:i:1}"
        sleep "$VITESSE"
    done
    printf '%s\n' "$RESET"
}

# Raccourcis par type de texte (avec une marge à gauche)
narrer()  { ecrire "$MARGE$1" "$COUL_NARRATION"; }
succes()  { ecrire "$MARGE$1" "$COUL_SUCCES"; }
echec()   { echo "$MARGE$COUL_ECHEC$1$RESET"; }
piste()   { echo "$MARGE$COUL_PISTE$1$RESET"; }
mystere() { ecrire "$MARGE$1" "$COUL_MYSTERE"; }
danger()  { ecrire "$MARGE$1" "$COUL_DANGER"; }

# Grand titre de lieu : bandeau "NIVEAU 1 · L'ASCENSEUR"
bandeau() {
    echo
    echo "$MARGE${2:-$COUL_PISTE}━━━━━━━━  $1  ━━━━━━━━$RESET"
    echo
}

# Pause de quelques secondes
pause() {
    sleep "$1"
}

# Écran brouillé : des lignes de parasites décalées, traversées de fragments
# de messages corrompus, puis une ligne d'erreur
glitch() {
    local caracteres='#@%&$*!?<>/=+~^01ABCDEFXYZ' couleurs=("$ROUGE" "$VERT" "$CYAN" "$MAGENTA" "$BLANC")
    local fragments=("ERROR" "PING 404" "NO SIGNAL" "run_away.exe" "0x404" "SEGFAULT" "?????" "LOOP" "/dev/null" "RECONNEXION")
    local ligne n i largeur decalage pos frag
    printf '\a'
    for (( n = 0; n < 16; n++ )); do
        largeur=$(( 20 + RANDOM % 50 ))
        decalage=$(( RANDOM % 12 ))
        ligne=""
        for (( i = 0; i < largeur; i++ )); do
            ligne+="${caracteres:RANDOM % ${#caracteres}:1}"
        done
        # Une fois sur trois, un fragment de message vient s'incruster
        if (( RANDOM % 3 == 0 )); then
            frag="${fragments[RANDOM % ${#fragments[@]}]}"
            pos=$(( RANDOM % (largeur - ${#frag} + 1) ))
            ligne="${ligne:0:pos}${RESET}${GRAS}${BLANC} $frag ${RESET}${couleurs[RANDOM % 5]}${ligne:pos+${#frag}+2}"
        fi
        printf '%*s%s%s%s\n' "$decalage" '' "${couleurs[RANDOM % 5]}" "$ligne" "$RESET"
        sleep 0.04
    done
    printf '\n%s%s  ░▒▓█  ERROR : PING 404  █▓▒░  %s\n' "$MARGE" "$ROUGE$GRAS" "$RESET"
    sleep 0.6
}

# Neige de télévision pendant ~3 secondes
neige() {
    local caracteres=' .:;+=*#%@' ligne n i
    for (( n = 0; n < 30; n++ )); do
        ligne=""
        for (( i = 0; i < 50; i++ )); do
            ligne+="${caracteres:RANDOM % ${#caracteres}:1}"
        done
        printf '%s%s%s\n' "$GRIS" "$ligne" "$RESET"
        pause 0.1
    done
}
