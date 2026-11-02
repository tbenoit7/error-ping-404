#!/usr/bin/env bash
# Error Ping 404 — efface le monde généré et l'état de la partie.

source "$(dirname "${BASH_SOURCE[0]}")/lib/etat.sh"
source "$JEU_ROOT/lib/niveaux.sh"

arreter_brouillage
rm -rf "$JEU_ROOT/monde" "$ETAT_DIR"
echo "Le monde a été effacé. ./lancer.sh pour une nouvelle partie."
