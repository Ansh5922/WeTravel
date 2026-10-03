const { WebSocketServer } = require('ws');
const { URL } = require('url');
const prisma = require('../repositories/prisma.client');
const { verifyWsToken, broadcast, handleMessage } = require('./ws.handler');

const rooms = new Map();

// Attach WebSocket server to HTTP server and manage authentication and room lifecycle
const attachWsServer = (httpServer) => {
  const wss = new WebSocketServer({ noServer: true });

  httpServer.on('upgrade', async (req, socket, head) => {
    try {
      const reqUrl = new URL(req.url, `http://${req.headers.host}`);
      const token  = reqUrl.searchParams.get('token');
      const tripId = reqUrl.searchParams.get('tripId');

      if (!token || !tripId) {
        socket.write('HTTP/1.1 400 Bad Request\r\n\r\n');
        socket.destroy();
        return;
      }

      let decoded;
      try {
        decoded = verifyWsToken(token);
      } catch {
        socket.write('HTTP/1.1 401 Unauthorized\r\n\r\n');
        socket.destroy();
        return;
      }

      const userId = decoded.sub || decoded.id;

      const [member, user] = await Promise.all([
        prisma.groupMember.findFirst({ where: { groupId: tripId, userId } }),
        prisma.user.findUnique({ where: { id: userId }, select: { id: true, fullName: true, username: true } }),
      ]);

      if (!member || !user) {
        socket.write('HTTP/1.1 403 Forbidden\r\n\r\n');
        socket.destroy();
        return;
      }

      wss.handleUpgrade(req, socket, head, (ws) => {
        wss.emit('connection', ws, { tripId, user });
      });
    } catch (err) {
      console.error('[WS] Upgrade error:', err.message);
      socket.destroy();
    }
  });

  wss.on('connection', (ws, { tripId, user }) => {
    console.log(`🔌 [WS] ${user.fullName} joined trip room: ${tripId}`);

    if (!rooms.has(tripId)) rooms.set(tripId, new Set());
    rooms.get(tripId).add(ws);

    broadcast(rooms, tripId, {
      type: 'member_joined',
      userId: user.id,
      fullName: user.fullName,
    }, ws);

    ws.send(JSON.stringify({
      type: 'connected',
      message: `Welcome to the trip chat, ${user.fullName}!`,
      tripId,
      onlineCount: rooms.get(tripId)?.size || 1,
    }));

    ws.on('message', (rawData) => {
      handleMessage(ws, rawData, { rooms, tripId, user }).catch((err) => {
        console.error('[WS] Handler error:', err.message);
        ws.send(JSON.stringify({ type: 'error', message: 'An error occurred processing your message.' }));
      });
    });

    ws.on('close', () => {
      const room = rooms.get(tripId);
      if (room) {
        room.delete(ws);
        if (room.size === 0) rooms.delete(tripId);
      }
      broadcast(rooms, tripId, {
        type: 'member_left',
        userId: user.id,
        fullName: user.fullName,
      });
      console.log(`❌ [WS] ${user.fullName} left trip room: ${tripId}`);
    });

    ws.on('error', (err) => {
      console.error(`[WS] Client error for ${user.fullName}:`, err.message);
    });
  });

  console.log('🔗 [WS] WebSocket server attached and ready.');
  return wss;
};

module.exports = { attachWsServer, rooms };
