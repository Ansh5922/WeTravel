const path = require('path');
const dns = require('dns');
dns.setDefaultResultOrder('ipv4first');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });

const http = require('http');
const express = require('express');
const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');
const friendRoutes = require('./routes/friend.routes');
const tripRoutes = require('./routes/trip.routes');
const chatRoutes = require('./routes/chat.routes');
const itineraryRoutes = require('./routes/itinerary.routes');
const expenseRoutes = require('./routes/expense.routes');
const memoryRoutes = require('./routes/memory.routes');
const { errorHandler } = require('./middleware/error.middleware');
const { attachWsServer } = require('./websocket/ws.server');
const { startChatRetentionCron } = require('./cron/chat.retention.cron');

const app = express();
const server = http.createServer(app);
const PORT = process.env.PORT || 3000;

// CORS middleware allowing cross-origin requests and preflight handling
app.use((req, res, next) => {
  const origin = req.headers.origin;
  res.setHeader('Access-Control-Allow-Origin', origin || '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  res.setHeader('Access-Control-Allow-Credentials', 'true');

  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// HTTP request duration logger
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`📡 [HTTP] ${req.method} ${req.originalUrl} → ${res.statusCode} (${duration}ms)`);
  });
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', service: 'WeTravel Backend', timestamp: new Date().toISOString() });
});

// Register API route handlers
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/friends', friendRoutes);
app.use('/api/trips', tripRoutes);
app.use('/api/trips/:tripId/chat', chatRoutes);
app.use('/api/trips/:tripId/expenses', expenseRoutes);
app.use('/api/trips/:tripId/memories', memoryRoutes);
app.use('/api/trips', itineraryRoutes);

// Catch-all 404 handler
app.use((req, res) => {
  res.status(404).json({ status: 'error', message: `Route ${req.method} ${req.path} not found.` });
});

// Global error handler
app.use(errorHandler);

// Attach WebSocket server instance
attachWsServer(server);

// Start chat message retention cron job
startChatRetentionCron();

// Start HTTP server listener
server.listen(PORT, () => {
  console.log(`✅  WeTravel Backend running on http://localhost:${PORT}`);
  console.log(`🔌  WebSocket ready at ws://localhost:${PORT}/ws?token=<JWT>&tripId=<UUID>`);
  console.log(`📦  Environment: ${process.env.NODE_ENV || process.env.ENVIRONMENT || 'development'}`);
});
