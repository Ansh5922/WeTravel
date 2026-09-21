const express = require('express');
const tripController = require('../controllers/trip.controller');
const { protect } = require('../middleware/auth.middleware');

/**
 * Trip Router
 * All routes protected — require valid JWT.
 *
 * Route order matters: static paths (/invites/me, /join/:token) must be
 * declared BEFORE dynamic paths (/:tripId) to avoid Express matching conflicts.
 */
const router = express.Router();
router.use(protect);

// ── Static paths first ────────────────────────────────────────────────────────
router.get('/invites/me',             tripController.getMyInvites);    // My pending direct invites
router.post('/join/:token',           tripController.joinViaToken);    // Join via invite link token
router.patch('/invites/:inviteId',    tripController.respondToInvite); // Accept / reject direct invite

// ── Trip CRUD ─────────────────────────────────────────────────────────────────
router.post('/',                      tripController.createTrip);      // Create trip (creator = admin)
router.get('/',                       tripController.getMyTrips);      // GET /api/trips?status=upcoming|ongoing|completed

// ── Trip-specific actions ──────────────────────────────────────────────────
router.get('/:tripId',                tripController.getTripDetails);  // Get trip details + members
router.post('/:tripId/invite',        tripController.inviteMember);    // Invite (friend/email/whatsapp/link)
router.get('/:tripId/invites',        tripController.getTripInvites);  // Pending invites for a trip
router.get('/:tripId/consensus',      tripController.getConsensus);    // View group preference (all members)
router.patch('/:tripId/consensus',    tripController.updateConsensus); // Admin override group preference
router.patch('/:tripId/members/:targetUserId/role', tripController.assignRole); // Admin assign role

module.exports = router;
