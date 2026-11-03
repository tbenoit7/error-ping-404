# Error Ping 404

Escape game en terminal, en pur bash. On reçoit un appel à l'aide, on clique sur le lien… et on se réveille dans une salle d'attente vide. Pour sortir, il faut traverser 4 lieux en utilisant les commandes du cours, avant la fin du compte à rebours.

## Installer et lancer

```
cd ~
git clone https://github.com/<pseudo>/error_ping_404.git
cd error_ping_404
./lancer.sh
```

Le jeu doit être cloné sur une partition Linux (le dossier personnel `~` convient). Une partition FAT/NTFS, comme celle d'une clé USB de stockage, ne gère pas `chmod +x`, dont le jeu a besoin.

Prérequis : bash 4 ou plus, et les outils standards (`ps`, `tar`, `sha256sum`). Rien à installer, ni `sudo` ni internet pendant la partie.

Options :

| Option | Effet |
| --- | --- |
| `--niveau 2` | Mode démo : niveaux 0 à 2 déjà ouverts, départ au niveau 2 |

`./reinitialiser.sh` efface les niveaux générés. Pour quitter une partie en cours : `exit`.

## Les lieux et les commandes

| Niveau | Lieu | Commandes |
| --- | --- | --- |
| 0 | La salle d'attente | `ls`, `ls -a`, `cd`, `cat`, `./` |
| 1 | L'ascenseur | `ls -lS`, `head`, `grep`, `ls -a`, `mv` |
| 2 | Le couloir | `ps aux`, `grep`, `kill`, `mv` |
| 3 | Le métro | `tar`, `grep`, `ls -lt`, `chmod +x` |

Trois fins : normale, ratée (temps écoulé ou mauvais train) et secrète.

## Fonctionnement

- Les niveaux sont générés au fur et à mesure : le niveau suivant n'existe pas tant que le précédent n'est pas résolu.
- Les codes changent à chaque partie (nombre de chaises, heure de lancement, étages manquants, bon billet, bonne voie).
- Les codes sont vérifiés par empreinte `sha256sum`, jamais stockés en clair.
- Le jeu ouvre un shell bash dont le prompt affiche le lieu et le temps restant.
- Aucune commande ne demande `sudo` ni internet.

```
lancer.sh / reinitialiser.sh
lib/etat.sh      état de la partie, timer, vérification des codes
lib/effets.sh    couleurs, machine à écrire, glitch
lib/niveaux.sh   génération des 4 niveaux
lib/action.sh    portes, télévision, coffre, billets, tablette, bouton
lib/fins.sh      les trois fins
lib/shellrc.sh   prompt et timer du shell de jeu
```
