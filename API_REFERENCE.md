# Admin API CURL Commands

**Base URL**: `http://localhost:8080/api`

---

## Authentication

### Register
```bash
curl -X POST http://localhost:8080/auth/register \
-H "Content-Type: application/json" \
-d '{"name": "New User", "email": "user@example.com", "password": "password123"}'
```

### Login
```bash
curl -X POST http://localhost:8080/auth/login \
-H "Content-Type: application/json" \
-d '{"email": "admin@example.com", "password": "password123"}'
```

### Get Logged-in User Profile
**URL**: `/auth/me`
**Method**: `GET`
**Headers**: `Authorization: Bearer <token>`

Returns details of the currently logged-in user. For students, this includes:
- `roll_number`, `batch`
- `experience_points`
- `rank` (Fetched from rankings)

```bash
curl -X GET http://localhost:8080/auth/me \
-H "Authorization: Bearer <YOUR_TOKEN_HERE>"
```

---

## Users

### Create User
```bash
curl -X POST http://localhost:8080/api/users \
-H "Content-Type: application/json" \
-d '{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "role": "student",
  "phone": "9876543210",
  "location": "Headquarters",
  "department": "Computer Science & Engineering"
}'
```

### Get All Users
```bash
curl -X GET http://localhost:8080/api/users
```

### Get User by ID
```bash
curl -X GET http://localhost:8080/api/users/1
```

### Update User
```bash
curl -X PUT http://localhost:8080/api/users/1 \
-H "Content-Type: application/json" \
-d '{
  "current_level": 2,
  "phone": "1234567890",
  "location": "Campus A"
}'
```

### Delete User
```bash
curl -X DELETE http://localhost:8080/api/users/1
```

---

## Admins

### Create Admin
```bash
curl -X POST http://localhost:8080/api/admins \
-H "Content-Type: application/json" \
-d '{"name": "Super Admin", "email": "admin@example.com", "password_hash": "secret", "is_active": true}'
```

### Get All Admins
```bash
curl -X GET http://localhost:8080/api/admins
```

### Get Admin by ID
```bash
curl -X GET http://localhost:8080/api/admins/1
```

### Update Admin
```bash
curl -X PUT http://localhost:8080/api/admins/1 \
-H "Content-Type: application/json" \
-d '{"phone": "9876543210"}'
```

### Delete Admin
```bash
curl -X DELETE http://localhost:8080/api/admins/1
```

---

## Hall QR Tokens

### Create Token
```bash
curl -X POST http://localhost:8080/api/hall-qr-tokens \
-H "Content-Type: application/json" \
-d '{"hall_qr_token": "TOKEN_ABC_123", "session_id": 101, "created_by_admin_id": 1, "expires_in_minutes": 60}'
```

### Get All Tokens
```bash
curl -X GET http://localhost:8080/api/hall-qr-tokens
```

---

## Session Configs

### Create Config
**Note**: If `activity_type` is provided, the session will automatically inherit default values (Time Limit, Max Capacity, Weights, etc.) from the **Calibration Panel** for that activity.

```bash
curl -X POST http://localhost:8080/api/session-configs \
-H "Content-Type: application/json" \
-d '{
  "session_id": 101, 
  "activity_type": "GROUP_DISCUSSION",
  "created_by_admin_id": 1, 
  "status": "ACTIVE",
  "protocol": "Hybrid Protocol",
  "start_time": "11:44 AM",
  "complexity_level": "L1"
}'
```

### Get All Configs
```bash
curl -X GET http://localhost:8080/api/session-configs
```

### Get Active Sessions (For Students)
Fetch sessions that are currently in `ACTIVE` state.
```bash
curl -X GET http://localhost:8080/api/session-configs/active
```

---

## Question Bank

### Create Question
```bash
curl -X POST http://localhost:8080/api/question-bank \
-H "Content-Type: application/json" \
-d '{"admin_id": 1, "question_text": "What is the capital of France?", "active": true}'
```

### Get All Questions
```bash
curl -X GET http://localhost:8080/api/question-bank
```

---

## Admin Analytics (Rankings)

**Note**: The legacy `AdminAnalytics` table has been replaced by `StudentRankings`.

### Get Rankings
Fetch leaderboard data filtered by Activity and Level.

**Table Filters**:
- **Activity**: `GROUP_DISCUSSION`, `TECHNICAL_EVENTS`, `PRESENTATION`, `CASE_STUDY`, `DEBATE_CLUB` (Default: `GROUP_DISCUSSION`)
- **Level**: `BEGINNER`, `INTERMEDIATE`, `ADVANCED`, `EXPERT`, `OVERALL` (Default: `OVERALL`)

```bash
curl -X GET "http://localhost:8080/api/admin-analytics/rankings?activity=GROUP_DISCUSSION&level=OVERALL"
```

---

## Admin Activity Log

### Create Log
```bash
curl -X POST http://localhost:8080/api/admin-activity-logs \
-H "Content-Type: application/json" \
-d '{"admin_id": 1, "action_type": "LOGIN", "details": {"ip": "192.168.1.1"}}'
```

### Get All Logs
```bash
curl -X GET http://localhost:8080/api/admin-activity-logs
```

---

## Activity Settings (Calibration Panel)

### Get All Activity Settings
```bash
curl -X GET http://localhost:8080/api/activity-settings
```

### Get Settings for Specific Activity
**Types**: `GROUP_DISCUSSION`, `TECHNICAL_EVENTS`, `PRESENTATION`, `CASE_STUDY`, `DEBATE_CLUB`
```bash
curl -X GET http://localhost:8080/api/activity-settings/GROUP_DISCUSSION
```

### Update Activity Settings
```bash
curl -X PUT http://localhost:8080/api/activity-settings/GROUP_DISCUSSION \
-H "Content-Type: application/json" \
-d '{
  "advancement_pts": 90,
  "time_limit_min": 50,
  "auto_rewards": false
}'
```

---

## Student Activities

### Get Student Activity Progress
Returns all activities with the logged-in student's progress and levels.

**URL**: `/api/student/activities`
**Method**: `GET`
**Headers**: `Authorization: Bearer <token>`

**Response Example**:
```json
[
  {
    "activity_type": "GROUP_DISCUSSION",
    "name": "Group Discussion",
    "category": "Collaboration",
    "total_levels": 10,
    "completed_levels": 3,
    "progress_percent": 30,
    "status": "PENDING"
  }
]
```

### Update Student Activity Progress
Updates the number of completed levels for a specific activity for the logged-in student.

**URL**: `/api/student/activities/update`
**Method**: `POST`
**Headers**:
- `Authorization: Bearer <token>`
- `Content-Type: application/json`

**Body**:
```json
{
  "activity_type": "GROUP_DISCUSSION",
  "completed_levels": 5
}
```

