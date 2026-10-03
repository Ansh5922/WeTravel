const express = require('express');
const tripController = require('../controllers/trip.controller');
const { protect } = require('../middleware/auth.middleware');

// Trip group creation, member invitation, and consensus management routes
const router = express.Router();
router.use(protect);

// My pending direct invites
router.get('/invites/me',             tripController.getMyInvites);

// Join trip via invite link token
router.post('/join/:token',           tripController.joinViaToken);

// Accept or reject direct invite
router.patch('/invites/:inviteId',    tripController.respondToInvite);

// Create trip (creator is assigned admin role)
router.post('/',                      tripController.createTrip);

// List user trips by status filter (upcoming, ongoing, completed)
router.get('/',                       tripController.getMyTrips);

// Get trip details with member list
router.get('/:tripId',                tripController.getTripDetails);

// Send trip invitation via friend, email, or whatsapp link
router.post('/:tripId/invite',        tripController.inviteMember);

// List pending invites for a trip
router.get('/:tripId/invites',        tripController.getTripInvites);

// View group consensus profile and aggregated stats
router.get('/:tripId/consensus',      tripController.getConsensus);

// Admin manual override of group consensus
router.patch('/:tripId/consensus',    tripController.updateConsensus);

// Admin assignment of member role (admin or member)
router.patch('/:tripId/members/:targetUserId/role', tripController.assignRole);

module.exports = router;
