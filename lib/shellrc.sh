# Error Ping 404 — configuration du shell de jeu.
# Chargé par lancer.sh avec : bash --rcfile lib/shellrc.sh -i

source "$(dirname "${BASH_SOURCE[0]}")/etat.sh"
source "$JEU_ROOT/lib/effets.sh"
source "$JEU_ROOT/lib/niveaux.sh"
source "$JEU_ROOT/lib/fins.sh"

alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Nom du lieu, déduit du dossier courant
__jeu_lieu() {
    case "$PWD" in
        *"/.etage_-404"*)     echo "Niveau ? · ???" ;;
        *"/salle_attente"*)   echo "Niveau 0 · La salle d'attente" ;;
        *"/ascenseur"*)       echo "Niveau 1 · L'ascenseur" ;;
        *"/couloir_hotel"*)   echo "Niveau 2 · Le couloir d'hôtel" ;;
        *"/quai"*)            echo "Niveau 3 · Le quai" ;;
        *)                    echo "Hors des murs" ;;
    esac
}

# Exécuté avant chaque affichage du prompt
__jeu_prompt() {
    local aller couleur
    # Après la fin secrète : on est ramené dans la nouvelle salle d'attente
    aller="$(etat_get aller)"
    if [ -n "$aller" ]; then
        etat_set aller ""
        cd "$aller" || true
    fi
    # Partie terminée : on quitte le shell de jeu
    if [ "$(etat_get fini)" = "1" ]; then
        echo
        exit 0
    fi
    # Temps écoulé
    if (( $(temps_restant) <= 0 )); then
        fin_ratee temps
        echo
        exit 0
    fi
    couleur="$BLANC"
    (( $(temps_restant) < 120 )) && couleur="$ROUGE$GRAS"
    PS1="\[$GRIS\][\[$BLANC\]$(__jeu_lieu)\[$GRIS\] | \[$couleur\]$(temps_formate)\[$RESET$GRIS\]]\[$RESET\] \W \$ "
}
PROMPT_COMMAND=__jeu_prompt

echo
ecrire "Vérifie bien à regarder partout et à ne rien oublier... (cat regarder_autour.txt)" "$GRIS"
echo
