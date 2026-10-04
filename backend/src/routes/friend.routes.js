const express = require('express');
const friendController = require('../controllers/friend.controller');
const { protect } = require('../middleware/auth.middleware');

/**
 * Friend Router
 * All routes protected — require valid JWT.
 */
const router = express.Router();
router.use(protect);

router.post('/request',               friendController.sendRequest);       // Send friend request by username
router.get('/requests',               friendController.getPendingRequests); // Get incoming pending requests
router.patch('/request/:friendshipId', friendController.respondToRequest);  // Accept or reject
router.get('/',                        friendController.getFriends);         // Get accepted friends list

module.exports = router;
