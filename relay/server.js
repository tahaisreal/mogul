/* ============================================================
   MOGUL — relay server

   A message bus, nothing more. It never sees a dice roll or a rule:
   the first client in a room is the host and runs the whole game in
   their browser. This exists purely so people whose network blocks
   WebRTC can still play.

   Deploy anywhere that runs Node and speaks WebSocket.
   ============================================================ */

const http = require('http');
const { WebSocketServer } = require('ws');

const PORT = process.env.PORT || 8080;
const rooms = new Map();   // code -> { host: id, clients: Map<id, ws> }
let nextId = 1;

const server = http.createServer((req, res) => {
  // a plain health check, handy for uptime pings on free hosting
  res.writeHead(200, { 'Content-Type': 'text/plain', 'Access-Control-Allow-Origin': '*' });
  res.end(`mogul relay ok — ${rooms.size} room(s)\n`);
});

const wss = new WebSocketServer({ server });

function send(ws, obj) {
  if (ws && ws.readyState === 1) ws.send(JSON.stringify(obj));
}

wss.on('connection', (ws) => {
  const id = 'c' + (nextId++);
  let room = null, code = null, role = null;

  ws.isAlive = true;
  ws.on('pong', () => { ws.isAlive = true; });

  ws.on('message', (raw) => {
    let msg;
    try { msg = JSON.parse(raw); } catch (e) { return; }

    if (msg.t === 'join') {
      code = String(msg.room || '').toUpperCase().slice(0, 8);
      role = msg.role === 'host' ? 'host' : 'guest';
      if (!code) return send(ws, { t: 'error', reason: 'missing room code' });

      if (!rooms.has(code)) rooms.set(code, { host: null, clients: new Map() });
      room = rooms.get(code);

      if (role === 'host') {
        if (room.host && room.clients.has(room.host)) {
          return send(ws, { t: 'error', reason: 'that room code is already hosted' });
        }
        room.host = id;
      }
      room.clients.set(id, ws);

      send(ws, { t: 'welcome', id, host: room.host, room: code });
      if (role === 'guest' && room.host) send(room.clients.get(room.host), { t: 'peer', id });
      console.log(`[${code}] ${role} ${id} joined (${room.clients.size} in room)`);
      return;
    }

    if (!room) return;

    // forward verbatim: the relay has no opinion about the payload
    if (msg.t === 'to') {
      const target = room.clients.get(msg.id);
      if (target) send(target, { t: 'from', id, data: msg.data });
      return;
    }
    if (msg.t === 'all') {
      room.clients.forEach((client, cid) => {
        if (cid !== id) send(client, { t: 'from', id, data: msg.data });
      });
    }
  });

  ws.on('close', () => {
    if (!room) return;
    room.clients.delete(id);
    room.clients.forEach(client => send(client, { t: 'gone', id }));
    if (room.host === id) room.host = null;
    if (room.clients.size === 0) { rooms.delete(code); console.log(`[${code}] room closed`); }
  });
});

/* free hosting tends to kill idle sockets; a ping keeps them alive */
setInterval(() => {
  wss.clients.forEach(ws => {
    if (ws.isAlive === false) return ws.terminate();
    ws.isAlive = false;
    try { ws.ping(); } catch (e) {}
  });
}, 25000);

server.listen(PORT, () => console.log('MOGUL relay listening on ' + PORT));
