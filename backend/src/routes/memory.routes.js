const express = require('express');
const memoryController = require('../controllers/memory.controller');
const { protect } = require('../middleware/auth.middleware');

/**
 * Memory Routes — WeTravel Backend
 * Layer: Routes
 * Mounted at: /api/trips/:tripId/memories (mergeParams: true → :tripId available)
 *
 * ┌─────────────────────────────────────────────────────────────────────────────┐
 * │ Route                                        Method  Auth       Who         │
 * ├─────────────────────────────────────────────────────────────────────────────┤
 * │ /imagekit-auth                               GET     Member     Any member  │
 * │ /highlights                                  GET     Member     Any member  │
 * │ /                                            POST    Member     Any member  │
 * │ /                                            GET     Member     Any member  │
 * │ /:memoryId/highlight                         PATCH   Member     Any member  │
 * │ /:memoryId                                   DELETE  Member*    Uploader/Adm│
 * └─────────────────────────────────────────────────────────────────────────────┘
 */

const router = express.Router({ mergeParams: true });
router.use(protect); // All memory routes require authentication

// ── Static paths first ────────────────────────────────────────────────────────
// ImageKit direct-upload auth parameters for memory photos
router.get('/imagekit-auth', memoryController.getImageKitAuth);

// Curated highlight reel for stories
router.get('/highlights',    memoryController.getHighlights);

// ── Collection routes ─────────────────────────────────────────────────────────
// Upload photo(s) to the Memory Vault
router.post('/',             memoryController.uploadMemories);

// View full day-by-day memory timeline
router.get('/',              memoryController.getMemoriesTimeline);

// ── Dynamic /:memoryId routes ────────────────────────────────────────────────
// Toggle highlight status (favorite override)
router.patch('/:memoryId/highlight', memoryController.toggleHighlight);

// Delete photo (uploader or trip admin)
router.delete('/:memoryId',          memoryController.deleteMemory);

module.exports = router;
