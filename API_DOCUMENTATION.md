# CropGuard AI - Complete API Documentation

## Overview
This is a comprehensive Flask API for plant disease detection with user authentication, JWT/OTP verification, database storage, and analysis history tracking.

## Features Implemented
✓ **User Authentication** - Sign up, login with JWT tokens
✓ **OTP Verification** - 6-digit OTP for email verification during sign up
✓ **Database Storage** - SQLite database for users and analysis results
✓ **Rescan Functionality** - Update analysis with new images
✓ **Analysis History** - Paginated history of past predictions
✓ **User Profile** - Get and update user information

---

## Database Schema

### Users Table
```
id (Integer, Primary Key)
email (String, Unique, Indexed)
password_hash (String)
full_name (String)
phone (String)
is_verified (Boolean)
created_at (DateTime)
updated_at (DateTime)
```

### OTP Records Table
```
id (Integer, Primary Key)
user_id (Foreign Key)
otp_code (String)
expires_at (DateTime)
is_used (Boolean)
created_at (DateTime)
```

### Analysis Results Table
```
id (Integer, Primary Key)
user_id (Foreign Key)
image_filename (String)
image_data (Binary)
predicted_disease (String)
clean_name (String)
confidence (Float)
gemini_data (JSON)
created_at (DateTime)
updated_at (DateTime)
```

---

## Authentication Endpoints

### 1. Sign Up
**POST** `/auth/signup`

Request Body:
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "full_name": "John Doe",
  "phone": "+1234567890"
}
```

Response (201):
```json
{
  "success": true,
  "message": "Signup successful. OTP sent to your email.",
  "code": "OTP_SENT",
  "email": "user@example.com"
}
```

**Note:** OTP will be printed in console (for testing). In production, implement email sending via Twilio/SendGrid.

---

### 2. Verify OTP
**POST** `/auth/verify-otp`

Request Body:
```json
{
  "email": "user@example.com",
  "otp": "123456"
}
```

Response (200):
```json
{
  "success": true,
  "message": "Email verified successfully",
  "code": "VERIFIED",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "full_name": "John Doe",
    "phone": "+1234567890",
    "is_verified": true,
    "created_at": "2026-03-17T20:00:00"
  }
}
```

---

### 3. Resend OTP
**POST** `/auth/resend-otp`

Request Body:
```json
{
  "email": "user@example.com"
}
```

Response (200):
```json
{
  "success": true,
  "message": "OTP resent to your email",
  "code": "OTP_SENT"
}
```

---

### 4. Login
**POST** `/auth/login`

Request Body:
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

Response (200):
```json
{
  "success": true,
  "message": "Login successful",
  "code": "LOGIN_SUCCESS",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "full_name": "John Doe",
    "is_verified": true,
    "created_at": "2026-03-17T20:00:00"
  }
}
```

---

### 5. Logout
**POST** `/auth/logout`

Headers:
```
Authorization: Bearer <JWT_TOKEN>
```

Response (200):
```json
{
  "success": true,
  "message": "Logged out successfully",
  "code": "LOGOUT_SUCCESS"
}
```

---

## Prediction Endpoints

All prediction endpoints require JWT authentication via `Authorization: Bearer <token>` header.

### 1. Predict Disease
**POST** `/predict`

Headers:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: multipart/form-data
```

Request Body:
```
image: <binary file>
```

Response (200):
```json
{
  "success": true,
  "analysis_id": 1,
  "disease": "Tomato___Early_blight",
  "clean_name": "Early blight",
  "confidence": 0.9542,
  "gemini_data": {
    "cause": "Fungal disease caused by Alternaria solani...",
    "prevention": "Remove infected leaves, improve air circulation...",
    "treatment": "Apply fungicide sprays...",
    "farming_advice": "Avoid overhead watering..."
  }
}
```

---

### 2. Rescan Analysis (Update with New Image)
**POST** `/rescan/<analysis_id>`

