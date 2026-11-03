#!/usr/bin/env bash
# Error Ping 404 — efface les niveaux générés et l'état de la partie.

source "$(dirname "${BASH_SOURCE[0]}")/lib/etat.sh"
source "$JEU_ROOT/lib/niveaux.sh"

arreter_brouillage
rm -rf "$JEU_ROOT/niveaux" "$ETAT_DIR"
echo "Les niveaux ont été effacés. ./lancer.sh pour une nouvelle partie."
