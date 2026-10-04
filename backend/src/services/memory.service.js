const exifr = require('exifr');
const prisma = require('../repositories/prisma.client');
const memoryRepo = require('../repositories/memory.repository');
const imagekitService = require('./imagekit.service');
const { rooms } = require('../websocket/ws.server');
const { broadcast } = require('../websocket/ws.handler');

/**
 * Memory Service — WeTravel Backend
 * Layer: Service (business logic, algorithmic highlight ranking, and timeline grouping)
 */

/** Verify user is a member of the trip (throws 403 otherwise) */
const requireMembership = async (userId, groupId) => {
  const member = await prisma.groupMember.findFirst({ where: { groupId, userId } });
  if (!member) throw Object.assign(new Error('You are not a member of this trip.'), { statusCode: 403 });
  return member;
};

/** ImageKit Auth token for direct frontend photo upload */
const getImageKitAuth = async (userId, groupId) => {
  await requireMembership(userId, groupId);
  return imagekitService.getAuthParams();
};

/**
 * Algorithmic Highlight Scoring (100% Local Heuristics)
 * Evaluates photo attributes, caption, location, and itinerary match.
 *
 * @param {object} photo
 * @param {Array} itineraryItems
 * @returns {{ score: number, isHighlight: boolean, matchedActivity: string | null }}
 */
const evaluateHighlightScore = (photo, itineraryItems = []) => {
  let score = 0.50; // Base score
  let matchedActivity = null;

  // Bonus for user engagement / captions
  if (photo.caption && photo.caption.trim().length > 3) {
    score += 0.15;
  }

  // Bonus for geotagging
  if (photo.locationTag && photo.locationTag.trim().length > 0) {
    score += 0.10;
  }

  // Bonus for GPS metadata
  if (photo.latitude && photo.longitude) {
    score += 0.10;
  }

  // Check correlation with scheduled itinerary items
  if (photo.capturedAt && itineraryItems.length > 0) {
    const photoDate = new Date(photo.capturedAt).toDateString();
    
    // Check if there is a scheduled itinerary stop on this day
    const matchingItem = itineraryItems.find((item) => {
      // If photo location matches activity name or transit mode
      if (photo.locationTag && item.activityName) {
        return item.activityName.toLowerCase().includes(photo.locationTag.toLowerCase()) ||
               photo.locationTag.toLowerCase().includes(item.activityName.toLowerCase());
      }
      return false;
    });

    if (matchingItem) {
      score += 0.15;
      matchedActivity = matchingItem.activityName;
    }
  }

  const finalScore = Math.min(1.0, parseFloat(score.toFixed(2)));
  const isHighlight = finalScore >= 0.70;

  return {
    score: finalScore,
    isHighlight,
    matchedActivity,
  };
};

/**
 * Upload one or multiple trip memories with EXIF parsing & algorithmic curation.
 */
const uploadMemories = async (userId, groupId, photos) => {
  await requireMembership(userId, groupId);

  if (!photos || !Array.isArray(photos) || photos.length === 0) {
    throw Object.assign(new Error('At least one photo must be provided.'), { statusCode: 400 });
  }

  const itineraryItems = await memoryRepo.getItineraryItemsForTrip(groupId);

  const processedData = await Promise.all(
    photos.map(async (p) => {
      let capturedAt = p.capturedAt;
      let latitude = p.latitude;
      let longitude = p.longitude;

      // Extract EXIF metadata if base64/buffer is passed
      if (p.base64Buffer) {
        try {
          const buffer = Buffer.from(p.base64Buffer, 'base64');
          const exif = await exifr.parse(buffer, ['DateTimeOriginal', 'CreateDate', 'latitude', 'longitude']);
          if (exif) {
            capturedAt = capturedAt || exif.DateTimeOriginal || exif.CreateDate;
            latitude = latitude || exif.latitude;
            longitude = longitude || exif.longitude;
          }
        } catch {
          // Graceful fallback to provided date/time if EXIF not present
        }
      }

      // Algorithmic highlight evaluation
      const evalResult = evaluateHighlightScore(
        { ...p, capturedAt, latitude, longitude },
        itineraryItems
      );

      const locationTag = p.locationTag || evalResult.matchedActivity || null;

      return {
        groupId,
        uploadedBy: userId,
        mediaUrl: p.mediaUrl,
        thumbnailUrl: p.thumbnailUrl || p.mediaUrl,
        caption: p.caption || null,
        capturedAt: capturedAt || new Date(),
        locationTag,
        latitude,
        longitude,
        aiHighlight: evalResult.isHighlight,
        highlightScore: evalResult.score,
      };
    })
  );

  const created = await memoryRepo.createManyMemories(processedData);

  // Broadcast to trip room so all members see new photos in real time
  broadcast(rooms, groupId, {
    type: 'NEW_MEMORIES_UPLOADED',
    tripId: groupId,
    count: created.length,
    uploadedBy: userId,
    memories: created,
  });

  return created;
};

