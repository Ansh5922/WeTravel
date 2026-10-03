const prisma = require('./prisma.client');

// Memory repository for TripMemory table database operations

const memoryInclude = {
  uploader: {
    select: { id: true, fullName: true, username: true },
  },
};

// Insert a single trip memory record
const createMemory = async ({
  groupId,
  uploadedBy,
  mediaUrl,
  thumbnailUrl,
  caption,
  capturedAt,
  locationTag,
  latitude,
  longitude,
  aiHighlight = false,
  highlightScore = 0.5,
}) => {
  return prisma.tripMemory.create({
    data: {
      groupId,
      uploadedBy,
      mediaUrl,
      thumbnailUrl: thumbnailUrl || mediaUrl,
      caption: caption || null,
      capturedAt: capturedAt ? new Date(capturedAt) : new Date(),
      locationTag: locationTag || null,
      latitude: latitude ? parseFloat(latitude) : null,
      longitude: longitude ? parseFloat(longitude) : null,
      aiHighlight: !!aiHighlight,
      highlightScore: highlightScore ? parseFloat(highlightScore) : 0.5,
    },
    include: memoryInclude,
  });
};

// Batch insert multiple memory records
const createManyMemories = async (memoriesData) => {
  return prisma.$transaction(
    memoriesData.map((data) =>
      prisma.tripMemory.create({
        data: {
          groupId: data.groupId,
          uploadedBy: data.uploadedBy,
          mediaUrl: data.mediaUrl,
          thumbnailUrl: data.thumbnailUrl || data.mediaUrl,
          caption: data.caption || null,
          capturedAt: data.capturedAt ? new Date(data.capturedAt) : new Date(),
          locationTag: data.locationTag || null,
          latitude: data.latitude ? parseFloat(data.latitude) : null,
          longitude: data.longitude ? parseFloat(data.longitude) : null,
          aiHighlight: !!data.aiHighlight,
          highlightScore: data.highlightScore ? parseFloat(data.highlightScore) : 0.5,
        },
        include: memoryInclude,
      })
    )
  );
};

// Fetch all memories for a trip group, ordered chronologically
const getMemoriesByGroup = async (groupId) => {
  return prisma.tripMemory.findMany({
    where: { groupId },
    orderBy: [
      { capturedAt: 'asc' },
      { createdAt: 'asc' },
    ],
    include: memoryInclude,
  });
};

// Fetch only curated highlights for a trip
const getHighlights = async (groupId) => {
  return prisma.tripMemory.findMany({
    where: {
      groupId,
      aiHighlight: true,
    },
    orderBy: [
      { highlightScore: 'desc' },
      { capturedAt: 'asc' },
    ],
    include: memoryInclude,
  });
};

// Fetch single memory by ID
const getMemoryById = async (id) => {
  return prisma.tripMemory.findUnique({
    where: { id },
    include: memoryInclude,
  });
};

// Update memory record (e.g., caption or manual highlight toggle)
const updateMemory = async (id, data) => {
  return prisma.tripMemory.update({
    where: { id },
    data,
    include: memoryInclude,
  });
};

// Delete a memory record
const deleteMemory = async (id) => {
  return prisma.tripMemory.delete({
    where: { id },
  });
};

// Fetch selected/active itinerary items for spatial and temporal milestone correlation
const getItineraryItemsForTrip = async (groupId) => {
  const activeItinerary = await prisma.itinerary.findFirst({
    where: { groupId, isSelected: true },
    include: { items: { orderBy: [{ dayNumber: 'asc' }] } },
  });

  if (activeItinerary) return activeItinerary.items;

  const fallback = await prisma.itinerary.findFirst({
    where: { groupId, isActive: true },
    orderBy: { createdAt: 'desc' },
    include: { items: { orderBy: [{ dayNumber: 'asc' }] } },
  });

  return fallback?.items || [];
};

module.exports = {
  createMemory,
  createManyMemories,
  getMemoriesByGroup,
  getHighlights,
  getMemoryById,
  updateMemory,
  deleteMemory,
  getItineraryItemsForTrip,
};
