const jwt = require('jsonwebtoken');
const chatRepo = require('../repositories/chat.repository');

/**
 * WebSocket Message Handler — WeTravel Backend
 * Layer: WebSocket Handler (processes incoming WS messages, broadcasts to room)
 *
 * Handles:
 *   - text messages
 *   - image messages (confirmed imageUrl from ImageKit)
 *   - typing indicators
 */

/**
 * Verify JWT from WebSocket connection query param.
 * @param {string} token
 * @returns {{ id: string, email: string }}
 */
const verifyWsToken = (token) => {
  return jwt.verify(token, process.env.JWT_SECRET);
};

/**
 * Broadcast a JSON payload to all authenticated clients in a specific trip room.
 * @param {Map} rooms - Map<tripId, Set<ws>>
 * @param {string} tripId
 * @param {object} payload
 * @param {WebSocket} [skipWs] - Optionally skip the sender
 */
const broadcast = (rooms, tripId, payload, skipWs = null) => {
  const room = rooms.get(tripId);
  if (!room) return;
  const data = JSON.stringify(payload);
  for (const client of room) {
    if (client !== skipWs && client.readyState === 1 /* OPEN */) {
      client.send(data);
    }
  }
};

/**
 * Handle an incoming WebSocket message from a client.
 */
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
      // Broadcast typing indicator to everyone else in the room
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