Headers:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: multipart/form-data
```

Request Body:
```
image: <binary file>
```

Response (200):
```json
{
  "success": true,
  "message": "Rescan completed successfully",
  "analysis_id": 1,
  "disease": "Tomato___Late_blight",
  "clean_name": "Late blight",
  "confidence": 0.8765,
  "gemini_data": { ... }
}
```

---

### 3. Get Analysis History
**GET** `/analysis/history?page=1&limit=10`

Headers:
```
Authorization: Bearer <JWT_TOKEN>
```

Response (200):
```json
{
  "success": true,
  "total": 25,
  "page": 1,
  "limit": 10,
  "results": [
    {
      "id": 1,
      "predicted_disease": "Tomato___Early_blight",
      "clean_name": "Early blight",
      "confidence": 0.9542,
      "gemini_data": { ... },
      "created_at": "2026-03-17T20:15:30"
    },
    ...
  ]
}
```

---

### 4. Get Specific Analysis
**GET** `/analysis/<analysis_id>`

Headers:
```
Authorization: Bearer <JWT_TOKEN>
```

Response (200):
```json
{
  "success": true,
  "analysis": {
    "id": 1,
    "predicted_disease": "Tomato___Early_blight",
    "clean_name": "Early blight",
    "confidence": 0.9542,
    "gemini_data": { ... },
    "created_at": "2026-03-17T20:15:30"
  }
}
```

---

## User Profile Endpoints

### 1. Get Profile
**GET** `/user/profile`

Headers:
```
Authorization: Bearer <JWT_TOKEN>
```

Response (200):
```json
{
  "success": true,
  "user": {
    "id": 1,
    "email": "user@example.com",
    "full_name": "John Doe",
    "phone": "+1234567890",
    "is_verified": true,
    "created_at": "2026-03-17T20:00:00"
  }
}
```

---

### 2. Update Profile
**PUT** `/user/profile`

Headers:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

Request Body:
```json
{
  "full_name": "John Updated",
  "phone": "+9876543210"
}
```

Response (200):
```json
{
  "success": true,
  "message": "Profile updated",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "full_name": "John Updated",
    "phone": "+9876543210",
    "is_verified": true,
    "created_at": "2026-03-17T20:00:00"
  }
}
```

---

## Database Initialization

### Initialize Database Tables
**POST** `/init-db`

Response (200):
```json
{
  "success": true,
  "message": "Database initialized successfully"
}
```

**Note:** This is called automatically on server startup, but can be manually triggered if needed.

---

## Error Responses

### 400 Bad Request
```json
{
  "error": "Email and password required",
  "code": "MISSING_FIELDS"
}
```

### 401 Unauthorized
```json
{
  "error": "Token is missing",
  "code": "NO_TOKEN"
}
```

### 403 Forbidden
```json
{
  "error": "Email not verified",
  "code": "NOT_VERIFIED"
}
```

### 404 Not Found
```json
{
  "error": "Analysis not found",
  "code": "NOT_FOUND"
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal server error",
  "code": "SERVER_ERROR"
}
```

---

## JWT Token Structure

Contains:
- `user_id`: User's ID
- `exp`: Expiration time (24 hours from issue)
- `iat`: Issued at time

Bearer Token Format:
```
Authorization: Bearer <token>
```

---

## Security Features

✓ **Password Hashing** - Bcrypt with salt
✓ **JWT Tokens** - HS256 signed, 24-hour expiration
✓ **OTP Verification** - 6-digit codes, 10-minute expiration
✓ **Database Indexed Queries** - Email indexed for fast lookups
✓ **Error Messages** - Generic error codes to prevent info leaks
✓ **Input Validation** - Email format, required fields

---

## Testing Workflow

### 1. Initialize Database
```bash
curl -X POST http://localhost:5000/init-db
```

### 2. Sign Up
```bash
curl -X POST http://localhost:5000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!","full_name":"Test User"}'
```

**Note:** OTP will be printed in console log

### 3. Verify OTP
```bash
curl -X POST http://localhost:5000/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","otp":"123456"}'
```

### 4. Login
```bash
curl -X POST http://localhost:5000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!"}'
```

### 5. Predict with Image
```bash
curl -X POST http://localhost:5000/predict \
  -H "Authorization: Bearer <TOKEN>" \
  -F "image=@/path/to/image.jpg"
```

### 6. Get History
```bash
curl -X GET "http://localhost:5000/analysis/history?page=1&limit=10" \
  -H "Authorization: Bearer <TOKEN>"
```

### 7. Rescan
```bash
curl -X POST http://localhost:5000/rescan/1 \
  -H "Authorization: Bearer <TOKEN>" \
  -F "image=@/path/to/new_image.jpg"
```

---

## Configuration

File: `.env`

```
JWT_SECRET=your-secret-key-change-in-production
GEMINI_API_KEY=AIzaSyAIeKu_yzJDd4xUmfxC4NGYW4BpioZBAs4
FLASK_ENV=development
FLASK_DEBUG=True
```

**In Production:**
- Change `JWT_SECRET` to a strong random key
- Set `FLASK_DEBUG=False`
- Use environment variables instead of .env file
- Implement actual email sending for OTP

---

## Running the Server

```bash
cd "d:\crop detection"
.\venv\Scripts\activate
python app.py
```

Server will start on: `http://0.0.0.0:5000`

Connected devices can access via: `http://<your-computer-ip>:5000`

---

## Database File Location

SQLite database will be created at:
```
d:\crop detection\cropguard.db
```

---

## Future Enhancements

- [ ] Email sending for OTP via Twilio/SendGrid
- [ ] SMS OTP option
- [ ] Password reset flow
- [ ] Admin dashboard
- [ ] Batch predictions
- [ ] Model versioning
- [ ] Analytics and reporting
- [ ] Mobile app notifications

---
