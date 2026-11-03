# Error: Ping 404 — Solution complète

> ⚠ **Spoilers.** Ce document donne la solution de chaque niveau et de la fin secrète. Si tu veux découvrir le jeu par toi-même, arrête-toi ici.

Les codes changent à chaque partie (nombre de chaises, heure, étages manquants, bon billet, bonne voie…). Les valeurs ci-dessous sont des **exemples** : la méthode, elle, reste toujours la même.

Les chemins sont donnés depuis le dossier du jeu, `error_ping_404/`. Après chaque porte réussie, le jeu t'emmène automatiquement dans le niveau suivant.

Ordre conseillé pour tout voir en une partie :

1. Niveau 0, en récupérant la tablette au passage
2. Niveau 1, en récupérant la batterie
3. Niveau 2, en notant le mot de passe de la télé
4. **Fin secrète** (avant de prendre le train)
5. Ou **fin normale** au niveau 3

---

## Niveau 0 — La salle d'attente

**Objectif :** trouver les trois indices cachés d'un ticket déchiré, puis calculer le code de la porte de service.

**Commandes :** `ls`, `ls -a`, `cd`, `cat`, `./`

```bash
cat regarder_autour.txt
cat guide_patient.txt
cat ecran_appel.txt horloge.txt     # numéro appelé (17) et heure figée (ex. 21)

cd chaises
ls                                   # compter les chaises (ex. 11)
ls -a                                # .indice1 apparaît
cat .indice1
cd ..

cd fenetres
cat fenetre*                         # une seule fenêtre cache un chiffre gravé (ex. 6)
cd ..

cd guichet
ls -a                                # .indice2 et le dossier caché .tablette
cat .indice2
cat .tablette/ecran.txt              # pour la fin secrète
cd ..

cd poubelle
ls -a
cat .indice3
cd ..
```

**Le code :** chaises + chiffre de la fenêtre + heure, puis le numéro appelé collé à droite.
Exemple : 11 + 6 + 21 = 38, suivi de 17, soit **3817**.

```bash
./porte_service.sh                   # taper le code
```

---

## Niveau 1 — L'ascenseur

**Objectif :** trouver l'étage « habité », seul dont la porte s'ouvre, puis déduire son code des deux boutons arrachés du panneau.

**Commandes :** `ls -lS`, `head`, `grep`, `ls -a`, `mv`

```bash
cat regarder_autour.txt
cat plaque.txt graffitis.txt

ls -lS etage*/mur.txt | head -3      # le plus gros mur = l'étage habité (ex. etage41)
grep code etage41/mur.txt            # renvoie aux boutons arrachés

ls                                   # deux étages manquent dans la liste (ex. 19 et 73)
```

**Le code :** les deux étages manquants mis bout à bout, du plus petit au plus grand.
Exemple : 19 et 73 donnent **1973**.

**Pour la fin secrète**, avant de passer la porte : la batterie de la tablette est cachée à l'étage du numéro appelé.

```bash
ls -a etage17                        # .batterie
mv etage17/.batterie ../niveau0_salle_attente/guichet/.tablette/
```

Puis :

```bash
cd etage41
./porte_coupe_feu.sh                 # taper le code
```

En cas de blocage, `indices_mode_facile.txt` donne trois indices progressifs.

---

## Niveau 2 — Le couloir

**Objectif :** arrêter l'émetteur qui brouille la télévision, lire le code du coffre à la télé, puis mettre la clé dans la porte du métro.

**Commandes :** `ps aux`, `grep`, `kill`, `mv`

```bash
cat regarder_autour.txt
cat notice_tv.txt
./television.sh                      # de la neige : le signal est brouillé

ps aux | grep brouillage             # ex. 4821 ... niveau2_couloir/chambre230/emetteur_brouillage
kill 4821                            # le PID de ta partie (2e colonne)

./television.sh                      # tirage du soir : 5 2 8 1, et « regarde-toi dans le MIROIR »
./coffre.sh                          # code : 5281 → un fichier cle apparaît

mv cle porte_metro/
cd porte_metro
./ouvrir.sh
```

**Pour la fin secrète :** la ligne en magenta de la télé donne le mot de passe de la tablette, **miroir**. La chambre de l'émetteur (`chambre230/valise.txt` dans l'exemple) le confirme.

---

## Niveau 3 — Le métro

**Objectif :** trouver le billet à ton numéro, le composter, et monter dans le dernier train arrivé.

**Commandes :** `tar`, `grep`, `ls -lt`, `chmod +x`

> Si tu veux voir la fin secrète, fais-la **avant** cette étape : le train termine la partie.

```bash
cat regarder_autour.txt
cat borne_info.txt

tar -xvf objets_trouves.tar          # billetA.sh à billetF.sh
grep 17 billet*                      # le billet au numéro du joueur (ex. billetC.sh)

ls -lt voies/                        # la voie en haut de la liste est la plus récente (ex. voie2)

chmod +x billetC.sh                  # composter le billet
./billetC.sh voie2                   # fin normale
```

Un mauvais billet est refusé, sans finir la partie. Une mauvaise voie mène à la fin ratée.

---

## Fin secrète — La boucle

**Prérequis :** la batterie est dans la tablette (niveau 1), et tu connais le mot de passe (niveau 2).

```bash
cd ~/error_ping_404/niveaux/niveau0_salle_attente/guichet/.tablette
./allumer.sh                         # mot de passe : miroir → la tablette affiche E T I R E V

cd ~/error_ping_404/niveaux/niveau1_ascenseur
./bouton_sans_numero.sh              # mot : verite (ETIREV lu à l'envers) → .etage404

cat regarder_autour.txt
chmod +x verite.sh
./verite.sh
pwd                                  # .../boucle_18/... : la révélation finale se déclenche
```

---

## Les trois fins

| Fin | Comment l'obtenir |
| --- | --- |
| **Normale** | Le bon billet, sur la bonne voie, au niveau 3 |
| **Ratée** | Une mauvaise voie au niveau 3, ou le temps écoulé (30 minutes) |
| **Secrète** | La tablette, la batterie, le mot de passe, puis le bouton sans numéro et `verite.sh` |

---

## Pour une démonstration

`./lancer.sh --niveau 2` démarre directement au couloir, avec les niveaux précédents déjà ouverts : la batterie est encore à l'étage 17 et la tablette dans le guichet. Ça permet de montrer `ps aux` et `kill`, le métro, puis la fin secrète, en quelques minutes.
