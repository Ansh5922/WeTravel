# WeTravel AI Engine Microservice

> **Welcome to the WeTravel AI Engine documentation!**  
> This document explains the AI microservice in **plain, simple language**.  
> It details every AI route, what data comes in, what smart calculations happen behind the scenes, and what is returned.

---

## 📖 Table of Contents
1. [What is the AI Engine?](#what-is-the-ai-engine)
2. [How the AI Engine Works (Architecture)](#how-the-ai-engine-works-architecture)
3. [Simple Route & Feature Guide](#simple-route--feature-guide)
   - [1. Server Health & Token Test](#1-server-health--token-test)
   - [2. Learning User Travel Taste (Embeddings)](#2-learning-user-travel-taste-embeddings)
   - [3. Calculating Group Compromise (Consensus)](#3-calculating-group-compromise-consensus)
   - [4. Generating 3-Tier Itinerary Packages](#4-generating-3-tier-itinerary-packages)
   - [5. Emergency Mishap & Delay Recovery](#5-emergency-mishap--delay-recovery)
   - [6. Paper Bill & Receipt Scanner (OCR)](#6-paper-bill--receipt-scanner-ocr)
   - [7. Poll Decisions & Group Memory](#7-poll-decisions--group-memory)
4. [AI Technologies Explained in Simple Words](#ai-technologies-explained-in-simple-words)
5. [How to Run Locally](#how-to-run-locally)

---

## What is the AI Engine?
The **AI Engine** is WeTravel's smart brain built with **FastAPI (Python)**.  
While the Node.js Backend handles normal everyday tasks (like chats and accounts), the AI Engine handles heavy mathematical and artificial intelligence work:
- Translates travel habits into smart numerical fingerprints.
- Finds fair compromises between people with different budgets and travel speeds.
- Builds realistic day-by-day itineraries with morning, afternoon, and evening activities.
- Reads restaurant and transit bills from paper photos using Optical Character Recognition (OCR).

---

## How the AI Engine Works (Architecture)

```
[Node.js Backend]
        │
        ▼  (Internal HTTP Request with Secure Token)
[FastAPI AI Engine (:8000)]
  ├── 1. Verifies Token (No inter-server delay)
  ├── 2. Warms Up AI Models in RAM on Startup (Fast Response)
  ├── 3. Executes Heavy AI / Math / OCR Logic
  └── 4. Reads & Writes Vectors to Neon PostgreSQL (pgvector)
```

---

## Simple Route & Feature Guide

---

### 1. Server Health & Token Test

#### 1.1 Health Check
- **What it does:** Allows cloud systems (Docker / Kubernetes / AWS) to check if the AI service is alive and healthy.
- **Route:** `GET /health`
- **What is sent in (Request):** None.
- **How it is handled behind the scenes:**
  - Responds immediately to confirm the server process is running.
- **What is returned (Response):**
  - `status`: `"online"`
  - `service`: `"WeTravel AI Engine"`
  - `version`: `"2.0.0"`

#### 1.2 Test Security Token Verification
- **What it does:** Verifies that a login token issued by the Node.js backend is valid and recognized by Python.
- **Route:** `GET /api/ai/test-auth`
- **What is sent in (Request):** Bearer token in the header.
- **How it is handled behind the scenes:**
  - Python uses the shared secret key to decrypt and verify the token without asking Node.js.
- **What is returned (Response):**
  - `status`: `"success"`
  - `authenticated_user_id`: The ID of the authenticated traveler.

---

### 2. Learning User Travel Taste (Embeddings)

#### 2.1 Generate User Taste Vector
- **What it does:** Converts what a user wrote about their travel habits into an AI "taste fingerprint".
- **Route:** `POST /api/ai/embeddings/preferences`
- **What is sent in (Request):**
  - `user_id`: Traveler's unique ID.
  - `preference_text`: Natural description (e.g., *"Vegetarian who loves quiet mountain cafes, slow walks, and budget hostels"*).
- **How it is handled behind the scenes:**
  - Passes the text through our AI embedding model (`all-MiniLM-L6-v2`).
  - Converts words into a **384-dimensional vector** (a list of 384 numbers that capture the subtle meaning of the user's travel taste).
  - Saves these numbers directly into the `user_profiles` database table.
- **What is returned (Response):**
  - `user_id`: Traveler's ID.
  - `vector_dimensions`: `384` (confirmation of complete embedding).

---

### 3. Calculating Group Compromise (Consensus)

#### 3.1 Group Consensus Calculation
- **What it does:** When friends travel together, they often have different budgets and travel speeds. This endpoint calculates a fair compromise so everyone is happy.
- **Route:** `POST /api/ai/consensus/group-preference`
- **What is sent in (Request):**
  - `group_id`: Trip group ID.
  - `member_preferences`: List of each member's budget tier, pacing preference (chill vs. active), and dietary habits.
- **How it is handled behind the scenes:**
  - Combines everyone's taste vectors mathematically.
  - Resolves dietary conflicts (e.g., if even 1 person is Vegan, the group needs Vegan-friendly stops).
  - Finds a realistic compromise budget range (e.g., ₹2,500 – ₹4,000 / day).
  - Saves the resulting consensus profile to the database.
- **What is returned (Response):**
  - `computed_budget_range`: Suggested minimum and maximum daily budget.
  - `hard_constraints`: Combined dietary and medical rules.
  - `dominant_style`: Group's unified vibe (e.g., *"Balanced / Nature-Curated"*).

---

### 4. Generating 3-Tier Itinerary Packages

#### 4.1 AI Travel Plan Generator
- **What it does:** Generates 3 complete, realistic day-by-day itinerary proposals tailored to the group's consensus.
- **Route:** `POST /api/ai/itinerary/generate`
- **What is sent in (Request):**
  - `origin`: Starting city (e.g., *"Delhi"*).
  - `destination`: Where the group is going (e.g., *"Manali"*).
  - `start_date`, `end_date`: Trip dates.
  - `member_count`: Number of travelers.
  - `group_stats`: Budget and pace rules from the consensus profile.
  - `constraints`: Specific requests (e.g., *"Include river rafting"*).
- **How it is handled behind the scenes:**
  - The scheduler divides each day into **Morning, Afternoon, and Evening** activity slots.
  - Builds 3 distinct package variants:
    1. **Budget / Adventure Variant:** Focuses on scenic outdoor treks, budget stays, and public/shared transit.
    2. **Balanced Variant:** Popular tourist sights, reputable local dining, and comfortable pacing.
    3. **Luxury / Relaxed Variant:** Premium resorts, private cabs, fine dining, and leisure time.
  - Calculates estimated costs per person for each plan.
- **What is returned (Response):**
  - `itineraries`: 3 complete itinerary packages containing daily schedules, activity titles, durations, and estimated costs.

---

### 5. Emergency Mishap & Delay Recovery

#### 5.1 Re-Schedule Itinerary on Mishaps
- **What it does:** If an unforeseen event occurs during the trip (e.g., severe storm, cancelled flight, closed museum), AI immediately reorganizes the remaining schedule.
- **Route:** `POST /api/ai/itinerary/recover`
- **What is sent in (Request):**
  - `itinerary_id`: Current active plan ID.
  - `mishap_type`: Category of problem (`"weather_delay"`, `"transport_cancellation"`).
  - `description`: What happened (e.g., *"Heavy rain flooded the trekking route"*).
  - `affected_date`: The day impacted.
- **How it is handled behind the scenes:**
  - Identifies which planned activities are no longer possible.
  - Replaces outdoor activities with nearby indoor alternatives (e.g., local art galleries, indoor markets, cozy cafes).
  - Shifts priority sights to the next available sunny day.
- **What is returned (Response):**
  - `itinerary`: Updated itinerary with the repaired schedule and recovery notes.

---

### 6. Paper Bill & Receipt Scanner (OCR)

#### 6.1 Scan Receipt Photo
- **What it does:** Takes a photo of a restaurant or hotel receipt and automatically extracts the total bill amount and category!
- **Route:** `POST /api/ai/ocr/receipt`
- **What is sent in (Request):**
  - `image_url`: Public link of the uploaded receipt photo.
  - `group_id`: Trip group ID.
  - `expense_id`: Associated expense record.
- **How it is handled behind the scenes:**
  - Downloads image into memory.
  - Uses **Tesseract Optical Character Recognition (OCR)** to read every printed word.
  - Uses smart pattern matching (Regex) to spot currency indicators (`₹`, `INR`, `Grand Total`, `Amount Paid`).
  - Scans for keywords (*"biryani"*, *"hotel"*, *"petrol"*) to automatically tag the category (`food`, `stay`, `transit`).
  - If the image is too blurry to read, returns a graceful message telling the user to enter the amount manually.
- **What is returned (Response):**
  - `success`: `true` or `false`.
  - `amount`: Extracted number (e.g., `1450.00`).
  - `currency`: `"INR"`.
  - `category`: Identified category (`"food"`, `"stay"`, `"transit"`).
  - `raw_text`: First 2000 characters of text read from the receipt.

---

### 7. Poll Decisions & Group Memory

#### 7.1 Record Group Decision Embedding
- **What it does:** When group members vote in chat to settle a question (e.g., *"Do we want Italian or North Indian for dinner?"*), this endpoint records the winning choice into group memory.
- **Route:** `POST /api/ai/embeddings/interaction`
- **What is sent in (Request):**
  - `group_id`: Trip ID.
  - `source_type`: Source of decision (`"poll"`).
  - `source_id`: Poll ID.
  - `summary_text`: Summary of the vote (e.g., *"Poll result: 4 votes for Italian, 1 vote for Indian"*).
- **How it is handled behind the scenes:**
  - Converts the decision summary into a vector.
  - Saves it to the `interaction_embeddings` table so future itinerary recommendations take this decision into account.
- **What is returned (Response):**
  - `status`: `"success"`
  - `message`: "Interaction embedding generated and saved."

---

## AI Technologies Explained in Simple Words

1. **Sentence Transformers (`all-MiniLM-L6-v2`):**
   - *What it is:* A deep-learning language model.
   - *What it does:* Turns human travel desires (e.g., *"peaceful mountain sunsets"*) into a list of 384 numbers. If two travelers have similar tastes, their numbers will be mathematically close to each other.

2. **pgvector (Vector Database):**
   - *What it is:* An extension for PostgreSQL.
   - *What it does:* Allows our database to search by "vibe" and "similarity" rather than just exact keywords.

3. **Tesseract OCR Engine:**
   - *What it is:* Optical Character Recognition engine.
   - *What it does:* Acts like digital eyes to read printed characters on crumpled physical paper receipts and bills.

4. **FastAPI Lifespan Startup:**
   - *What it is:* Server startup lifecycle manager.
   - *What it does:* Loads AI model weights into memory when the server turns on so user requests never freeze or wait.

---

## How to Run Locally

1. **Activate Virtual Environment:**
   ```bash
   .\venv\Scripts\activate
   ```
2. **Install Dependencies:**
   ```bash
   pip install -r requirements.txt
   ```
3. **Environment Variables:**
   Ensure `.env` exists with database and secret keys.
4. **Run FastAPI Server:**
   ```bash
   uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```
   Interactive Swagger API docs will be available at `http://localhost:8000/docs`.
