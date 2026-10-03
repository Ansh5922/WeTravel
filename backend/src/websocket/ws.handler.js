const jwt = require('jsonwebtoken');
const chatRepo = require('../repositories/chat.repository');

// Verify JWT token from WebSocket connection query parameter
const verifyWsToken = (token) => {
  return jwt.verify(token, process.env.JWT_SECRET);
};

// Broadcast JSON payload to active clients in a trip room, optionally skipping sender
const broadcast = (rooms, tripId, payload, skipWs = null) => {
  const room = rooms.get(tripId);
  if (!room) return;
  const data = JSON.stringify(payload);
  for (const client of room) {
    if (client !== skipWs && client.readyState === 1) {
      client.send(data);
    }
  }
};

// Handle incoming WebSocket message and route according to type
const handleMessage = async (ws, rawData, { rooms, tripId, user }) => {
  let parsed;
  try {
    parsed = JSON.parse(rawData.toString());
  } catch {
    ws.send(JSON.stringify({ type: 'error', message: 'Invalid JSON.' }));
    return;
  }

  const { type, content, imageUrl, fileName } = parsed;

  switch (type) {
    case 'message': {
      if (!content || !content.trim()) {
        ws.send(JSON.stringify({ type: 'error', message: 'Message content cannot be empty.' }));
        return;
      }
      const saved = await chatRepo.saveMessage({
        groupId: tripId,
        senderId: user.id,
        messageType: 'text',
        content: content.trim(),
      });
      broadcast(rooms, tripId, {
        type: 'message',
        id: saved.id,
        sender: { id: user.id, fullName: user.fullName, username: user.username },
        content: saved.content,
        createdAt: saved.createdAt,
      });
      break;
    }

    case 'image': {
      if (!imageUrl) {
        ws.send(JSON.stringify({ type: 'error', message: 'imageUrl is required for image messages.' }));
        return;
      }
      const saved = await chatRepo.saveMessage({
        groupId: tripId,
        senderId: user.id,
        messageType: 'image',
        content: fileName || 'Image',
        imageUrl,
      });
      broadcast(rooms, tripId, {
        type: 'image',
        id: saved.id,
        sender: { id: user.id, fullName: user.fullName, username: user.username },
        imageUrl: saved.imageUrl,
        fileName: saved.content,
        createdAt: saved.createdAt,
      });
      break;
    }

    case 'typing': {
      broadcast(rooms, tripId, {
        type: 'typing',
        userId: user.id,
        fullName: user.fullName,
      }, ws);
      break;
    }

    default:
      ws.send(JSON.stringify({ type: 'error', message: `Unknown message type: "${type}".` }));
  }
};

module.exports = { verifyWsToken, broadcast, handleMessage };
