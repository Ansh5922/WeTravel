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

const VOTER_USER_SELECT = {
  id: true,
  fullName: true,
  username: true,
  avatarUrl: true,
};

const createPoll = async ({ groupId, createdBy, question, options, isAnonymous = false }) => {
  return prisma.poll.create({
    data: {
      groupId,
      createdBy,
      question,
      isAnonymous: Boolean(isAnonymous),
      options: {
        create: options.map((text) => ({ optionText: text })),
      },
    },
    include: {
      options: {
        include: {
          votes: {
            include: {
              user: { select: VOTER_USER_SELECT },
            },
          },
        },
      },
      creator: { select: { id: true, fullName: true, username: true, avatarUrl: true } },
    },
  });
};

const getPollById = async (pollId) => {
  return prisma.poll.findUnique({
    where: { id: pollId },
    include: {
      options: {
        include: {
          votes: {
            include: {
              user: { select: VOTER_USER_SELECT },
            },
          },
        },
      },
      votes: true,
      creator: { select: { id: true, fullName: true, username: true, avatarUrl: true } },
    },
  });
};

const getPollsByGroup = async (groupId) => {
  return prisma.poll.findMany({
    where: { groupId },
    orderBy: { id: 'desc' },
    include: {
      options: {
        include: {
          votes: {
            include: {
              user: { select: VOTER_USER_SELECT },
            },
          },
        },
      },
      creator: { select: { id: true, fullName: true, username: true, avatarUrl: true } },
    },
  });
};

const updatePoll = async (pollId, { question, options }) => {
  const updateData = {};
  if (question && question.trim()) {
    updateData.question = question.trim();
  }
  if (Array.isArray(options) && options.length > 0) {
    updateData.options = {
      create: options.map((text) => ({ optionText: text })),
    };
  }

  return prisma.poll.update({
    where: { id: pollId },
    data: updateData,
    include: {
      options: {
        include: {
          votes: {
            include: {
              user: { select: VOTER_USER_SELECT },
            },
          },
        },
      },
      creator: { select: { id: true, fullName: true, username: true, avatarUrl: true } },
    },
  });
};

const deletePoll = async (pollId) => {
  return prisma.poll.delete({
    where: { id: pollId },
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
      options: {
        include: {
          votes: {
            include: {
              user: { select: VOTER_USER_SELECT },
            },
          },
        },
      },
      creator: { select: { id: true, fullName: true, username: true, avatarUrl: true } },
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
  createPoll, getPollById, getPollsByGroup, updatePoll, deletePoll, castVote, closePoll, deletePollUserVote,
  deleteExpiredMessages,
};
