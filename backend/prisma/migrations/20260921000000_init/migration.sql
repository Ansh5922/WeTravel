-- Enable vector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Create Enums
CREATE TYPE "Role" AS ENUM ('creator', 'admin', 'member');
CREATE TYPE "FriendshipStatus" AS ENUM ('pending', 'accepted', 'blocked');
CREATE TYPE "TripStatus" AS ENUM ('planning', 'ongoing', 'completed', 'archived');
CREATE TYPE "MessageType" AS ENUM ('text', 'image', 'receipt_upload', 'poll', 'ai_system');
CREATE TYPE "PollStatus" AS ENUM ('open', 'closed');
CREATE TYPE "ExpenseSource" AS ENUM ('manual_entry', 'ai_screenshot_ocr');
CREATE TYPE "ExpenseStatus" AS ENUM ('pending_approval', 'approved', 'rejected');
CREATE TYPE "SettlementStatus" AS ENUM ('pending', 'completed');

-- Create Tables
CREATE TABLE "users" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "email" VARCHAR(255) NOT NULL,
    "password_hash" VARCHAR(255),
    "full_name" VARCHAR(100),
    "phone" VARCHAR(20),
    "is_premium" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

CREATE TABLE "user_profiles" (
    "user_id" UUID NOT NULL,
    "dietary_preference" VARCHAR(50),
    "travel_style" VARCHAR(50),
    "budget_tier" VARCHAR(30),
    "pace_preference" VARCHAR(30),
    "health_constraints" JSONB,
    "climate_sensitivities" JSONB,
    "raw_preference_notes" TEXT,
    "preference_vector" vector(384),

    CONSTRAINT "user_profiles_pkey" PRIMARY KEY ("user_id")
);

CREATE TABLE "friendships" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "friend_id" UUID NOT NULL,
    "status" "FriendshipStatus" NOT NULL DEFAULT 'pending',

    CONSTRAINT "friendships_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "trip_groups" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "name" VARCHAR(150) NOT NULL,
    "cover_image_url" TEXT,
    "created_by" UUID NOT NULL,
    "status" "TripStatus" NOT NULL DEFAULT 'planning',
    "trip_start_date" DATE,
    "trip_end_date" DATE,
    "chat_retention_deadline" DATE,
    "preserve_chat" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "trip_groups_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "group_members" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "group_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'member',
    "joined_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "group_members_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "group_consensus_profiles" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "group_id" UUID NOT NULL,
    "computed_budget_range" JSONB,
    "hard_constraints" JSONB,
    "consensus_vector" vector(384),
    "last_edited_by" UUID,
    "is_locked_by_admin" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "group_consensus_profiles_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "group_consensus_profiles_group_id_key" ON "group_consensus_profiles"("group_id");

