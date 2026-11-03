# Error: Ping 404

*Un escape game en terminal, écrit en pur bash, pour apprendre les commandes Unix en jouant.*

## Synopsis

Un soir, un mail étrange arrive dans ta boîte : quelqu'un est retenu quelque part et appelle à l'aide. Il a réussi à partager sa position. Tu cliques sur le lien.

L'écran se brouille. Quand tu rouvres les yeux, tu es assis dans une salle d'attente d'un blanc aveuglant. Les chaises sont vides, les fenêtres sont peintes, et l'horloge revient toujours sur la même heure.

Pour t'en sortir, il faudra traverser quatre lieux qui ne devraient pas exister, avant la fin du compte à rebours. Et peut-être comprendre qui t'a fait venir ici.

## Le principe

Chaque lieu est un dossier, chaque objet est un fichier. Pour avancer, tu fouilles, tu lis, tu déplaces et tu exécutes avec les commandes du terminal. Chaque niveau fait découvrir une nouvelle famille de commandes, et les lieux eux-mêmes (guide affiché, graffitis, notice, borne d'information) te mettent sur la piste sans donner la solution.

| Niveau | Lieu | Ce que tu y pratiques |
| --- | --- | --- |
| 0 | La salle d'attente | se déplacer, lire, trouver les fichiers cachés : `ls`, `ls -a`, `cd`, `cat`, `./` |
| 1 | L'ascenseur | trier et filtrer : `ls -l`, `ls -S`, `head`, `grep`, déplacer avec `mv` |
| 2 | Le couloir | les processus : `ps aux`, `grep`, `kill` |
| 3 | Le métro | archives, dates et droits : `tar`, `grep`, `ls -lt`, `chmod +x` |

Une partie dure **30 minutes**. Le temps restant et le lieu où tu te trouves s'affichent en permanence au-dessus de la ligne de commande. Les codes changent à chaque partie.

Il existe **trois fins** : une fin normale, une mauvaise fin… et une vraie fin, pour ceux qui fouillent vraiment partout.

## Prérequis

- Un système Linux (ou macOS) avec **bash 4 ou plus**
- Les outils standards, présents sur presque toutes les distributions : `ps`, `tar`, `sha256sum`
- Rien à installer, ni `sudo`, ni connexion internet pendant la partie

## Installation

```bash
git clone https://github.com/tbenoit7/error-ping-404
cd error-ping-404/
```

## Jouer

```bash
./lancer.sh
```

- Lis le mail, puis appuie sur **Entrée**.
- Commence toujours par regarder autour de toi : `ls` et `cat regarder_autour.txt`.
- Quand tu réussis un niveau, tu es directement emmené au suivant.
- `exit` arrête la partie en cours.

| Commande | Effet |
| --- | --- |
| `./lancer.sh` | Nouvelle partie (le monde est régénéré à chaque fois) |
| `./lancer.sh --niveau 2` | Mode démo : démarre directement au niveau 2, les précédents déjà ouverts |
| `./reinitialiser.sh` | Efface les niveaux générés et l'état de la partie |

Pendant la partie, le terminal passe en fond noir. Ses couleurs d'origine reviennent à la fin.

## Solution

Bloqué ? La solution complète, niveau par niveau et fin secrète comprise, se trouve dans [SOLUTION.md](SOLUTION.md). Attention, spoilers.

## Structure du projet

```
error_ping_404/
├── lancer.sh          lancement, intro, shell de jeu
├── reinitialiser.sh   remise à zéro
├── SOLUTION.md        solution complète (spoilers)
└── lib/
    ├── etat.sh        état de la partie, compte à rebours, vérification des codes
    ├── effets.sh      couleurs, effet machine à écrire, glitch
    ├── niveaux.sh     génération des quatre niveaux
    ├── action.sh      portes, télévision, coffre, tablette, billets…
    ├── fins.sh        les fins
    └── shellrc.sh     prompt et compte à rebours du shell de jeu
```

Chaque niveau n'est généré qu'une fois le précédent réussi, et les codes sont vérifiés par empreinte `sha256sum` : ils ne sont jamais écrits en clair.

## Contexte

Projet réalisé dans le cadre du cours de Passeport Informatique, en 3e année de Télécommunications à l'INSA Lyon. Il s'inspire de *Keep Talking and Nobody Explodes — UNIX version*, utilisé en cours pour découvrir le terminal, et surtout de l'histoire des Backrooms pour la narration.

Auteur : Tamatoa BENOIT (assisted by Claude.ai)