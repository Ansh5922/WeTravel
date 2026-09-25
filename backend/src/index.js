const dns = require('dns');
dns.setDefaultResultOrder('ipv4first');
require('dotenv').config();

const http    = require('http');
const express = require('express');
const authRoutes      = require('./routes/auth.routes');
const userRoutes      = require('./routes/user.routes');
const friendRoutes    = require('./routes/friend.routes');
const tripRoutes      = require('./routes/trip.routes');
const chatRoutes      = require('./routes/chat.routes');
const itineraryRoutes = require('./routes/itinerary.routes');
const { errorHandler }          = require('./middleware/error.middleware');
const { attachWsServer }        = require('./websocket/ws.server');
const { startChatRetentionCron } = require('./cron/chat.retention.cron');

const app    = express();
const server = http.createServer(app); // Wrap in HTTP server for WebSocket upgrade
const PORT   = process.env.PORT || 3000;

// ── Global Middleware ─────────────────────────────────────────────────────────
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Live HTTP Request Logger
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`📡 [HTTP] ${req.method} ${req.originalUrl} → ${res.statusCode} (${duration}ms)`);
  });
  next();
});

// ── Health Check ──────────────────────────────────────────────────────────────
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', service: 'WeTravel Backend', timestamp: new Date().toISOString() });
});

// ── Routes ────────────────────────────────────────────────────────────────────
app.use('/api/auth',    authRoutes);
app.use('/api/users',   userRoutes);
app.use('/api/friends', friendRoutes);
app.use('/api/trips',   tripRoutes);
app.use('/api/trips/:tripId/chat', chatRoutes);
app.use('/api/trips',   itineraryRoutes);

// ── 404 Handler ───────────────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ status: 'error', message: `Route ${req.method} ${req.path} not found.` });
});

// ── Global Error Handler ──────────────────────────────────────────────────────
app.use(errorHandler);

// ── WebSocket Server ──────────────────────────────────────────────────────────
attachWsServer(server);

// ── Cron Jobs ─────────────────────────────────────────────────────────────────
startChatRetentionCron();

// ── Start Server ──────────────────────────────────────────────────────────────
server.listen(PORT, () => {
  console.log(`✅  WeTravel Backend running on http://localhost:${PORT}`);
  console.log(`🔌  WebSocket ready at ws://localhost:${PORT}/ws?token=<JWT>&tripId=<UUID>`);
  console.log(`📦  Environment: ${process.env.NODE_ENV}`);
});
