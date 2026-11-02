#!/usr/bin/env bash
# Error Ping 404 — les fins : normale, ratée, secrète.

fin_normale() {
    local reste; reste="$(temps_formate)"
    echo
    ecrire "Les portes se ferment. Le train démarre dans le noir." "$BLANC"
    ecrire "Les néons défilent, de plus en plus vite, puis plus rien." "$BLANC"
    pause 1
    glitch
    clear
    echo "${VERT}${GRAS}"
    cat <<'EOF'
   ███████  ██████  ██████  ████████ ██
   ██      ██    ██ ██   ██    ██    ██
   ███████ ██    ██ ██████     ██    ██
        ██ ██    ██ ██   ██    ██    ██
   ███████  ██████  ██   ██    ██    ██
EOF
    echo "${RESET}"
    ecrire "Tu te réveilles devant ton écran. Tout est normal." "$BLANC"
    pause 1
    ecrire "Une notification apparaît : Nouveau message (1)." "$GRIS"
    echo
    echo "Temps restant : ${VERT}$reste${RESET}"
    echo "${GRIS}(Fin normale. Certains secrets n'ont pas été découverts...)${RESET}"
    terminer_partie
}

fin_ratee() {
    echo
    [ "$1" = "temps" ] && ecrire "Le bourdonnement s'arrête. Le silence est pire." "$GRIS"
    [ "$1" = "train" ] && ecrire "Le train ne démarre pas. Les portes se ferment derrière toi." "$BLANC"
    ecrire "Les néons se rallument." "$BLANC"
    pause 1
    glitch
    clear
    ecrire "Une salle d'attente d'un blanc aveuglant." "$BLANC"
    echo
    echo "        ${ROUGE}${GRAS}NUMÉRO APPELÉ : $(( $(etat_get appel) + 1 ))${RESET}"
    echo
    echo "${ROUGE}(Fin ratée. Relance ./lancer.sh pour retenter ta chance.)${RESET}"
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
    clear
    pause 2
    ecrire "lecture : enregistrement_retrouve.mp4" "$GRIS"
    echo
    pause 1
    ecrire "Une caméra posée sur une chaise orange." "$GRIS"
    ecrire "Quelqu'un s'assoit face à l'objectif. Il a ton visage." "$GRIS"
    ecrire "Il a l'air fatigué." "$GRIS"
    echo
    pause 1
    ecrire "  « Si tu regardes ça, c'est que ça a recommencé." "$BLANC"
    ecrire "    Le message, c'est moi qui l'ai envoyé. Je n'avais pas le choix." "$BLANC"
    ecrire "    Il fallait que quelqu'un vienne, et il n'y a que moi qui viens toujours." "$BLANC"
    ecrire "    Je t'ai laissé la tablette. Je t'ai laissé la batterie." "$BLANC"
    ecrire "    J'espère que cette fois, tu vas comprendre avant de prendre le train." "$BLANC"
    ecrire "    Ne réponds pas au prochain message. »" "$BLANC"
    echo
    pause 2
    echo "${FOND_GRIS}${BLANC} Boîte de réception (1) ${RESET}"
    echo "De      : ${ROUGE}${GRAS}$utilisateur@$machine${RESET}"
    echo "Objet   : aide"
    echo "Envoyé  : dans 3 minutes"
    pause 3
    glitch
    clear
    pause 2

    # La boucle recommence : nouvelle salle d'attente, numéro suivant
    arreter_brouillage
    ancien="$(etat_get appel)"
    nouveau=$(( ancien + 1 ))
    base="$JEU_ROOT/monde/boucle_$nouveau"
    rm -rf "$base"
    etat_set appel "$nouveau"
    etat_set base "$base"
    etat_set tablette 0
    etat_set niveau 0
    etat_set debut "$(date +%s)"
    generer_niveau0 "$base"
    etat_set aller "$base/salle_attente"

    ecrire "Tu ouvres les yeux. Une odeur de produits d'entretien, un blanc aveuglant..." "$GRIS"
    pause 1
    echo
    echo "${ROUGE}${GRAS}Tu as déjà vu cette salle. Tape pwd.${RESET}"
}
