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
        *"/.etage404"*)       echo "Niveau ? · ???" ;;
        *"/salle_attente"*)   echo "Niveau 0 · La salle d'attente" ;;
        *"/ascenseur"*)       echo "Niveau 1 · L'ascenseur" ;;
        *"/couloir"*)         echo "Niveau 2 · Le couloir" ;;
        *"/metro"*)           echo "Niveau 3 · Le métro" ;;
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
    local reste lieu couleur_lieu="$COUL_PISTE"
    reste="$(temps_restant)"
    if   (( reste > 300 )); then couleur="$VERT"
    elif (( reste > 120 )); then couleur="$JAUNE"
    else couleur="$ROUGE$GRAS"; fi
    lieu="$(__jeu_lieu)"
    [[ "$lieu" == *"?"* ]] && couleur_lieu="$COUL_MYSTERE"
    # Une ligne vide, puis le bandeau du lieu et du temps, puis le dossier courant
    PS1="\n\[$couleur_lieu\]━━ \[$GRAS\]$lieu\[$RESET$couleur_lieu\] ━━ \[$RESET$couleur\]$(temps_formate)\[$RESET$couleur_lieu\] ━━\[$RESET\]\n\[$GRIS\]\W\[$RESET\] \$ "
}
PROMPT_COMMAND=__jeu_prompt

piste "Vérifie bien à regarder partout et à ne rien oublier..."
piste "(cat regarder_autour.txt)"
