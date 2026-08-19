# MOGUL

Jeu de plateau web. Un seul fichier : `index.html`.

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

### À huit qui écrivent en même temps

L'hôte n'envoie plus toute la partie à chaque fois que quelqu'un fait quelque
chose. Il compare son état morceau par morceau et n'envoie que ce qui a
vraiment bougé : une ligne de chat pèse une ligne de chat, pas les 48 cases,
les 8 sièges, le journal et le paquet de cartes. Le journal et le chat, qui
s'allongent au lieu de changer, partent en « ce qui vient de s'ajouter ». Sur
une partie bien avancée, ça fait **~95 % de trafic en moins**, et 99 % pour un
message de chat.

Côté écran, tout ce qui arrive dans la même image est dessiné une seule fois :
128 messages envoyés à la volée, c'est douze redessins au lieu de cent
vingt-huit.

Chaque envoi porte un numéro. Si un navigateur en rate un — coupure, wifi
d'hôtel — il le voit tout de suite et redemande la partie entière au lieu de
continuer sur un plateau à moitié faux.

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

Survoler un joueur assombrit le plateau sauf ses propriétés, et survoler un
pays dans le panneau de droite allume ses cases sans assombrir le reste.
Survoler une case du plateau, en revanche, ne l'allume pas : elle prend un
simple filet clair, et c'est le titre de propriété qui s'ouvre au-dessus qui
répond vraiment. Cliquer une case fait clignoter sa ligne dans le panneau.

Dans le journal, le mot **trade** en ambre est survolable : il rouvre les
termes exacts de l'échange, même longtemps après.

## Le plateau

**48 cases** : 11 par côté plus les quatre coins. Dix pays — Brésil, Maroc,
Inde, Italie, Allemagne, Chine, France, Japon, Royaume-Uni, États-Unis — quatre
aéroports et trois compagnies (électricité, gaz, eau).

Les compagnies s'empilent, comme les aéroports : **×4 les dés** avec une,
**×10** avec deux, **×15** avec les trois. En équipe, elles comptent ensemble —
deux alliés qui en tiennent trois à eux deux facturent au tarif du haut.

La case **Earnings Tax** prend 10 % de ce qu'il y a dans le portefeuille, et
rien d'autre : ni les terrains, ni les maisons. Avant, elle taxait la fortune
entière, ce qui faisait payer des milliers au joueur en tête. La **Premium
Tax**, elle, reste à 75 $ pour tout le monde.

Le Maroc, ce sont Casablanca, Marrakech et Rabat, avec l'aéroport CMN juste à
côté.

Chaque case se lit du bord extérieur vers l'intérieur, toujours dans le même
ordre : **le prix**, puis **le nom**, puis **le drapeau** — une pastille ronde
posée sur le bord intérieur, assez grosse pour reconnaître le pays d'un coup
d'œil depuis l'autre bout de la table.

**La couleur d'une case, c'est son drapeau.** Le même drapeau est repris derrière
la carte, agrandi et flouté jusqu'à n'être plus que ses couleurs — le vert et le
rouge de l'Italie, le blanc et le carmin du Japon — puis éteint avant d'atteindre
le nom. Ça dit à quelle série appartient une case plus vite qu'un aplat, et ça ne
peut pas être confondu avec la couleur d'un joueur. Le lavis est volontairement
sombre : à pleine lumière, la moitié blanche du drapeau italien transformait le
milieu de la carte en page blanche et le nom disparaissait dessus.

Les cases sans pays — aéroports, compagnies, taxes, coffres — portent une icône
**dessinée**, pas un emoji : un emoji est une image différente sur chaque machine,
plusieurs n'existent pas du tout sous Windows, et il n'y en avait pas deux de la
même graisse.

**La seule couleur franche du plateau, c'est un titre de propriété** : dès que
quelqu'un achète, une barre nette de sa couleur apparaît sur le bord extérieur.
Tant que la case est libre, il n'y a qu'une teinte. Quand des maisons sortent,
elles prennent la place du prix — une seule chose par bord.

Aéroports et compagnies ont leur propre fond, bleu, pour se distinguer des
pays sans leur voler leur couleur.

Une propriété hypothéquée devient grise, se hachure, et affiche MORTGAGED sur
sa barre de propriétaire.

Avec le réglage **Vacation cash**, la case **Vacation** garde tout ce que la
banque encaisse jusqu'à ce que quelqu'un tombe dessus. Le montant s'affiche sur
la case elle-même, en vert : une cagnotte qu'on ne voit pas est une cagnotte
pour laquelle personne ne joue. La pastille disparaît une fois la cagnotte
remportée — un « 0 $ » affiché se lirait comme « il n'y a rien à gagner »
plutôt que comme « il n'y a rien ici ».

En prison, on continue de toucher ses loyers. Le réglage **Don't collect rent
while in prison** existe toujours mais arrive décoché : une cellule doit coûter
des tours, pas des revenus. Perdre les deux d'un coup faisait de la prison la
seule case capable de décider une partie à elle seule.

Rien dans le code ne compte les cases à la main : la taille de l'anneau est
déduite des données (`TILES`, `PER_SIDE`, `CORNER_AT`), donc changer la carte
ne demande pas de retoucher le moteur.

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

## Pourquoi le plateau est à plat

À plat, comme sur richup.io : lisible d'un coup d'œil, et ça tourne sans carte
graphique — ni WebGL, ni accélération matérielle, même sur un téléphone.

Il a existé une vue 3D en volume à côté, avec un bouton pour basculer. Personne
ne s'en servait, elle est partie.

## Le mode équipes

Réglage de room, **désactivé par défaut** : coche **Teams** dans les réglages
avant de lancer. Chacun crée une équipe ou rejoint une équipe existante, avec
son nom, son emoji et sa couleur. Deux équipes, trois, ou une bande contre un
loup solitaire — un joueur sans équipe est un camp à lui tout seul. Une
nouvelle équipe prend une couleur libre, jamais celle d'une autre, et la
pastille d'une couleur déjà portée est grisée dans le sélecteur. **Une fois la
partie lancée, les alliances sont figées** : le moteur refuse tout changement
d'équipe hors du lobby.

**Qui touche à quoi.** Celui qui crée l'équipe en est le chef — une couronne 👑
à côté de son nom — et **lui seul** en change le nom, l'emoji et la couleur ;
les autres voient le nom écrit, pas un champ. Avant, n'importe quel membre
pouvait le retaper : à quatre sur le même champ, chaque lettre écrasait celle
du voisin.
Si le chef quitte l'équipe, se fait éjecter ou perd sa connexion, la couronne
passe au membre suivant.

**L'hôte de la room** a un **✕** sur chaque carte d'équipe : il la dissout, et
ses membres repartent chacun de leur côté, sièges et couleurs intacts. C'est
sans retour, alors le bouton demande une fois — il devient *Delete?*, et
redevient ✕ tout seul si on ne confirme pas.

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
un tourbillon. Chacune existe en pion sur le plateau et en icône assortie dans
le lobby — les deux montrent toujours la même chose. Couleur et forme se
choisissent séparément.

## Le son

Dés, déplacements, achats, argent, cartes, constructions, échanges. Tout est
synthétisé à la volée, aucun fichier audio. Bouton **Sound** pour couper, le
choix est mémorisé.

## Debug

Console du navigateur :

- `MOGUL.S` — l'état complet de la partie
- `MOGUL.S.log` — le journal, avec le détail des échanges
- `MOGUL.act({type:'roll'})` — déclencher une action à la main
- `MOGUL.Board` — le plateau monté
- `MOGUL.S.teams` — les équipes, `MOGUL.S.chat` — les messages
