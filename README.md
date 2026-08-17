# MOGUL

Jeu de plateau web, en 3D ou à plat. Un seul fichier : `index.html`.

---

## 1. Mettre en ligne (une fois, 5 min)

```bash
mkdir mogul && cd mogul
# copie index.html ici (et relay/ si tu veux le garder sous la main)
git init
git add .
git commit -m "MOGUL"
git branch -M main
git remote add origin https://github.com/TON_PSEUDO/mogul.git
git push -u origin main
```

Sur GitHub : **Settings → Pages → Source: Deploy from a branch → main / (root) → Save**.

Une minute après, c'est en ligne sur `https://TON_PSEUDO.github.io/mogul/`.

Mise à jour plus tard : `git add index.html && git commit -m "maj" && git push`.

GitHub Pages ne sert que `index.html` ; le dossier `relay/` peut rester dans le
même dépôt sans rien casser, Pages l'ignore.

## 2. Lancer une partie

1. Tu ouvres `https://TON_PSEUDO.github.io/mogul/`
2. **Create an online room** → un lien apparaît, genre `.../mogul/?b=e#K7M2QX8T3N94`
3. Tu l'envoies. Chacun met son pseudo et clique **Join**. Rien d'autre à faire :
   pas de compte, pas d'installation, pas de réglage.
4. Quand tout le monde est là : **Start game**.

Le code de la room reste affiché en haut à gauche pendant la partie, avec un
bouton pour recopier le lien — pratique pour un retardataire.

Testé de 2 à 8 joueurs. Le maximum se règle dans les réglages avant de lancer.

### Si un pote reste bloqué

Les rooms passent par un canal public : un simple WebSocket, comme n'importe
quel site. Rien à installer, rien à régler, et ça marche même là où WebRTC est
bloqué (VPN d'Opera ou de Brave, proxy d'entreprise).

Si personne n'arrive à ouvrir de room, c'est que les deux brokers publics sont
injoignables — vérifie ta connexion et réessaie. Le jeu bascule alors tout seul
en pair-à-pair, et propose **Join over the shared link instead** dans l'autre
sens si le pair-à-pair coince.

Le bouton **Run a connection test** reste là pour diagnostiquer WebRTC.

### Deux détails sur le lien

Le lien contient une clé de 12 caractères : les 5 premiers sont le nom de la
room affiché à l'écran, les 7 autres la rendent indevinable. Les brokers sont
publics et un canal se devine, pas une clé de 12 caractères. Envoie le lien
entier, pas seulement le code.

Si tu préfères ne pas partager un broker public, le dossier `relay/` contient
un petit serveur à héberger toi-même (voir `relay/DEPLOY.md`). Une fois son
adresse collée dans **⚙ Use a relay server**, le lien d'invitation l'embarque.

### Deux choses à savoir

- **Garde ton onglet ouvert.** C'est ton navigateur qui fait tourner la partie
  et arbitre les règles. Si tu fermes, la partie s'arrête.
- **Déconnexion :** rouvrir le lien **depuis le même navigateur** récupère la
  place, l'argent et les propriétés. C'est le navigateur qui identifie le
  siège, pas le pseudo : une clé aléatoire est rangée dans ton stockage local
  à la première partie, envoyée à l'hôte au moment de rejoindre, et jamais
  diffusée aux autres. Taper le pseudo de quelqu'un d'autre ne donne donc plus
  rien — avant, ça donnait sa fortune.

  Revers de la médaille : navigation privée, autre navigateur ou stockage
  effacé = nouveau siège. Et pendant une partie, seuls ceux qui y ont déjà une
  place peuvent rejoindre ; les autres peuvent regarder mais pas jouer.

- **Abandonner :** un bouton *Give up* en bas du panneau des propriétés rend
  tout à la banque — cases libérées, argent effacé — et la partie continue
  sans toi. Deux clics, il n'y a pas de retour en arrière.

Aucun serveur à payer : GitHub Pages ne sert que le fichier, et le canal des
rooms tourne sur des brokers publics gratuits.

---

## L'interface

Tout flotte par-dessus le plateau :

- **Au milieu du plateau** : les dés, à qui le tour, puis le journal des
  actions — le plus récent en haut, les anciens qui s'effacent en descendant
- **En haut à gauche** : la room, les joueurs et leur argent
- **En bas à droite** : tes propriétés, avec construire / vendre / hypothéquer
  — le titre du panneau se clique pour le replier quand il gêne le plateau
- **En bas à gauche** : le chat, en ligne uniquement
- **En bas au centre** : lancer, échanger, couper le son, changer de vue
- **Par-dessus le journal** : toute décision à prendre (acheter, enchérir,
  régler une dette)

Sur le plateau à plat, la barre du bas flotte *à l'intérieur* de l'anneau,
là où seraient les dés sur une vraie table : le plateau prend alors toute la
hauteur de la fenêtre au lieu de s'arrêter au-dessus de la barre.

Survoler un joueur assombrit le plateau sauf ses propriétés. Survoler une case
allume son pays sans assombrir. Cliquer une case fait clignoter sa ligne dans
le panneau de droite.

Dans le journal, le mot **trade** en ambre est survolable : il rouvre les
termes exacts de l'échange, même longtemps après.

## Le plateau

