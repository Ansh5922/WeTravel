const express = require('express');
const memoryController = require('../controllers/memory.controller');
const { protect } = require('../middleware/auth.middleware');

// Trip memory vault and photo timeline routes
const router = express.Router({ mergeParams: true });
router.use(protect);

// ImageKit direct-upload auth parameters for memory photos
router.get('/imagekit-auth', memoryController.getImageKitAuth);

// Curated highlight reel for stories
router.get('/highlights',    memoryController.getHighlights);

// Upload photo(s) to the Memory Vault
router.post('/',             memoryController.uploadMemories);

// View full day-by-day memory timeline
router.get('/',              memoryController.getMemoriesTimeline);

// Toggle highlight status (favorite override)
router.patch('/:memoryId/highlight', memoryController.toggleHighlight);

// Delete photo (uploader or trip admin)
router.delete('/:memoryId',          memoryController.deleteMemory);

module.exports = router;
