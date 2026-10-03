const express = require('express');
const chatController = require('../controllers/chat.controller');
const { protect } = require('../middleware/auth.middleware');

// Trip chat message and poll routes
const router = express.Router({ mergeParams: true });
router.use(protect);

// Message history (paginated, ?before=<ISO timestamp> for cursor pagination)
router.get('/messages', chatController.getMessages);

// ImageKit direct-upload auth token
router.get('/imagekit-auth', chatController.getImageKitAuth);

// Confirm image upload and persist message
router.post('/image', chatController.confirmImageMessage);

// Poll endpoints
router.post('/polls', chatController.createPoll);
router.get('/polls', chatController.getPolls);
router.post('/polls/:pollId/vote', chatController.castVote);
router.patch('/polls/:pollId/close', chatController.closePoll);

module.exports = router;
