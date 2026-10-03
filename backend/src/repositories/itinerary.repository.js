const prisma = require('./prisma.client');

// Itinerary repository for database persistence of itinerary variants and items

const formatItinerary = (itin) => {
  if (!itin) return null;
  const dataSources = itin.constraints?.dataSources || null;
  return {
    ...itin,
    dataSources,
  };
};

// Batch create and persist itinerary variants with daily schedule items
const saveItineraries = async (groupId, itineraries) => {
  const saved = [];
  for (const itin of itineraries) {
    const constraintsToSave = {
      ...(itin.constraints || {}),
      ...(itin.dataSources ? { dataSources: itin.dataSources } : {}),
    };
    const created = await prisma.itinerary.create({
      data: {
        groupId,
        generatedBy: 'ai',
        variantType: itin.variantType,
        version: itin.version || 1,
        summary: itin.summary,
        totalCostPerPerson: itin.totalCostPerPerson,
        constraints: constraintsToSave,
        items: {
          create: itin.days.flatMap((day) =>
            day.items.map((item) => ({
              dayNumber: day.dayNumber,
              timeSlot: item.startTime || item.timeSlot || '09:00',
              startTime: item.startTime || null,
              endTime: item.endTime || null,
              activityName: item.activityName,
              description: item.description || null,
              location: item.location || null,
              transitMode: item.transitMode || null,
              estimatedCost: item.estimatedCost || 0,
              bookingRef: item.bookingRef || null,
              apiSource: item.apiSource || null,
              rawApiData: item.rawApiData || null,
            })),
          ),
        },
      },
      include: { items: true },
    });
    saved.push(formatItinerary(created));
  }
  return saved;
};

// Fetch active itineraries for a trip group
const getItinerariesByGroup = async (groupId) => {
  const itins = await prisma.itinerary.findMany({
    where: { groupId, isActive: true },
    orderBy: { createdAt: 'desc' },
    include: { items: { orderBy: [{ dayNumber: 'asc' }, { startTime: 'asc' }] } },
  });
  return itins.map(formatItinerary);
};

// Fetch an itinerary by ID with ordered schedule items
const getItineraryById = async (itineraryId) => {
  const itin = await prisma.itinerary.findUnique({
    where: { id: itineraryId },
    include: { items: { orderBy: [{ dayNumber: 'asc' }, { startTime: 'asc' }] } },
  });
  return formatItinerary(itin);
};

// Select a specific itinerary as the trip's chosen plan
const selectItinerary = async (itineraryId, groupId) => {
  await prisma.itinerary.updateMany({
    where: { groupId, isSelected: true },
    data: { isSelected: false, selectedAt: null },
  });
  const updated = await prisma.itinerary.update({
    where: { id: itineraryId },
    data: { isSelected: true, selectedAt: new Date() },
    include: { items: { orderBy: [{ dayNumber: 'asc' }, { startTime: 'asc' }] } },
  });
  return formatItinerary(updated);
};

// Fetch the currently selected itinerary for a group
const getSelectedItinerary = async (groupId) => {
  const selected = await prisma.itinerary.findFirst({
    where: { groupId, isSelected: true },
    include: { items: { orderBy: [{ dayNumber: 'asc' }, { startTime: 'asc' }] } },
  });
  return formatItinerary(selected);
};

// Flag an individual itinerary item as missed
const markItemMissed = async (itemId) => {
  return prisma.itineraryItem.update({
    where: { id: itemId },
    data: { isMissed: true },
  });
};

module.exports = {
  saveItineraries, getItinerariesByGroup, getItineraryById,
  selectItinerary, getSelectedItinerary, markItemMissed,
};
