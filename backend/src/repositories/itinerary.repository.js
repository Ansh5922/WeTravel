const prisma = require('./prisma.client');

/**
 * Itinerary Repository — WeTravel Backend
 * Layer: Repository → DB
 */

const formatItinerary = (itin) => {
  if (!itin) return null;
  const dataSources = itin.constraints?.dataSources || null;
  return {
    ...itin,
    dataSources,
  };
};

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

const getItinerariesByGroup = async (groupId) => {
  const itins = await prisma.itinerary.findMany({
    where: { groupId, isActive: true },
    orderBy: { createdAt: 'desc' },
    include: { items: { orderBy: [{ dayNumber: 'asc' }, { startTime: 'asc' }] } },
  });
  return itins.map(formatItinerary);
};

const getItineraryById = async (itineraryId) => {
  const itin = await prisma.itinerary.findUnique({
    where: { id: itineraryId },
    include: { items: { orderBy: [{ dayNumber: 'asc' }, { startTime: 'asc' }] } },
  });
  return formatItinerary(itin);
};

const selectItinerary = async (itineraryId, groupId) => {
  // Deselect all others for the group, then select this one
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

const getSelectedItinerary = async (groupId) => {
  const selected = await prisma.itinerary.findFirst({
    where: { groupId, isSelected: true },
    include: { items: { orderBy: [{ dayNumber: 'asc' }, { startTime: 'asc' }] } },
  });
  return formatItinerary(selected);
};

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
