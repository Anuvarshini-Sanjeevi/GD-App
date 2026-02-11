# Task: Implement Student Rankings & Analytics

- [x] Planning & Design
    - [x] Analyze existing schema and models <!-- id: 0 -->
    - [x] Create implementation plan <!-- id: 1 -->
- [x] Database Implementation
    - [x] Create migration to drop `AdminAnalytics` and create `StudentRankings` <!-- id: 2 -->
    - [x] Create `StudentRanking` Sequelize model <!-- id: 3 -->
    - [x] Run migrations <!-- id: 4 -->
- [x] Backend Logic
    - [x] Create/Update Analytics Controller to fetch rankings <!-- id: 5 -->
    - [x] Create/Update Analytics Routes (`GET /api/analytics/rankings`) <!-- id: 6 -->
- [x] Data Seeding
    - [x] Update `seed-analytics.js` to populate `StudentRankings` with sample data for all levels and activities <!-- id: 7 -->
    - [x] Run seed script <!-- id: 8 -->
- [x] Verification
    - [x] verify API returns correct data for "Group Discussion" (Overall) <!-- id: 9 -->
    - [x] verify API returns correct data for "Beginner", "Intermediate", etc. <!-- id: 10 -->
