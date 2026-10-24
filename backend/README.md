# WeTravel Backend Microservice

> **Welcome to the WeTravel Backend documentation!**  
> This document explains what the backend does and details every route in **plain, simple language** so anyone without a technical background can easily understand how requests are handled and what data is returned.

---

## 📖 Table of Contents
1. [What is the Backend?](#what-is-the-backend)
2. [How the Backend Works (Big Picture)](#how-the-backend-works-big-picture)
3. [Simple Route & Feature Guide](#simple-route--feature-guide)
   - [1. User Accounts & Authentication](#1-user-accounts--authentication)
   - [2. User Profile & Travel Preferences](#2-user-profile--travel-preferences)
   - [3. Friends & Social Network](#3-friends--social-network)
   - [4. Trip Planning & Group Management](#4-trip-planning--group-management)
   - [5. Group Chat & Interactive Polls](#5-group-chat--interactive-polls)
   - [6. Travel Itineraries & Planning](#6-travel-itineraries--planning)
   - [7. Expense Splitting & Debt Settlement](#7-expense-splitting--debt-settlement)
   - [8. Trip Memories & Photo Albums](#8-trip-memories--photo-albums)
4. [How to Run Locally](#how-to-run-locally)

---

## What is the Backend?
The Backend is the central coordinator of WeTravel built with **Node.js & Express**. It connects our mobile users to the **PostgreSQL Database**, handles real-time messages via **WebSockets**, and talks to the **FastAPI AI Engine** whenever smart calculations or AI features are needed.

---

## How the Backend Works (Big Picture)

```
[Mobile App / Web Client]
          │
          ▼  (HTTP Requests & WebSockets)
   [Node.js Backend]
     ├── Handles User Accounts & Security
     ├── Saves Data to Neon PostgreSQL DB
     ├── Broadcasts Live Chat & Polls
     └── Dispatches AI Requests ──► [FastAPI AI Microservice]
```

---

## Simple Route & Feature Guide

---

### 1. User Accounts & Authentication

#### 1.1 Sign Up (Register New Account)
- **What it does:** Creates a brand-new user account.
- **Route:** `POST /api/auth/signup`
- **What is sent in (Request):**
  - `name`: Full name.
  - `email`: User email address.
  - `password`: Password chosen by the user.
- **How it is handled behind the scenes:**
  - Checks if the email is already registered.
  - Scrambles (hashes) the password securely.
  - Saves the user in the database and creates an initial profile.
- **What is returned (Response):**
  - `token`: Secure login pass (JWT) for future requests.
  - `user`: Basic user details (`id`, `name`, `email`).

#### 1.2 Log In
- **What it does:** Authenticates an existing user.
- **Route:** `POST /api/auth/login`
- **What is sent in (Request):**
  - `email`: Registered email.
  - `password`: User password.
- **How it is handled behind the scenes:**
  - Verifies the email and compares the password.
  - Issues a fresh login pass.
- **What is returned (Response):**
  - `token`: Login pass.
  - `user`: Details (`id`, `name`, `email`, profile photo).

#### 1.3 Google One-Click Sign-In
- **What it does:** Allows one-tap sign-in using Google.
- **Route:** `POST /api/auth/google`
- **What is sent in (Request):**
  - `idToken`: Token received from Google on the user's phone.
- **How it is handled behind the scenes:**
  - Validates the token directly with Google servers.
  - Creates an account if new, or logs in if existing.
- **What is returned (Response):**
  - `token`: WeTravel login pass.
  - `user`: Details imported from Google.

#### 1.4 Get My Account Details
- **What it does:** Checks who is currently logged in when the app starts.
- **Route:** `GET /api/auth/me`
- **What is sent in (Request):** None (uses login pass).
- **How it is handled behind the scenes:**
  - Looks up the user by the ID stored inside their login pass.
- **What is returned (Response):**
  - `user`: Name, email, phone, and profile photo.

---

### 2. User Profile & Travel Preferences

#### 2.1 View My Travel Profile
- **What it does:** Displays the user's travel style, food preferences, and pace.
- **Route:** `GET /api/users/profile`
- **What is sent in (Request):** None.
- **How it is handled behind the scenes:**
  - Reads saved habits and constraints from the database.
- **What is returned (Response):**
  - `profile`: Dietary choice (Veg/Non-veg), travel style (Adventure/Chill), budget tier, health constraints.

#### 2.2 Update Travel Profile & Preferences
- **What it does:** Updates habits and alerts the AI to regenerate the user's smart taste profile.
- **Route:** `PATCH /api/users/profile`
- **What is sent in (Request):**
  - `fullName`, `phone`: Contact details.
  - `dietaryPreference`, `travelStyle`, `budgetTier`, `pacePreference`: Travel habits.
  - `healthConstraints`: Medical notes/allergies.
  - `rawPreferenceNotes`: Free-text notes (e.g., *"Love cafes and quiet treks"*).
- **How it is handled behind the scenes:**
  - Saves updates to the database.
  - Asynchronously sends preference notes to the AI engine to update vector embeddings.
- **What is returned (Response):**
  - `message`: "Profile updated successfully."
  - `profile`: Updated profile details.

#### 2.3 Delete Account (Play Store & GDPR Compliant)
- **What it does:** Permanently deletes user account, scrubs all personal identifying data (PII), and invalidates active sessions while preserving shared group financial ledgers.
- **Route:** `DELETE /api/users/account`
- **What is sent in (Request):** None (requires Bearer token).
- **How it is handled behind the scenes:**
  - Deletes user's private `UserProfile` and AI preference vectors.
  - Deletes all friendship connections and pending invites.
  - Scrubs name to `"Deleted User"`, email to an anonymized placeholder, and sets phone/passwords to `null`.
  - Immediately revokes the JWT session so the user cannot log in again.
- **What is returned (Response):**
  - `status`: `"success"`
  - `message`: `"Account deleted successfully and personal data anonymized."`

---

### 3. Friends & Social Network

#### 3.1 Send Friend Request
- **What it does:** Sends an in-app friend request to another user.
- **Route:** `POST /api/friends/request`
- **What is sent in (Request):**
  - `username` or `email`: The person to add.
- **How it is handled behind the scenes:**
  - Verifies the user exists and creates a "pending" friendship request.
- **What is returned (Response):**
  - `message`: "Friend request sent successfully."

#### 3.2 View Pending Friend Requests
- **What it does:** Lists all invitations waiting for your decision.
- **Route:** `GET /api/friends/requests`
- **What is sent in (Request):** None.
- **How it is handled behind the scenes:**
  - Fetches all pending requests where the logged-in user is the recipient.
- **What is returned (Response):**
  - `requests`: List of pending requests with sender names and photos.

#### 3.3 Accept or Reject Friend Request
- **What it does:** Approves or declines a friend request.
- **Route:** `PATCH /api/friends/request/:friendshipId`
- **What is sent in (Request):**
  - `status`: `"accepted"` or `"rejected"`.
- **How it is handled behind the scenes:**
  - Updates the friendship state. If accepted, both users can add each other to group trips.
- **What is returned (Response):**
  - `message`: Status update confirmation.

#### 3.4 List My Friends
- **What it does:** Displays all accepted friends.
- **Route:** `GET /api/friends`
- **What is sent in (Request):** None.
- **How it is handled behind the scenes:**
  - Retrieves the user's active friendships.
- **What is returned (Response):**
  - `friends`: List of friends (name, email, profile photo).

---

### 4. Trip Planning & Group Management

#### 4.1 Create a New Trip
- **What it does:** Creates a new group trip (creator automatically becomes the Admin).
- **Route:** `POST /api/trips`
- **What is sent in (Request):**
  - `name`: Trip title (e.g., *"Goa Weekend Getaway"*).
  - `destination`: Target location.
  - `startDate`, `endDate`: Travel dates.
  - `coverImageUrl`: Optional cover photo link.
- **How it is handled behind the scenes:**
  - Records the trip, assigns the creator as Admin, and initializes chat and expense ledgers.
- **What is returned (Response):**
  - `trip`: Complete trip object with ID and shareable invite token.

#### 4.2 List My Trips
- **What it does:** Shows all trips the user is part of.
- **Route:** `GET /api/trips` (optional filter: `?status=upcoming|ongoing|completed`)
- **What is sent in (Request):** None.
- **How it is handled behind the scenes:**
  - Finds all trips where the user is an active member.
- **What is returned (Response):**
  - `trips`: List of trips with dates, destination, cover photo, and status.

#### 4.3 View Trip Details
- **What it does:** Opens the trip dashboard showing members and roles.
- **Route:** `GET /api/trips/:tripId`
- **What is sent in (Request):** `tripId` in URL.
- **How it is handled behind the scenes:**
  - Checks user membership and loads trip metadata and member list.
- **What is returned (Response):**
  - `trip`: Destination, dates, members list with Admin/Member badges.

#### 4.4 Invite Friends to Trip
- **What it does:** Generates a link or sends an invite to friends.
- **Route:** `POST /api/trips/:tripId/invite`
- **What is sent in (Request):**
  - `inviteType`: `"friend"`, `"email"`, or `"link"`.
  - `friendId` or `email`: Target person.
- **How it is handled behind the scenes:**
  - Creates an invitation record and generates a secure join link.
- **What is returned (Response):**
  - `inviteLink`: Shareable link.

#### 4.5 Join Trip Via Link
- **What it does:** Allows a friend with an invite link to join the trip.
- **Route:** `POST /api/trips/join/:token`
- **What is sent in (Request):** `token` in URL.
- **How it is handled behind the scenes:**
  - Validates the token and adds the user as an official group member.
- **What is returned (Response):**
  - `message`: "Successfully joined trip!"
  - `trip`: Trip details.

#### 4.6 View Group Consensus
- **What it does:** Shows the combined preferences of all trip members.
- **Route:** `GET /api/trips/:tripId/consensus`
- **What is sent in (Request):** `tripId` in URL.
- **How it is handled behind the scenes:**
  - Fetches the group consensus calculated by the AI engine.
- **What is returned (Response):**
  - `consensus`: Combined budget range, food restrictions, and preferred pacing.

#### 4.7 Admin Override Group Consensus
- **What it does:** Allows the trip organizer to manually set budget or pace rules.
- **Route:** `PATCH /api/trips/:tripId/consensus`
- **What is sent in (Request):**
  - `budgetRange`: Overridden budget range.
  - `hardConstraints`: Mandatory rules (e.g., *"Must have vegetarian food options"*).
- **How it is handled behind the scenes:**
  - Verifies user is Admin and locks the profile against automatic changes.
- **What is returned (Response):**
  - `message`: "Group consensus updated and locked."

---

### 5. Group Chat & Interactive Polls

#### 5.1 Fetch Chat Messages
- **What it does:** Loads previous chat messages in the group room.
- **Route:** `GET /api/chat/:groupId/messages`
- **What is sent in (Request):** Optional `before` timestamp for loading older history.
- **How it is handled behind the scenes:**
  - Fetches messages sorted chronologically (oldest to newest).
- **What is returned (Response):**
  - `messages`: List of messages (sender name, text, photo URL, timestamp).

#### 5.2 Upload Photo to Chat
- **What it does:** Posts a photo into the group chat stream.
- **Route:** `POST /api/chat/:groupId/image`
- **What is sent in (Request):**
  - `imageUrl`: Public link to the uploaded photo.
  - `fileName`: Optional photo name.
- **How it is handled behind the scenes:**
  - Saves the image message and broadcasts it live to all group members via WebSockets.
- **What is returned (Response):**
  - `message`: Saved message record.

#### 5.3 Create Group Poll
- **What it does:** Starts a voting poll (e.g., *"Rafting or Bungee Jumping?"*).
- **Route:** `POST /api/chat/:groupId/polls`
- **What is sent in (Request):**
  - `question`: Poll question.
  - `options`: List of choices (e.g., `["Rafting", "Bungee Jumping"]`).
- **How it is handled behind the scenes:**
  - Saves the poll and broadcasts an alert to the group.
- **What is returned (Response):**
  - `poll`: Created poll with options and zero votes.

#### 5.4 Vote on a Poll
- **What it does:** Casts your vote for an option.
- **Route:** `POST /api/chat/polls/:pollId/vote`
- **What is sent in (Request):**
  - `optionId`: Selected option ID.
- **How it is handled behind the scenes:**
  - Records or updates vote, then broadcasts live vote percentages to the room.
- **What is returned (Response):**
  - `poll`: Updated poll results.

#### 5.5 Close Poll (Final Decision)
- **What it does:** Closes voting and calculates the winning choice.
- **Route:** `PATCH /api/chat/polls/:pollId/close`
- **What is sent in (Request):** None.
- **How it is handled behind the scenes:**
  - Freezes voting, calculates results, and forwards the winner to the AI engine for future planning.
- **What is returned (Response):**
  - `poll`: Final summary of votes.

---

### 6. Travel Itineraries & Planning

#### 6.1 Generate Itineraries with AI
- **What it does:** Asks the AI engine to generate 3 custom travel plans for the group.
- **Route:** `POST /api/itineraries/:tripId/itinerary/generate`
- **What is sent in (Request):**
  - `origin`: Starting city.
  - `destination`: Trip destination.
  - `startDate`, `endDate`: Travel dates.
  - `constraints`: Specific group desires (e.g., *"Beach activities"*).
- **How it is handled behind the scenes:**
  - Backend collects member preferences, calls the AI Engine, and saves 3 variants (Budget/Adventure, Balanced, Luxury).
- **What is returned (Response):**
  - `itineraries`: 3 complete day-by-day plans with morning, afternoon, and evening activities.

#### 6.2 View Trip Itineraries
- **What it does:** Displays all generated drafts for this trip.
- **Route:** `GET /api/itineraries/:tripId/itineraries`
- **What is sent in (Request):** `tripId` in URL.
- **How it is handled behind the scenes:**
  - Loads saved itinerary proposals.
- **What is returned (Response):**
  - `itineraries`: List of plans with day breakdown and estimated costs.

#### 6.3 Select Official Itinerary
- **What it does:** Locks in the plan the group agrees to follow.
- **Route:** `PATCH /api/itineraries/:tripId/itineraries/:id/select`
- **What is sent in (Request):** Itinerary ID in URL.
- **How it is handled behind the scenes:**
  - Marks the chosen itinerary as active and archives the other two.
- **What is returned (Response):**
  - `message`: "Itinerary selected as official schedule."

#### 6.4 Mishap / Emergency Schedule Recovery
- **What it does:** Re-adjusts the trip schedule in case of rain, flight delays, or closures.
- **Route:** `POST /api/itineraries/:tripId/itineraries/mishap`
- **What is sent in (Request):**
  - `mishapType`: Nature of issue (`"weather_delay"`, `"transport_cancellation"`).
  - `mishapDescription`: What happened.
  - `affectedDate`: Date impacted.
- **How it is handled behind the scenes:**
  - AI swaps outdoor plans with indoor alternatives and balances remaining days.
- **What is returned (Response):**
  - `itinerary`: Newly repaired schedule.

---

### 7. Expense Splitting & Debt Settlement

#### 7.1 Manual Expense Entry
- **What it does:** Records a bill paid by one person and splits it among the group.
- **Route:** `POST /api/expenses`
- **What is sent in (Request):**
  - `groupId`: Trip ID.
  - `title`: Description (e.g., *"Dinner at Fisherman's Wharf"*).
  - `amount`: Total amount paid (e.g., `₹3,500`).
  - `category`: Category (`food`, `stay`, `transit`, `activities`).
  - `paidById`: Who paid the bill.
  - `splitMemberIds`: Who is sharing this bill.
  - `splitType`: `"equal"` or `"custom"`.
- **How it is handled behind the scenes:**
  - Calculates everyone's share and updates group balance ledgers.
- **What is returned (Response):**
  - `expense`: Saved record with individual debt shares.

#### 7.2 View Group Expense List
- **What it does:** Shows all expenses recorded for this trip.
- **Route:** `GET /api/expenses`
- **What is sent in (Request):** `groupId` filter.
- **How it is handled behind the scenes:**
  - Loads chronological list of group expenses.
- **What is returned (Response):**
  - `expenses`: List of all bills, payer name, and split status.

#### 7.3 Debt Settlement ("Who Owes Whom?")
- **What it does:** Solves complicated group debts so members make the minimum number of UPI transfers.
- **Route:** `GET /api/expenses/settlements` & `POST /api/expenses/settlements/calculate`
- **What is sent in (Request):** `groupId`.
- **How it is handled behind the scenes:**
  - Uses an optimal debt simplification algorithm (e.g., if Alice owes Bob ₹500 and Bob owes Charlie ₹500, Alice pays Charlie ₹500 directly).
- **What is returned (Response):**
  - `settlements`: Clean transfer list (e.g., *"Rahul pays Priya ₹1,200"*).

#### 7.4 Mark Debt as Paid
- **What it does:** Confirms money transfer is completed.
- **Route:** `PATCH /api/expenses/settlements/:settlementId/complete`
- **What is sent in (Request):** None.
- **How it is handled behind the scenes:**
  - Clears debt balance between the two members.
- **What is returned (Response):**
  - `message`: "Settlement marked as completed."

---

### 8. Trip Memories & Photo Albums

#### 8.1 Upload Trip Photos
- **What it does:** Members upload trip photos to a shared scrapbook.
- **Route:** `POST /api/memories`
- **What is sent in (Request):**
  - `groupId`: Trip ID.
  - `mediaUrls`: List of uploaded image links.
  - `caption`: Optional memory caption.
  - `locationName`: Where the photo was taken.
- **How it is handled behind the scenes:**
  - Saves images to the trip scrapbook album.
- **What is returned (Response):**
  - `memories`: List of saved photo records.

#### 8.2 View Memory Timeline
- **What it does:** Displays chronological photo scrapbook.
- **Route:** `GET /api/memories`
- **What is sent in (Request):** `groupId`.
- **How it is handled behind the scenes:**
  - Orders photos by timestamp.
- **What is returned (Response):**
  - `timeline`: Photos arranged day-by-day with captions.

#### 8.3 Star a Highlight Photo
- **What it does:** Features a photo on the trip summary reel.
- **Route:** `PATCH /api/memories/:memoryId/highlight`
- **What is sent in (Request):** None.
- **How it is handled behind the scenes:**
  - Toggles the highlight star on or off.
- **What is returned (Response):**
  - `isHighlight`: `true` or `false`.

---

## How to Run Locally

1. **Install Dependencies:**
   ```bash
   npm install
   ```
2. **Environment Variables:**
   Create a `.env` file based on `.env.example`:
   ```bash
   cp .env.example .env
   ```
3. **Database Migration:**
   ```bash
   npx prisma migrate dev
   ```
4. **Start Backend Server:**
   ```bash
   npm run dev
   ```
   Server will run on `http://localhost:3000`.
