# Flutter Authentication Setup - COMPLETE

## Summary of Changes

Your Flutter app now has a complete authentication system integrated with the Flask backend.

### Files Created:
1. **lib/services/api_service.dart** - HTTP client with JWT token management
2. **lib/services/auth_service.dart** - Authentication service wrapper
3. **lib/screens/otp_screen.dart** - OTP verification screen

### Files Updated:
1. **lib/screens/signup_screen.dart** - Added validation, API integration, OTP navigation
2. **lib/screens/login_screen.dart** - Added validation, API integration
3. **lib/screens/upload_scan_screen.dart** - Uses ApiService with JWT token
4. **lib/main.dart** - Added OTPScreen import

## Authentication Flow

### Sign Up Flow:
```
1. User enters: name, email, phone, password
2. Form validation (non-empty, email format, password length)
3. API call to /auth/signup → OTP sent to email
4. Navigate to OTP verification screen
5. User enters 6-digit OTP
6. API call to /auth/verify-otp → JWT token stored locally
7. Navigate to /home (authenticated)
```

### Login Flow:
```
1. User enters: email, password
2. Form validation (non-empty, email format)
3. API call to /auth/login → JWT token returned
4. Token stored in SharedPreferences
5. Navigate directly to /home (authenticated)
```

### Protected API Calls:
- All requests to `/predict`, `/rescan`, `/analysis/history`, `/user/profile`
- Automatically include `Authorization: Bearer <token>` header
- Token retrieved from SharedPreferences by ApiService

## Important Configuration

**CRITICAL: Update the API Base URL**

In `lib/services/api_service.dart`, line 7:
```dart
static const String baseUrl = 'http://192.168.17.1:5000';
```

Change `192.168.17.1` to your **computer's actual IP address** on the network.

To find your computer IP:
- **Windows**: Open Terminal and run `ipconfig` → look for IPv4 Address
- The IP should match what your Android device sees when uploading scans

## Form Validation Rules

### Signup:
- ✓ Name: required, non-empty
- ✓ Email: required, valid format (contains @ and .)
- ✓ Phone: optional
- ✓ Password: required, minimum 6 characters

### Login:
- ✓ Email: required, valid format
- ✓ Password: required, non-empty

**Users CANNOT proceed with blank forms** - buttons disabled until all required fields filled.

## OTP Screen Features

- 6-digit code input field
- Resend OTP button (with 60-second cooldown)
- Error messages for invalid/expired OTPs
- Loading indicator during verification
- Auto-navigate to home on success

## JWT Token Management

- Tokens stored in `SharedPreferences` under key `'jwt_token'`
- Automatically included in all API requests
- Cleared on logout
- 24-hour validity (handled by backend)

## Testing the Integration

### 1. Test Signup:
```
Email: test@example.com
Password: password123
Name: Test User
Phone: 9876543210
```
→ Check your console for the OTP (backend prints it)
→ Enter OTP in the mobile app

### 2. Test Login:
```
Email: test@example.com (from signup)
Password: password123
```
→ Should navigate directly to home

### 3. Test Protected API (Upload Scan):
- Token is automatically included from SharedPreferences
- Upload image → Should work with /predict endpoint

## API Base URL Discovery

If you don't know your computer's IP:

1. **Python Backend Console** - Shows connection IP:
   ```
   192.168.17.141 - - [17/Mar/2026 21:44:31] "POST /auth/signup HTTP/1.1" 201
   ```
   Use that IP in `api_service.dart`

2. **Or manually check**:
   - Windows: `ipconfig` → IPv4 Address
   - Make sure device and computer share same WiFi network

## Troubleshooting

### "Connection error: Connection refused"
- Backend not running
- Wrong IP address in api_service.dart
- Check `python app.py` is running on backend

### "401 Unauthorized" on /predict
- Token not being saved
- Check `SharedPreferences` integration
- Verify signup → OTP → login flow completed

### "Invalid OTP" message
- Check backend console for printed OTP (for development)
- OTP valid for 10 minutes only
- Can resend if expired

### Form validation not working
- Check if required fields are empty
- Buttons should be disabled (grayed out) if validation fails
- Non-empty check: email format check: `name@domain.com`

## Next Steps (Optional)

1. **Add Splash Screen Authentication Check**
   - Check `SharedPreferences` for token on app startup
   - Route to /login if no token, or /home if token exists

2. **Add Logout Button**
   - Call `AuthService.logout()` 
   - Clears token and routes to /login

3. **Add Password Reset**
   - Implement `/auth/forgot-password` endpoint on backend
   - Add forgot password screen

4. **Add Profile Update**
   - Implement PUT `/user/profile` on backend
   - Show profile screen with editable fields

## Files Structure

```
lib/
  services/
    api_service.dart        ← HTTP client with JWT
    auth_service.dart       ← Auth wrapper
    scan_history_service.dart
  screens/
    signup_screen.dart      ✓ Updated
    login_screen.dart       ✓ Updated
    otp_screen.dart         ✓ Created
    upload_scan_screen.dart ✓ Updated
    home_screen.dart
    analysis_result_screen.dart
    history_screen.dart
    profile_screen.dart
  main.dart                 ✓ Updated
```

## Backend Requirements

Backend (app.py) must have:
- ✓ `/auth/signup` (POST) - Creates user, sends OTP
- ✓ `/auth/verify-otp` (POST) - Verifies OTP, returns JWT
- ✓ `/auth/resend-otp` (POST) - Resends OTP
- ✓ `/auth/login` (POST) - Returns JWT token
- ✓ `/predict` (POST, requires JWT) - Analyzes image
- ✓ `/analysis/history` (GET, requires JWT) - Gets past scans
- ✓ `/user/profile` (GET, requires JWT) - Gets user profile

All already implemented in your Flask app.py!

---

## Key Changes Summary

| Component | Change | Why |
|-----------|--------|-----|
| signup_screen.dart | Added form validation | Users can't submit blank forms |
| signup_screen.dart | Added API call | Creates account on backend |
| signup_screen.dart | Navigate to OTP screen | Email verification required |
| login_screen.dart | Added form validation | Email/password required |
| login_screen.dart | Added API call | Authenticate with backend |
| upload_scan_screen.dart | Use ApiService | JWT token automatically included |
| api_service.dart | New file | Centralized API communication |
| auth_service.dart | New file | Authentication business logic |
| otp_screen.dart | New file | OTP verification UI |

---

**Status: COMPLETE ✓**

Your app now has a fully functional authentication system. Users must:
1. Sign up with validation
2. Verify email with OTP
3. Login or proceed after verification
4. All subsequent API calls include JWT token automatically

The 401 errors should now be resolved! 🎉
