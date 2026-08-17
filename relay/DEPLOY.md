# Serveur relais MOGUL

À utiliser **seulement** si le pair-à-pair ne passe pas chez toi ou tes potes.
Le relais ne fait que transmettre des messages : c'est toujours le navigateur
de l'hôte qui applique les règles. Il ne voit jamais un lancer de dés.

## Déployer sur Render (gratuit, 5 min)

1. Crée un dépôt GitHub avec **uniquement** `server.js` et `package.json`
   (ceux de ce dossier). Appelle-le par exemple `mogul-relay`.
2. Va sur render.com → **New** → **Web Service** → connecte ce dépôt.
3. Réglages :
   - Runtime : **Node**
   - Build command : `npm install`
   - Start command : `npm start`
   - Instance type : **Free**
4. Déploie. Render te donne une adresse en `https://mogul-relay-xxxx.onrender.com`.
5. Vérifie en l'ouvrant dans le navigateur : ça doit afficher `mogul relay ok`.

## Le brancher dans le jeu

Dans MOGUL, avant de créer une room : **⚙ Use a relay server**, et colle
l'adresse en remplaçant `https://` par `wss://` :

```
wss://mogul-relay-xxxx.onrender.com
```

Le `wss://` est obligatoire — `https://` ne marchera pas, c'est un protocole
différent. Clique **Save relay**, puis **Create an online room**.

Le lien d'invitation contiendra alors automatiquement l'adresse du relais :
tes potes n'ont rien à configurer, ils cliquent et ça marche.

## À savoir sur l'offre gratuite

Render met le service en veille après 15 minutes sans trafic. Le premier
joueur qui se connecte après une pause attendra 30 à 60 secondes le temps du
réveil. Ouvre l'adresse dans un onglet une minute avant de jouer pour éviter ça.

## Alternatives

Le même dossier fonctionne tel quel sur Fly.io, Railway, Koyeb, ou n'importe
quel VPS. Le serveur écoute sur `process.env.PORT`, ce que tous ces hébergeurs
fournissent automatiquement.

## Tester en local

```bash
npm install
npm start
```

Puis dans le jeu, relais = `ws://localhost:8080` (un seul `s` en moins : en
local il n'y a pas de TLS).
