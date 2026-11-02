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
BLANC=$'\e[97m'
FOND_GRIS=$'\e[100m'

# Vitesse de la machine à écrire (secondes par caractère).
# ECRITURE_RAPIDE=1 désactive l'effet (tests, démo pressée).
VITESSE="${VITESSE:-0.03}"

# Affiche un texte lettre par lettre : ecrire "texte" [couleur]
ecrire() {
    local texte="$1" couleur="${2:-}" i
    printf '%s' "$couleur"
    if [ "${ECRITURE_RAPIDE:-0}" = "1" ]; then
        printf '%s' "$texte"
    else
        for (( i = 0; i < ${#texte}; i++ )); do
            printf '%s' "${texte:i:1}"
            sleep "$VITESSE"
        done
    fi
    printf '%s\n' "$RESET"
}

# Pause, sauf en mode rapide
pause() {
    [ "${ECRITURE_RAPIDE:-0}" = "1" ] || sleep "$1"
}

# Écran brouillé pendant ~1 seconde
glitch() {
    local caracteres='#@%&$*!?<>/=+~^01ABCDEFXYZ' couleurs=("$ROUGE" "$VERT" "$CYAN" "$BLANC")
    local ligne n i largeur=60
    printf '\a'
    [ "${ECRITURE_RAPIDE:-0}" = "1" ] && return
    for (( n = 0; n < 18; n++ )); do
        ligne=""
        for (( i = 0; i < largeur; i++ )); do
            ligne+="${caracteres:RANDOM % ${#caracteres}:1}"
        done
        printf '%s%s%s\n' "${couleurs[RANDOM % 4]}" "$ligne" "$RESET"
        sleep 0.05
    done
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
