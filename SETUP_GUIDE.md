# CropGuard AI - Setup & Implementation Guide

## What's Been Implemented

### 1. **Full Authentication System**
   - User registration (signup)
   - OTP verification (6-digit code, 10-minute expiry)
   - Secure login with JWT tokens
   - Logout (stateless)
   - Password hashing with bcrypt

### 2. **Database (SQLite)**
   - **Users Table**: Store user credentials, verification status, profile info
   - **OTP Records Table**: Track OTP codes and expiry
   - **Analysis Results Table**: Store predictions, confidence scores, and Gemini insights
   - Auto-initialized on server startup

### 3. **Rescan Functionality**
   - POST `/rescan/<analysis_id>` - Upload new image to update existing analysis
   - Keeps history of analysis and updates in-place
   - Returns updated results with new prediction

### 4. **Analysis History**
   - GET `/analysis/history` - Paginated list of past predictions
   - GET `/analysis/<id>` - View specific analysis result
   - Filters by authenticated user

### 5. **API Security**
   - JWT token-based authentication
   - All prediction/history endpoints require valid token
   - Bearer token format: `Authorization: Bearer <token>`
   - Token expires in 24 hours

---

## File Structure

```
d:\crop detection\
├── app.py                          # Main Flask application
├── .env                            # Configuration (JWT_SECRET, API keys)
├── cropguard.db                    # SQLite database (auto-created)
├── API_DOCUMENTATION.md            # Complete API reference
├── SETUP_GUIDE.md                  # This file
├── plant_disease_mobilenetv2_finetuned.h5  # ML model
└── venv/                           # Python virtual environment
```

---

## Quick Start

### 1. Activate Virtual Environment
```bash
cd "d:\crop detection"
.\venv\Scripts\activate
```

### 2. Start the Server
```bash
python app.py
```

Expected output:
```
[OK] Loaded finetuned model: plant_disease_mobilenetv2_finetuned.h5
[OK] Database tables created
[OK] Starting Flask server...
 * Running on http://0.0.0.0:5000
```

### 3. Initialize Database (First Time Only)
```bash
curl -X POST http://localhost:5000/init-db
```

---

## Testing Workflow

### Step 1: Sign Up
```bash
curl -X POST http://localhost:5000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "farmer@example.com",
    "password": "SecurePass123!",
    "full_name": "John Farmer",
    "phone": "+1234567890"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Signup successful. OTP sent to your email.",
  "code": "OTP_SENT",
  "email": "farmer@example.com"
}
```

**Server Console will show:**
```
[OTP] User farmer@example.com - OTP: 123456 (expires in 10 minutes)
```

### Step 2: Verify OTP
Use the OTP printed in console (during development). In production, it will be sent via email.

```bash
curl -X POST http://localhost:5000/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "email": "farmer@example.com",
    "otp": "123456"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Email verified successfully",
  "code": "VERIFIED",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "email": "farmer@example.com",
    "full_name": "John Farmer",
    "is_verified": true
  }
}
```

**Save the token for next requests!**

### Step 3: Predict Disease
```bash
curl -X POST http://localhost:5000/predict \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -F "image=@C:\path\to\leaf_image.jpg"
```

**Response:**
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

### Step 4: Rescan (Upload New Image)
```bash
curl -X POST http://localhost:5000/rescan/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -F "image=@C:\path\to\new_image.jpg"
```

**Response:** Same format as predict, but with updated data

### Step 5: View History
```bash
curl -X GET "http://localhost:5000/analysis/history?page=1&limit=10" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Response:**
```json
{
  "success": true,
  "total": 5,
  "page": 1,
  "limit": 10,
  "results": [
    {
      "id": 1,
      "predicted_disease": "Tomato___Early_blight",
      "clean_name": "Early blight",
      "confidence": 0.9542,
      "gemini_data": {...},
      "created_at": "2026-03-17T20:15:30"
    }
  ]
}
```

### Step 6: Login (Next Session)
```bash
curl -X POST http://localhost:5000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "farmer@example.com",
    "password": "SecurePass123!"
  }'