**48 cases** : 11 par côté plus les quatre coins. Dix pays — Brésil, Maroc,
Inde, Italie, Allemagne, Chine, France, Japon, Royaume-Uni, États-Unis — quatre
aéroports et trois compagnies (électricité, gaz, eau).

Le Maroc, ce sont Casablanca, Marrakech et Rabat, avec l'aéroport CMN juste à
côté.

Le pays est un dégradé doux qui entre par le bord extérieur et meurt avant le
milieu de la case. **La seule couleur franche du plateau, c'est un titre de
propriété** : dès que quelqu'un achète, une barre nette de sa couleur apparaît
sur le bord extérieur. Tant que la case est libre, il n'y a qu'une teinte.

Une propriété hypothéquée devient grise, se hachure, et affiche MORTGAGED sur
sa barre de propriétaire.

Rien dans le code ne compte les cases à la main : la taille de l'anneau est
déduite des données (`TILES`, `PER_SIDE`, `CORNER_AT`), donc changer la carte
ne demande pas de retoucher le moteur ni les deux plateaux.

## Les enchères en direct

Réglage **Auction**. Quand quelqu'un refuse d'acheter, la case part aux
enchères : **3 secondes au compteur, et chaque relance les remet à zéro**.
Tout le monde peut relancer en même temps, de +2$, +10$, +50$ ou +100$ — pas
de tour de parole. Quand le compteur tombe à zéro, la meilleure offre emporte
la case et paie ; si personne n'a relancé, la case reste libre.

L'horloge qui compte est celle de l'hôte : les autres écrans affichent leur
propre décompte pour rester fluides, mais une seule machine peut conclure une
vente. Une relance envoyée juste au buzzer passe encore (400 ms de marge pour
le réseau).

## Négocier au lieu de refuser

Sur une offre reçue, à côté d'**Accepter** et **Refuser**, il y a
**⇄ Counter** : ça rouvre le constructeur d'échange avec l'offre inversée,
déjà remplie. Tu changes ce que tu veux, tu renvoies — l'offre d'origine est
retirée au passage, donc une seule proposition reste sur la table à la fois.

## Deux vues, un seul plateau

Bouton **🀫 Flat board** / **🧊 3D board** en bas au centre :

- **3D** — le plateau posé sur une table, en volume.
- **2D** — le plateau à plat, comme sur richup.io : plus lisible, et ça tourne
  sans carte graphique.

Le choix est mémorisé. Les deux vues répondent aux mêmes appels et une seule
est montée à la fois — survol, surbrillance et déplacements n'ont jamais deux
propriétaires. Chacun choisit la sienne : ça n'a aucun effet sur la partie, tu
peux être en 3D pendant que tes potes sont à plat.

Et si la 3D ne démarre pas (accélération matérielle coupée), le jeu bascule
tout seul sur le plateau à plat au lieu d'afficher une erreur.

## Le mode équipes

Réglage de room, **désactivé par défaut** : coche **Teams** dans les réglages
avant de lancer. Chacun crée une équipe ou rejoint une équipe existante, avec
son nom et son emoji. Deux équipes, trois, ou une bande contre un loup
solitaire — un joueur sans équipe est un camp à lui tout seul. **Une fois la
partie lancée, les alliances sont figées** : le moteur refuse tout changement
d'équipe hors du lobby.

Ce que ça change sur le plateau :

- **Pas de loyer entre coéquipiers.** Tu tombes sur l'hôtel de ton pote, tu
  repars sans payer.
- **Vos propriétés se cumulent.** Pays, aéroports et compagnies comptent
  ensemble : un pays réparti entre deux alliés est quand même un monopole, et
  le loyer double comme tel. Chacun construit sur ses propres cases.
- **Un coéquipier qui saute lègue tout** — cases, maisons et argent — à un
  allié encore en vie, avant même le créancier.
- **La dernière équipe debout gagne**, ensemble.

En ligne, un onglet **chat d'équipe** apparaît à côté du chat général pour
comploter tranquillement. À savoir : le canal d'équipe est masqué à l'écran des
autres, mais c'est le navigateur de l'hôte qui fait tourner la partie et détient
tout l'état — c'est de la discrétion, pas du chiffrement. Si l'hôte joue contre
toi, écris tes plans ailleurs.

Autour d'un seul écran, il n'y a personne à cacher : chaque siège s'assigne à
la main avec les boutons **+ Pseudo** de chaque équipe.

## Les apparences

Cinq formes de pion : la boule classique, un citron, une fraise, une flamme et
un tourbillon. Chacune existe en vraie géométrie 3D sur le plateau, en pion à
plat sur le plateau 2D, et en icône assortie dans le lobby — les trois montrent
toujours la même chose. Couleur et forme se choisissent séparément.

## Le son

Dés, déplacements, achats, argent, cartes, constructions, échanges. Tout est
synthétisé à la volée, aucun fichier audio. Bouton **Sound** pour couper, le
choix est mémorisé.

## Debug

Console du navigateur :

- `MOGUL.S` — l'état complet de la partie
- `MOGUL.S.log` — le journal, avec le détail des échanges
- `MOGUL.act({type:'roll'})` — déclencher une action à la main
- `MOGUL.Board3D.Layout` — la géométrie du plateau
- `MOGUL.setView('2d')` — changer de vue à la main
- `MOGUL.Board` — la vue actuellement montée
- `MOGUL.S.teams` — les équipes, `MOGUL.S.chat` — les messages
