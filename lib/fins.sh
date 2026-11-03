#!/usr/bin/env bash
# Error Ping 404 — les fins : normale, ratée, secrète.

fin_normale() {
    local reste; reste="$(temps_formate)"
    echo
    narrer "Les portes se ferment. Le train démarre dans le noir."
    narrer "Les néons défilent, de plus en plus vite, puis plus rien."
    pause 1
    glitch
    echo
    echo "${COUL_SUCCES}"
    cat <<'EOF'
   ███████  ██████  ██████  ████████ ██
   ██      ██    ██ ██   ██    ██    ██
   ███████ ██    ██ ██████     ██    ██
        ██ ██    ██ ██   ██    ██    ██
   ███████  ██████  ██   ██    ██    ██
EOF
    echo "${RESET}"
    narrer "Tu te réveilles devant ton écran. Tout est normal."
    pause 1
    mystere "Une notification apparaît : Nouveau message (1)."
    echo
    echo "$MARGE${COUL_SUCCES}Temps restant : $reste${RESET}"
    echo
    piste "(Fin normale. Certains secrets n'ont pas été découverts...)"
    terminer_partie
}

fin_ratee() {
    echo
    [ "$1" = "temps" ] && danger "Le bourdonnement s'arrête. Le silence est pire."
    [ "$1" = "train" ] && narrer "Le train ne démarre pas. Les portes se ferment derrière toi."
    narrer "Les néons se rallument."
    pause 1
    glitch
    echo
    narrer "Une salle d'attente d'un blanc aveuglant."
    echo
    echo "        ${ROUGE}${GRAS}NUMÉRO APPELÉ : $(( $(etat_get appel) + 1 ))${RESET}"
    echo
    piste "(Fin ratée. Relance ./lancer.sh pour retenter ta chance.)"
    terminer_partie
}

terminer_partie() {
    etat_set fini 1
    arreter_brouillage
}

fin_secrete() {
    local utilisateur machine ancien nouveau base
    utilisateur="${USER:-$(whoami)}"
    machine="${HOSTNAME:-$(hostname 2> /dev/null || echo machine)}"

    glitch
    echo
    pause 2
    mystere "lecture : enregistrement_retrouve.mp4"
    echo
    pause 1
    mystere "Une caméra posée sur une chaise orange."
    mystere "Quelqu'un s'assoit face à l'objectif. Il a ton visage."
    mystere "Il a l'air fatigué."
    echo
    pause 1
    narrer "  « Si tu regardes ça, c'est que ça a recommencé."
    narrer "    Le message, c'est moi qui l'ai envoyé. Je n'avais pas le choix."
    narrer "    Il fallait que quelqu'un vienne, et il n'y a que moi qui viens toujours."
    narrer "    Je t'ai laissé la tablette. Je t'ai laissé la batterie."
    narrer "    J'espère que cette fois, tu vas comprendre avant de prendre le train."
    narrer "    Ne réponds pas au prochain message. »"
    echo
    pause 2
    echo "$MARGE${FOND_GRIS} Boîte de réception (1) ${RESET}"
    echo "${MARGE}De      : ${ROUGE}${GRAS}$utilisateur@$machine${RESET}"
    echo "${MARGE}Objet   : aide"
    echo "${MARGE}Envoyé  : dans 3 minutes"
    pause 3
    glitch
    echo
    pause 2

    # La boucle recommence : nouvelle salle d'attente, numéro suivant
    arreter_brouillage
    ancien="$(etat_get appel)"
    nouveau=$(( ancien + 1 ))
    base="$JEU_ROOT/niveaux/boucle_$nouveau"
    rm -rf "$base"
    etat_set appel "$nouveau"
    etat_set base "$base"
    etat_set tablette 0
    etat_set niveau 0
    etat_set debut "$(date +%s)"
    generer_niveau0 "$base"
    etat_set aller "$base/niveau0_salle_attente"
    etat_set revelation 1   # la prochaine commande du joueur déclenche la révélation finale

    mystere "Tu ouvres les yeux. Une odeur de produits d'entretien, un blanc aveuglant..."
    pause 1
    echo
    danger "Tu as déjà vu cette salle. Tape pwd."
}

# Dernière révélation : déclenchée par la première commande tapée dans la boucle (le pwd)
fin_revelation() {
    local n deja suivant
    n="$(etat_get appel)"
    deja=$(( n - 1 ))
    suivant=$(( n + 1 ))
    local VITESSE=0.05

    pause 2
    echo
    mystere "Le chemin ne ment pas. boucle_$n."
    pause 2
    mystere "Tu repenses à l'écran d'appel, la première fois. Il affichait $deja."
    mystere "Tu as cru que c'était ton numéro."
    pause 1
    danger "Ce n'était pas un numéro. C'était un compte."
    pause 2
    echo
    narrer "$deja fois, tu t'es réveillé dans cette salle."
    narrer "$deja fois, tu as compté les chaises, gratté les fenêtres, tué le brouillage."
    narrer "$deja fois, tu as pris le dernier train, et tu as cru être sorti."
    pause 2
    echo
    VITESSE=0.08
    mystere "Il n'y a pas de sortie. Il n'y en a jamais eu."
    mystere "Il n'y a que toi, qui reviens toujours."
    pause 2
    echo
    VITESSE=0.05
    narrer "Tu t'assois sur une chaise orange. Devant toi, un écran s'allume."
    narrer "Tes mains se posent sur le clavier. Elles savent déjà quoi écrire."
    pause 2
    echo
    echo "$MARGE${FOND_GRIS} Nouveau message ─────────────────────────────── ${RESET}"
    echo "${MARGE}À       : ████████@█████"
    echo "${MARGE}Objet   : Error: Ping 404 (run_away.exe)"
    echo
    VITESSE=0.04
    narrer "Je ne sais pas si ce message parviendra à quelqu'un."
    narrer "Mais, si c'est le cas... aidez-moi s'il vous plaît."
    narrer "..."
    narrer "Tu es le seul à qui j'ai pu écrire !"
    pause 1
    echo
    echo "$MARGE$COUL_SUCCES[ Message envoyé ]$RESET"
    pause 3
    glitch
    echo
    VITESSE=0.15
    echo "        ${ROUGE}${GRAS}NUMÉRO APPELÉ : $suivant${RESET}"
    pause 2
    echo
    VITESSE=0.05
    mystere "Quelque part, quelqu'un vient d'ouvrir les yeux."
    mystere "Une odeur de produits d'entretien. Un blanc aveuglant. Un tic d'horloge."
    pause 2
    echo
    echo "${COUL_MYSTERE}${GRAS}"
    cat <<'EOF'
   ██████   ██████  ██    ██  ██████ ██      ███████
   ██   ██ ██    ██ ██    ██ ██      ██      ██
   ██████  ██    ██ ██    ██ ██      ██      █████
   ██   ██ ██    ██ ██    ██ ██      ██      ██
   ██████   ██████   ██████   ██████ ███████ ███████
EOF
    echo "${RESET}"
    echo "$MARGE${COUL_MYSTERE}━━━━━━━━━━━━━━  FIN SECRÈTE  ━━━━━━━━━━━━━━${RESET}"
    echo
    VITESSE=0.08
    mystere "        Ne réponds pas au prochain message."
    echo
    terminer_partie
}