```

---

## Mobile App Integration

For your Flutter app (`cropguard_ai`):

### 1. Update API Base URL
```dart
final String baseUrl = 'http://<YOUR_COMPUTER_IP>:5000';
```

### 2. Implement Sign Up Flow
```dart
Future<void> signup(String email, String password, String fullName) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/signup'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
      'full_name': fullName,
    }),
  );
  // Handle response...
}
```

### 3. Store JWT Token Locally
```dart
import 'package:shared_preferences/shared_preferences.dart';

final prefs = await SharedPreferences.getInstance();
await prefs.setString('jwt_token', token);
```

### 4. Use Token in Requests
```dart
final token = prefs.getString('jwt_token');
final response = await http.post(
  Uri.parse('$baseUrl/predict'),
  headers: {
    'Authorization': 'Bearer $token',
  },
  body: formData,
);
```

---

## Database Details

### Users Table
- Stores email, password hash, name, phone, verification status
- Email is unique and indexed for fast lookups
- Timestamps for created/updated dates

### OTP Records Table
- Links to Users via user_id
- OTP code valid for 10 minutes
- One-time use (marked as is_used after verification)

### Analysis Results Table
- Links to Users via user_id
- Stores image filename, ML prediction, confidence
- Stores JSON data from Gemini API
- Timestamps for created/updated dates

---

## Configuration (.env File)

```
JWT_SECRET=your-secret-key-change-in-production
GEMINI_API_KEY=AIzaSyAIeKu_yzJDd4xUmfxC4NGYW4BpioZBAs4
FLASK_ENV=development
FLASK_DEBUG=True
```

### Production Changes:
```
JWT_SECRET=<generate-strong-random-key>
GEMINI_API_KEY=<your-actual-api-key>
FLASK_ENV=production
FLASK_DEBUG=False
```

---

## Security Checklist

Before deploying to production:

✓ Change `JWT_SECRET` to a strong random key
✓ Use actual Gemini API key from Google Cloud
✓ Set `FLASK_DEBUG=False`
✓ Implement email sending for OTP (Twilio/SendGrid)
✓ Use HTTPS instead of HTTP
✓ Set up proper CORS headers if needed
✓ Implement rate limiting
✓ Backup database regularly
✓ Use environment variables instead of .env

---

## Troubleshooting

### Database Issues
```bash
# Remove old database to start fresh
del cropguard.db

# Restart server - new DB will be created
python app.py
```

### Module Import Errors
```bash
# Ensure all packages are installed
pip install flask flask-sqlalchemy pyjwt python-dotenv bcrypt twilio

# Check specific package
pip show flask-sqlalchemy
```

### JWT Token Expired
```
Error: "Token has expired" (401)
Solution: Login again to get new token
```

### OTP Expired
```
Error: "OTP expired" (400)
Solution: Request resend-otp, OTP valid for 10 minutes
```

### User Already Verified
```
Error: "User already verified" (400)
Solution: Use login endpoint instead of verify-otp
```

---

## API Endpoints Summary

### Authentication
- `POST /auth/signup` - Register new user
- `POST /auth/verify-otp` - Verify OTP → Get JWT token
- `POST /auth/resend-otp` - Resend OTP
- `POST /auth/login` - Login with email/password
- `POST /auth/logout` - Logout (stateless)

### Predictions (Requires JWT)
- `POST /predict` - Predict disease from image
- `POST /rescan/<id>` - Update analysis with new image
- `GET /analysis/history` - Get past predictions
- `GET /analysis/<id>` - Get specific prediction

### User Profile (Requires JWT)
- `GET /user/profile` - Get user info
- `PUT /user/profile` - Update profile

### Admin
- `POST /init-db` - Initialize database

---

## Next Steps

1. **Test the API** using the workflows above
2. **Integrate with Flutter app** for mobile interface
3. **Set up email sending** for OTP delivery
4. **Configure production deployment** (change secrets, HTTPS, etc.)
5. **Add more disease data** to fallback database if needed
6. **Monitor logs** for errors and usage patterns

---

## Support & Documentation

- Full API docs: See `API_DOCUMENTATION.md`
- Code comments in `app.py`
- SQLAlchemy ORM docs: https://docs.sqlalchemy.org/
- Flask docs: https://flask.palletsprojects.com/
- JWT docs: https://tools.ietf.org/html/rfc7519

---
