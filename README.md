# MOGUL

Jeu de plateau web en 3D. Un seul fichier : `index.html`.

---

## 1. Mettre en ligne (une fois, 5 min)

```bash
mkdir mogul && cd mogul
# copie index.html ici
git init
git add index.html
git commit -m "MOGUL"
git branch -M main
git remote add origin https://github.com/TON_PSEUDO/mogul.git
git push -u origin main
```

Sur GitHub : **Settings → Pages → Source: Deploy from a branch → main / (root) → Save**.

Une minute après, c'est en ligne sur `https://TON_PSEUDO.github.io/mogul/`.

Mise à jour plus tard : `git add index.html && git commit -m "maj" && git push`.

## 2. Lancer une partie

1. Tu ouvres `https://TON_PSEUDO.github.io/mogul/`
2. **Create an online room** → un lien apparaît, genre `.../mogul/#K7M2Q`
3. Tu l'envoies. Chacun met son pseudo et clique **Join**.
4. Quand tout le monde est là : **Start game**.

Le code de la room reste affiché en haut à gauche pendant la partie, avec un
bouton pour recopier le lien — pratique pour un retardataire.

Testé de 2 à 8 joueurs. Le maximum se règle dans les réglages avant de lancer.

### Si un pote reste bloqué sur "Connecting…"

Après 14 secondes, le jeu arrête d'attendre et explique ce qui cloche. Il y a
aussi un bouton **Run a connection test** qui répond en clair :

- `WebRTC no` → le navigateur ne sait pas faire de pair-à-pair
- `local candidates 0` → **quelque chose bloque WebRTC**. C'est presque
  toujours le VPN intégré du navigateur (Opera, Brave) ou une extension de
  confidentialité. Coupe-le pour cette page et recharge.
- `public 0` mais `local` > 0 → les serveurs STUN sont injoignables (VPN ou
  pare-feu strict). Vos potes sur le même wifi passeront, les autres non.
- tout à zéro sauf WebRTC → la room n'est plus ouverte, l'hôte a fermé l'onglet

Le compteur **"N guests connected"** côté hôte permet de distinguer un pote qui
n'a jamais atteint la room d'un pote bloqué plus loin.

Si deux personnes n'arrivent jamais à se connecter alors que le test est bon
des deux côtés, c'est un NAT symétrique : il faut un serveur TURN. L'endroit
où mettre ses identifiants est marqué en commentaire dans le fichier, cherche
`turn:YOUR_HOST`.

### Deux choses à savoir

- **Garde ton onglet ouvert.** C'est ton navigateur qui fait tourner la partie
  et arbitre les règles. Si tu fermes, la partie s'arrête.
- **Déconnexion :** rouvrir le lien avec *exactement* le même pseudo récupère
  la place, l'argent et les propriétés.

Aucun serveur à payer : la connexion est en pair-à-pair (WebRTC), GitHub Pages
ne sert que le fichier.

---

## L'interface

Tout flotte par-dessus la 3D :

- **En haut à gauche** : la room, les joueurs et leur argent
- **En haut à droite** : tes propriétés, avec construire / vendre / hypothéquer
- **En bas à gauche** : le journal des actions
- **En bas au centre** : à qui le tour, le dé, les échanges, le son
- **Au milieu** : toute décision à prendre (acheter, enchérir, régler une dette)

Survoler un joueur assombrit le plateau sauf ses propriétés. Survoler une case
allume son pays sans assombrir. Cliquer une case fait clignoter sa ligne dans
le panneau de droite.

Dans le journal, le mot **trade** en ambre est survolable : il rouvre les
termes exacts de l'échange, même longtemps après.

## Le plateau

Sur chaque case, la couleur du pays est sur le bord extérieur et la couleur du
propriétaire sur le bord intérieur — aux deux extrémités opposées, pour qu'un
orange de pays ne se confonde jamais avec un rouge de joueur.

Une propriété hypothéquée devient grise, se hachure, et affiche MORTGAGED sur
sa barre de propriétaire.

## Le son

Dés, déplacements, achats, argent, cartes, constructions, échanges. Tout est
synthétisé à la volée, aucun fichier audio. Bouton **Sound** pour couper, le
choix est mémorisé.

## Si la 3D ne démarre pas

Le jeu affiche un message clair au lieu d'une page vide. C'est presque toujours
l'accélération matérielle désactivée dans le navigateur.

## Debug

Console du navigateur :

- `MOGUL.S` — l'état complet de la partie
- `MOGUL.S.log` — le journal, avec le détail des échanges
- `MOGUL.act({type:'roll'})` — déclencher une action à la main
- `MOGUL.Board3D.Layout` — la géométrie du plateau
