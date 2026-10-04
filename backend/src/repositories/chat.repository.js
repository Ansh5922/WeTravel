const prisma = require('./prisma.client');


const PAGE_SIZE = 50;

// ── Messages ────────────────────────────────────────────────────────────────

const getMessages = async (groupId, before = null) => {
  return prisma.message.findMany({
    where: {
      groupId,
      ...(before && { createdAt: { lt: new Date(before) } }),
    },
    orderBy: { createdAt: 'desc' },
    take: PAGE_SIZE,
    include: {
      sender: { select: { id: true, fullName: true, username: true } },
    },
  });
};

const saveMessage = async ({ groupId, senderId, messageType, content, imageUrl = null, pollId = null }) => {
  return prisma.message.create({
    data: { groupId, senderId, messageType, content, imageUrl, pollId },
    include: {
      sender: { select: { id: true, fullName: true, username: true } },
    },
  });
};

// ── Polls ───────────────────────────────────────────────────────────────────

const createPoll = async ({ groupId, createdBy, question, options }) => {
  return prisma.poll.create({
    data: {
      groupId,
      createdBy,
      question,
      options: {
        create: options.map((text) => ({ optionText: text })),
      },
    },
    include: { options: true, creator: { select: { id: true, fullName: true } } },
  });
};

const getPollById = async (pollId) => {
  return prisma.poll.findUnique({
    where: { id: pollId },
    include: {
      options: { include: { votes: true } },
      votes: true,
      creator: { select: { id: true, fullName: true } },
    },
  });
};

const getPollsByGroup = async (groupId) => {
  return prisma.poll.findMany({
    where: { groupId },
    orderBy: { id: 'desc' },
    include: {
      options: { include: { votes: true } },
      creator: { select: { id: true, fullName: true } },
    },
  });
};

const castVote = async ({ pollId, optionId, userId }) => {
  // Upsert: one vote per user per poll (update if they re-vote)
  const existing = await prisma.pollVote.findFirst({ where: { pollId, userId } });
  if (existing) {
    return prisma.pollVote.update({
      where: { id: existing.id },
      data: { optionId },
    });
  }
  return prisma.pollVote.create({ data: { pollId, optionId, userId } });
};

const closePoll = async (pollId) => {
  return prisma.poll.update({
    where: { id: pollId },
    data: { status: 'closed' },
    include: {
      options: { include: { votes: true } },
      creator: { select: { id: true, fullName: true } },
    },
  });
};

const deletePollUserVote = async (pollId, userId) => {
  return prisma.pollVote.deleteMany({ where: { pollId, userId } });
};

// ── Retention ───────────────────────────────────────────────────────────────

const deleteExpiredMessages = async () => {
  const now = new Date();
  const expiredGroups = await prisma.tripGroup.findMany({
    where: {
      preserveChat: false,
      chatRetentionDeadline: { lte: now },
    },
    select: { id: true },
  });
  const groupIds = expiredGroups.map((g) => g.id);
  if (!groupIds.length) return 0;
  const result = await prisma.message.deleteMany({ where: { groupId: { in: groupIds } } });
  return result.count;
};

module.exports = {
  getMessages, saveMessage,
  createPoll, getPollById, getPollsByGroup, castVote, closePoll, deletePollUserVote,
  deleteExpiredMessages,
};