/**
 * Fetch the memory timeline grouped by days with top highlight reel.
 */
const getMemoriesTimeline = async (userId, groupId) => {
  await requireMembership(userId, groupId);

  const allMemories = await memoryRepo.getMemoriesByGroup(groupId);

  // Group photos by day (YYYY-MM-DD)
  const dayGroups = {};
  for (const mem of allMemories) {
    const dateKey = new Date(mem.capturedAt || mem.createdAt).toISOString().split('T')[0];
    if (!dayGroups[dateKey]) {
      dayGroups[dateKey] = {
        date: dateKey,
        photos: [],
      };
    }
    dayGroups[dateKey].photos.push(mem);
  }

  // Convert map to sorted timeline array
  const timeline = Object.values(dayGroups).map((day, idx) => ({
    dayNumber: idx + 1,
    date: day.date,
    totalPhotos: day.photos.length,
    photos: day.photos,
  }));

  // Curate top highlights (tagged highlights or top scoring photos)
  const highlights = allMemories
    .filter((m) => m.aiHighlight || m.highlightScore >= 0.70)
    .sort((a, b) => (b.highlightScore || 0) - (a.highlightScore || 0))
    .slice(0, 20); // Top 20 highlight reel

  return {
    totalMemories: allMemories.length,
    highlightsCount: highlights.length,
    highlights,
    timeline,
  };
};

/**
 * Fetch top curated highlights for stories/reels.
 */
const getHighlights = async (userId, groupId) => {
  await requireMembership(userId, groupId);
  return memoryRepo.getHighlights(groupId);
};

/**
 * Toggle highlight status (manual favorite override).
 */
const toggleHighlight = async (userId, groupId, memoryId, isHighlight) => {
  await requireMembership(userId, groupId);
  const memory = await memoryRepo.getMemoryById(memoryId);
  if (!memory || memory.groupId !== groupId) {
    throw Object.assign(new Error('Memory not found in this trip.'), { statusCode: 404 });
  }

  const updated = await memoryRepo.updateMemory(memoryId, {
    aiHighlight: isHighlight !== undefined ? !!isHighlight : !memory.aiHighlight,
  });

  broadcast(rooms, groupId, {
    type: 'MEMORY_HIGHLIGHT_TOGGLED',
    tripId: groupId,
    memoryId,
    aiHighlight: updated.aiHighlight,
  });

  return updated;
};

/**
 * Delete a memory (allowed for uploader or trip admin).
 */
const deleteMemory = async (userId, groupId, memoryId) => {
  const member = await requireMembership(userId, groupId);
  const memory = await memoryRepo.getMemoryById(memoryId);
  if (!memory || memory.groupId !== groupId) {
    throw Object.assign(new Error('Memory not found in this trip.'), { statusCode: 404 });
  }

  const isUploader = memory.uploadedBy === userId;
  const isAdmin = member.role !== 'member';

  if (!isUploader && !isAdmin) {
    throw Object.assign(new Error('Only the uploader or a trip admin can delete this photo.'), { statusCode: 403 });
  }

  await memoryRepo.deleteMemory(memoryId);

  broadcast(rooms, groupId, {
    type: 'MEMORY_DELETED',
    tripId: groupId,
    memoryId,
  });

  return { message: 'Memory deleted successfully.' };
};

module.exports = {
  getImageKitAuth,
  uploadMemories,
  getMemoriesTimeline,
  getHighlights,
  toggleHighlight,
  deleteMemory,
  evaluateHighlightScore,
};