CREATE TABLE "messages" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "group_id" UUID NOT NULL,
    "sender_id" UUID,
    "message_type" "MessageType" NOT NULL DEFAULT 'text',
    "content" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "messages_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "polls" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "group_id" UUID NOT NULL,
    "created_by" UUID NOT NULL,
    "question" TEXT NOT NULL,
    "status" "PollStatus" NOT NULL DEFAULT 'open',
    "poll_vector" vector(384),

    CONSTRAINT "polls_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "poll_options" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "poll_id" UUID NOT NULL,
    "option_text" VARCHAR(255) NOT NULL,

    CONSTRAINT "poll_options_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "poll_votes" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "poll_id" UUID NOT NULL,
    "option_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,

    CONSTRAINT "poll_votes_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "interaction_embeddings" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "group_id" UUID NOT NULL,
    "source_type" VARCHAR(50) NOT NULL,
    "source_id" UUID,
    "summary_text" TEXT NOT NULL,
    "context_vector" vector(384),

    CONSTRAINT "interaction_embeddings_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "destinations_catalog" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "name" VARCHAR(150) NOT NULL,
    "state" VARCHAR(100),
    "country" VARCHAR(100),
    "tags" JSONB,
    "climate_type" VARCHAR(50),
    "avg_daily_cost" DECIMAL(10,2),
    "destination_vector" vector(384),

    CONSTRAINT "destinations_catalog_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "itineraries" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "group_id" UUID NOT NULL,
    "generated_by" VARCHAR(20) NOT NULL DEFAULT 'ai',
    "version" INTEGER NOT NULL DEFAULT 1,
    "is_active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "itineraries_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "itinerary_items" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "itinerary_id" UUID NOT NULL,
    "day_number" INTEGER NOT NULL,
    "time_slot" VARCHAR(30) NOT NULL,
    "activity_name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "location" VARCHAR(255),
    "transit_mode" VARCHAR(50),
    "estimated_cost" DECIMAL(10,2),

    CONSTRAINT "itinerary_items_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "expenses" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "group_id" UUID NOT NULL,
    "created_by" UUID NOT NULL,
    "source" "ExpenseSource" NOT NULL DEFAULT 'manual_entry',
    "amount" DECIMAL(12,2) NOT NULL,
    "currency" VARCHAR(10) NOT NULL DEFAULT 'INR',
    "category" VARCHAR(50),
    "receipt_image_url" TEXT,
    "ocr_raw_metadata" JSONB,
    "status" "ExpenseStatus" NOT NULL DEFAULT 'pending_approval',
    "approved_by" UUID,
    "approved_at" TIMESTAMPTZ,

    CONSTRAINT "expenses_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "expense_splits" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "expense_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "amount_owed" DECIMAL(12,2) NOT NULL,

    CONSTRAINT "expense_splits_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "settlements" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "group_id" UUID NOT NULL,
    "payer_id" UUID NOT NULL,
    "payee_id" UUID NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "status" "SettlementStatus" NOT NULL DEFAULT 'pending',

    CONSTRAINT "settlements_pkey" PRIMARY KEY ("id")
);

-- Foreign Keys
ALTER TABLE "user_profiles" ADD CONSTRAINT "user_profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "friendships" ADD CONSTRAINT "friendships_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "friendships" ADD CONSTRAINT "friendships_friend_id_fkey" FOREIGN KEY ("friend_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "trip_groups" ADD CONSTRAINT "trip_groups_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "group_members" ADD CONSTRAINT "group_members_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "trip_groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "group_members" ADD CONSTRAINT "group_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "group_consensus_profiles" ADD CONSTRAINT "group_consensus_profiles_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "trip_groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "group_consensus_profiles" ADD CONSTRAINT "group_consensus_profiles_last_edited_by_fkey" FOREIGN KEY ("last_edited_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "messages" ADD CONSTRAINT "messages_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "trip_groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "messages" ADD CONSTRAINT "messages_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "polls" ADD CONSTRAINT "polls_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "trip_groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "polls" ADD CONSTRAINT "polls_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "poll_options" ADD CONSTRAINT "poll_options_poll_id_fkey" FOREIGN KEY ("poll_id") REFERENCES "polls"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "poll_votes" ADD CONSTRAINT "poll_votes_poll_id_fkey" FOREIGN KEY ("poll_id") REFERENCES "polls"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "poll_votes" ADD CONSTRAINT "poll_votes_option_id_fkey" FOREIGN KEY ("option_id") REFERENCES "poll_options"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "poll_votes" ADD CONSTRAINT "poll_votes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "interaction_embeddings" ADD CONSTRAINT "interaction_embeddings_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "trip_groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "itineraries" ADD CONSTRAINT "itineraries_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "trip_groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "itinerary_items" ADD CONSTRAINT "itinerary_items_itinerary_id_fkey" FOREIGN KEY ("itinerary_id") REFERENCES "itineraries"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "trip_groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_approved_by_fkey" FOREIGN KEY ("approved_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "expense_splits" ADD CONSTRAINT "expense_splits_expense_id_fkey" FOREIGN KEY ("expense_id") REFERENCES "expenses"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "expense_splits" ADD CONSTRAINT "expense_splits_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "settlements" ADD CONSTRAINT "settlements_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "trip_groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "settlements" ADD CONSTRAINT "settlements_payer_id_fkey" FOREIGN KEY ("payer_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "settlements" ADD CONSTRAINT "settlements_payee_id_fkey" FOREIGN KEY ("payee_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
