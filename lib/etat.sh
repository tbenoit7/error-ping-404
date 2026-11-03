#!/usr/bin/env bash
# Error Ping 404 — état de la partie, timer et vérification des codes.
# Ce fichier est « sourcé » par les autres scripts, il ne se lance pas seul.

JEU_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ETAT_DIR="$JEU_ROOT/.etat"
ETAT_FICHIER="$ETAT_DIR/etat"

# Lire une valeur : etat_get cle
etat_get() {
    [ -f "$ETAT_FICHIER" ] || return 0
    grep -m1 "^$1=" "$ETAT_FICHIER" | cut -d'=' -f2-
}

# Écrire une valeur : etat_set cle valeur
etat_set() {
    mkdir -p "$ETAT_DIR"
    touch "$ETAT_FICHIER"
    grep -v "^$1=" "$ETAT_FICHIER" > "$ETAT_FICHIER.tmp"
    echo "$1=$2" >> "$ETAT_FICHIER.tmp"
    mv "$ETAT_FICHIER.tmp" "$ETAT_FICHIER"
}

# Empreinte sha256 d'un texte (les codes ne sont jamais stockés en clair)
empreinte() {
    printf '%s' "$1" | sha256sum | cut -d' ' -f1
}

# Normalise une saisie : minuscules, sans accents, sans espaces autour
normaliser() {
    local s="$1"
    local paire
    for paire in É:e é:e È:e è:e Ê:e ê:e Ë:e ë:e À:a à:a Â:a â:a Ä:a ä:a \
                 Î:i î:i Ï:i ï:i Ô:o ô:o Ö:o ö:o Ù:u ù:u Û:u û:u Ü:u ü:u Ç:c ç:c; do
        s="${s//"${paire%%:*}"/"${paire##*:}"}"
    done
    s="${s,,}"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

# Vérifie une saisie contre l'empreinte stockée : verifier_code cle saisie
verifier_code() {
    [ "$(empreinte "$(normaliser "$2")")" = "$(etat_get "$1")" ]
}

# Secondes restantes avant la fin du compte à rebours
temps_restant() {
    local debut duree
    debut="$(etat_get debut)"
    duree="$(etat_get duree)"
    [ -z "$debut" ] && { echo 0; return; }
    echo $(( debut + duree - $(date +%s) ))
}

# Format mm:ss
temps_formate() {
    local r; r="$(temps_restant)"
    (( r < 0 )) && r=0
    printf '%02d:%02d' $(( r / 60 )) $(( r % 60 ))
}

# Dossier du monde courant (change après la fin secrète)
base_monde() {
    local b; b="$(etat_get base)"
    echo "${b:-$JEU_ROOT/niveaux}"
}

# Petit tirage aléatoire : alea min max
alea() {
    echo $(( $1 + RANDOM % ($2 - $1 + 1) ))
}
