# Implementation Plan - Student Rankings & Analytics

## Goal
Replace the unstructured `AdminAnalytics` table with a structured `StudentRankings` table to support filtered leaderboards by Activity and Level (Beginner, Intermediate, etc.).

## Proposed Changes

### Database Schema
1.  **Drop Table**: `AdminAnalytics`
2.  **Create Table**: `StudentRankings`
    - `id`: PK, Integer, AutoIncrement
    - `student_id`: FK to `Users` (optional, for now we can store `name` and `photo` directly if no user exists, or link it. Given `User` model exists, we should probably link `student_id`).
        - *Decision*: I'll add `student_id` (nullable) AND `name`/`photo` columns. If `student_id` is present, we can fetch from User, but storing `name`/`photo` snapshots is also fine for analytics to persist even if user changes. Let's just link to User for cleaner data if possible, but the user's current seeder uses explicit names/photos. I'll include `name` and `photo` columns in `StudentRankings` to be safe and simple.
    - `activity_type`: Enum/String ('GROUP_DISCUSSION', 'TECHNICAL_EVENTS', 'PRESENTATION', 'CASE_STUDY', 'DEBATE_CLUB')
    - `level`: Enum/String ('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT', 'OVERALL')
    - `rank`: Integer
    - `points`: Integer
    - `trend`: String ('UP', 'DOWN', 'SAME') - Optional, for UI "progress" or similar.
    - `created_at`, `updated_at`

### Backend Logic
1.  **Model**: Create `models/StudentRanking.js`.
2.  **Controller**: Create/Update `controllers/analyticsController.js`.
    - `getRankings(req, res)`:
        - Query params: `activity` (default: 'GROUP_DISCUSSION'), `level` (default: 'OVERALL').
        - Logic: Fetch from `StudentRankings` where `activity_type = ?` AND `level = ?` ORDER BY `rank` ASC.
        - If `level` is not provided, maybe return 'OVERALL'.
3.  **Routes**: Update `routes/analyticsRoutes.js`.
    - `GET /rankings` -> `analyticsController.getRankings`

### Seeding
- Update `seed-analytics.js` to clear `StudentRankings` and insert sample data for:
    - Group Discussion: Overall, Beginner, Intermediate, Advanced, Expert.
    - Other activities if needed.

## Verification Plan
1.  Run migrations.
2.  Run seed.
3.  Test API with `curl` or browser.
