require('dotenv').config();

const express = require('express');
const authRoutes   = require('./routes/auth.routes');
const userRoutes   = require('./routes/user.routes');
const friendRoutes = require('./routes/friend.routes');
const tripRoutes   = require('./routes/trip.routes');
const { errorHandler } = require('./middleware/error.middleware');

const app = express();
const PORT = process.env.PORT || 3000;

// ── Global Middleware ─────────────────────────────────────────────────────────
app.use(express.json());               // Parse JSON request bodies
app.use(express.urlencoded({ extended: true }));

// Live HTTP Request Logger (prints every request in terminal)
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

// ── 404 Handler ───────────────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ status: 'error', message: `Route ${req.method} ${req.path} not found.` });
});

// ── Global Error Handler (must be last!) ──────────────────────────────────────
app.use(errorHandler);

// ── Start Server ──────────────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`✅  WeTravel Backend running on http://localhost:${PORT}`);
  console.log(`📦  Environment: ${process.env.NODE_ENV}`);
});

