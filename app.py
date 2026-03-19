from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from functools import wraps
import cv2
import numpy as np
import tensorflow as tf
try:
    from tensorflow.keras.models import load_model
    from tensorflow.keras.applications.mobilenet_v2 import preprocess_input
except ImportError:
    from keras.models import load_model
    from keras.applications.mobilenet_v2 import preprocess_input
import google.generativeai as genai
import json
import time
import re
import jwt
import bcrypt
import random
import string
from datetime import datetime, timedelta
from twilio.rest import Client
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

app = Flask(__name__)

# Database Configuration
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///cropguard.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['JWT_SECRET'] = os.getenv('JWT_SECRET', 'your-secret-key-change-in-production')

db = SQLAlchemy(app)

# Configure Gemini
genai.configure(api_key=os.getenv('GEMINI_API_KEY', 'AIzaSyAIeKu_yzJDd4xUmfxC4NGYW4BpioZBAs4'))

# Configure Twilio
TWILIO_ACCOUNT_SID = os.getenv('TWILIO_ACCOUNT_SID')
TWILIO_AUTH_TOKEN = os.getenv('TWILIO_AUTH_TOKEN')
TWILIO_PHONE_NUMBER = os.getenv('TWILIO_PHONE_NUMBER', '+12133205276')

if TWILIO_ACCOUNT_SID and TWILIO_AUTH_TOKEN:
    twilio_client = Client(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
    print("[OK] Twilio configured successfully")
else:
    twilio_client = None
    print("[WARNING] Twilio credentials not found in .env file")

# Load trained model
try:
    model = load_model("plant_disease_mobilenetv2_finetuned.h5")
    print("[OK] Loaded finetuned model: plant_disease_mobilenetv2_finetuned.h5")
except Exception as e:
    print(f"[WARNING] Finetuned model not found, loading base model: {e}")
    model = load_model("plant_disease_mobilenetv2.h5")

# Disease class names
class_names = [
    'Apple___Apple_scab', 'Apple___Black_rot', 'Apple___Cedar_apple_rust', 'Apple___healthy',
    'Blueberry___healthy', 'Cherry_(including_sour)___Powdery_mildew', 'Cherry_(including_sour)___healthy',
    'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot', 'Corn_(maize)___Common_rust_',
    'Corn_(maize)___Northern_Leaf_Blight', 'Corn_(maize)___healthy',
    'Grape___Black_rot', 'Grape___Esca_(Black_Measles)', 'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)',
    'Grape___healthy', 'Orange___Haunglongbing_(Citrus_greening)', 'Peach___Bacterial_spot',
    'Peach___healthy', 'Pepper,_bell___Bacterial_spot', 'Pepper,_bell___healthy',
    'Potato___Early_blight', 'Potato___Late_blight', 'Potato___healthy',
    'Raspberry___healthy', 'Soybean___healthy', 'Squash___Powdery_mildew',
    'Strawberry___Leaf_scorch', 'Strawberry___healthy',
    'Tomato___Bacterial_spot', 'Tomato___Early_blight', 'Tomato___Late_blight',
    'Tomato___Leaf_Mold', 'Tomato___Septoria_leaf_spot',
    'Tomato___Spider_mites Two-spotted_spider_mite', 'Tomato___Target_Spot',
    'Tomato___Tomato_Yellow_Leaf_Curl_Virus', 'Tomato___Tomato_mosaic_virus',
    'Tomato___healthy'
]

# ==================== DATABASE MODELS ====================

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(255), nullable=False)
    full_name = db.Column(db.String(120), nullable=True)
    phone = db.Column(db.String(20), nullable=True)
    is_verified = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    analysis_results = db.relationship('AnalysisResult', backref='user', lazy=True, cascade='all, delete-orphan')
    otp_records = db.relationship('OTPRecord', backref='user', lazy=True, cascade='all, delete-orphan')
    
    def set_password(self, password):
        """Hash and set password"""
        self.password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    
    def check_password(self, password):
        """Verify password against hash"""
        return bcrypt.checkpw(password.encode('utf-8'), self.password_hash.encode('utf-8'))
    
    def to_dict(self):
        return {
            'id': self.id,
            'email': self.email,
            'full_name': self.full_name,
            'phone': self.phone,
            'is_verified': self.is_verified,
            'created_at': self.created_at.isoformat()
        }


class OTPRecord(db.Model):
    __tablename__ = 'otp_records'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    otp_code = db.Column(db.String(6), nullable=False)
    expires_at = db.Column(db.DateTime, nullable=False)
    is_used = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def is_valid(self):
        """Check if OTP is valid (not expired and not used)"""
        return not self.is_used and datetime.utcnow() < self.expires_at
    
    def mark_used(self):
        """Mark OTP as used"""
        self.is_used = True
        db.session.commit()


class AnalysisResult(db.Model):
    __tablename__ = 'analysis_results'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    image_filename = db.Column(db.String(255), nullable=True)
    image_data = db.Column(db.LargeBinary, nullable=True)
    predicted_disease = db.Column(db.String(255), nullable=False)
    clean_name = db.Column(db.String(255), nullable=False)
    confidence = db.Column(db.Float, nullable=False)
    gemini_data = db.Column(db.JSON, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'predicted_disease': self.predicted_disease,
            'clean_name': self.clean_name,
            'confidence': self.confidence,
            'gemini_data': self.gemini_data,
            'created_at': self.created_at.isoformat()
        }



# ==================== AUTHENTICATION MIDDLEWARE ====================

def token_required(f):
    """Decorator to require JWT token"""
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        
        if not token:
            return jsonify({'error': 'Token is missing', 'code': 'NO_TOKEN'}), 401
        
        try:
            # Extract token from "Bearer <token>"
            if token.startswith('Bearer '):
                token = token[7:]
            
            payload = jwt.decode(token, app.config['JWT_SECRET'], algorithms=['HS256'])
            user_id = payload.get('user_id')
            
            if not user_id:
                return jsonify({'error': 'Invalid token', 'code': 'INVALID_TOKEN'}), 401
            
            user = User.query.get(user_id)
            if not user:
                return jsonify({'error': 'User not found', 'code': 'USER_NOT_FOUND'}), 401
            
            request.current_user = user
            request.current_user_id = user_id
            
        except jwt.ExpiredSignatureError:
            return jsonify({'error': 'Token has expired', 'code': 'TOKEN_EXPIRED'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Invalid token', 'code': 'INVALID_TOKEN'}), 401
        
        return f(*args, **kwargs)
    
    return decorated


def generate_jwt_token(user_id, expires_in_hours=24):
    """Generate JWT token"""
    payload = {
        'user_id': user_id,
        'exp': datetime.utcnow() + timedelta(hours=expires_in_hours),
        'iat': datetime.utcnow()
    }
    return jwt.encode(payload, app.config['JWT_SECRET'], algorithm='HS256')


def generate_otp(length=6):
    """Generate random OTP"""
    return ''.join(random.choices(string.digits, k=length))


def send_otp_sms(phone_number, otp_code):
    """Send OTP via Twilio SMS"""
    try:
        if not twilio_client:
            print(f"[WARNING] Twilio not configured. OTP: {otp_code}")
            return False
        
        message = twilio_client.messages.create(
            body=f"Your CropGuard AI verification code is: {otp_code}. Valid for 10 minutes.",
            from_=TWILIO_PHONE_NUMBER,
            to=phone_number
        )
        print(f"[SMS] OTP sent to {phone_number} | Message ID: {message.sid}")
        return True
    except Exception as e:
        print(f"[ERROR] Failed to send SMS to {phone_number}: {e}")
        return False


# ==================== AUTHENTICATION ROUTES ====================

@app.route('/auth/signup', methods=['POST'])
def signup():
    """
    Sign up a new user
    Request: {email, password, full_name (optional), phone (optional)}
    Response: OTP sent to email
    """
    try:
        data = request.get_json()
        
        if not data or not data.get('email') or not data.get('password'):
            return jsonify({'error': 'Email and password required', 'code': 'MISSING_FIELDS'}), 400
        
        email = data.get('email').lower().strip()
        password = data.get('password')
        full_name = data.get('full_name', '')
        phone = data.get('phone', '')
        
        # Validate email format
        if '@' not in email or '.' not in email:
            return jsonify({'error': 'Invalid email format', 'code': 'INVALID_EMAIL'}), 400
        
        # Check if user exists
        existing_user = User.query.filter_by(email=email).first()
        if existing_user:
            return jsonify({'error': 'Email already registered', 'code': 'EMAIL_EXISTS'}), 400
        
        # Create new user
        user = User(email=email, full_name=full_name, phone=phone)
        user.set_password(password)
        
        db.session.add(user)
        db.session.commit()
        
        # Generate and save OTP
        otp_code = generate_otp()
        otp_expires = datetime.utcnow() + timedelta(minutes=10)
        
        otp_record = OTPRecord(user_id=user.id, otp_code=otp_code, expires_at=otp_expires)
        db.session.add(otp_record)
        db.session.commit()
        
        # Send OTP via SMS if phone number provided
        sms_sent = False
        if phone:
            # Format phone number (add +91 for India if not already formatted)
            formatted_phone = phone if phone.startswith('+') else f"+91{phone}"
            sms_sent = send_otp_sms(formatted_phone, otp_code)
        
        if not sms_sent:
            print(f"[OTP] User {email} - OTP: {otp_code} (expires in 10 minutes)")
        
        return jsonify({
            'success': True,
            'message': 'Signup successful. OTP sent to your phone.' if sms_sent else 'Signup successful. OTP sent to your email.',
            'code': 'OTP_SENT',
            'email': email,
            'otp': otp_code  # For development only - remove in production!
        }), 201
    
    except Exception as e:
        print(f"[ERROR] Signup error: {e}")
        return jsonify({'error': str(e), 'code': 'SIGNUP_ERROR'}), 500


@app.route('/auth/verify-otp', methods=['POST'])
def verify_otp():
    """
    Verify OTP for email verification
    Request: {email, otp}
    Response: JWT token
    """
    try:
        data = request.get_json()
        
        if not data or not data.get('email') or not data.get('otp'):
            return jsonify({'error': 'Email and OTP required', 'code': 'MISSING_FIELDS'}), 400
        
        email = data.get('email').lower().strip()
        otp = data.get('otp')
        
        # Find user
        user = User.query.filter_by(email=email).first()
        if not user:
            return jsonify({'error': 'User not found', 'code': 'USER_NOT_FOUND'}), 404
        
        # Check if already verified
        if user.is_verified:
            return jsonify({'error': 'User already verified', 'code': 'ALREADY_VERIFIED'}), 400
        
        # Find valid OTP
        otp_record = OTPRecord.query.filter_by(user_id=user.id, otp_code=otp).order_by(OTPRecord.created_at.desc()).first()
        
        if not otp_record:
            return jsonify({'error': 'Invalid OTP', 'code': 'INVALID_OTP'}), 400
        
        if not otp_record.is_valid():
            return jsonify({'error': 'OTP expired', 'code': 'OTP_EXPIRED'}), 400
        
        # Mark user as verified
        user.is_verified = True
        otp_record.mark_used()
        db.session.commit()
        
        # Generate JWT token
        token = generate_jwt_token(user.id)
        
        return jsonify({
            'success': True,
            'message': 'Email verified successfully',
            'code': 'VERIFIED',
            'token': token,
            'user': user.to_dict()
        }), 200
    
    except Exception as e:
        print(f"[ERROR] OTP verification error: {e}")
        return jsonify({'error': str(e), 'code': 'VERIFY_ERROR'}), 500


@app.route('/auth/resend-otp', methods=['POST'])
def resend_otp():
    """
    Resend OTP to user email
    Request: {email}
    Response: OTP sent message
    """
    try:
        data = request.get_json()
        
        if not data or not data.get('email'):
            return jsonify({'error': 'Email required', 'code': 'MISSING_EMAIL'}), 400
        
        email = data.get('email').lower().strip()
        user = User.query.filter_by(email=email).first()
        
        if not user:
            return jsonify({'error': 'User not found', 'code': 'USER_NOT_FOUND'}), 404
        
        if user.is_verified:
            return jsonify({'error': 'User already verified', 'code': 'ALREADY_VERIFIED'}), 400
        
        # Generate new OTP
        otp_code = generate_otp()
        otp_expires = datetime.utcnow() + timedelta(minutes=10)
        
        otp_record = OTPRecord(user_id=user.id, otp_code=otp_code, expires_at=otp_expires)
        db.session.add(otp_record)
        db.session.commit()
        
        # Send OTP via SMS if phone number available
        sms_sent = False
        if user.phone:
            formatted_phone = user.phone if user.phone.startswith('+') else f"+91{user.phone}"
            sms_sent = send_otp_sms(formatted_phone, otp_code)
        
        if not sms_sent:
            print(f"[OTP] User {email} - OTP: {otp_code} (expires in 10 minutes)")
        
        return jsonify({
            'success': True,
            'message': 'OTP resent to your phone' if sms_sent else 'OTP resent to your email',
            'code': 'OTP_SENT'
        }), 200
    
    except Exception as e:
        print(f"[ERROR] Resend OTP error: {e}")
        return jsonify({'error': str(e), 'code': 'RESEND_ERROR'}), 500


@app.route('/auth/login', methods=['POST'])
def login():
    """
    Login user with email and password
    Request: {email, password}
    Response: JWT token
    """
    try:
        data = request.get_json()
        
        if not data or not data.get('email') or not data.get('password'):
            return jsonify({'error': 'Email and password required', 'code': 'MISSING_FIELDS'}), 400
        
        email = data.get('email').lower().strip()
        password = data.get('password')
        
        user = User.query.filter_by(email=email).first()
        
        if not user:
            return jsonify({'error': 'Invalid email or password', 'code': 'INVALID_CREDENTIALS'}), 401
        
        if not user.is_verified:
            return jsonify({'error': 'Email not verified', 'code': 'NOT_VERIFIED'}), 403
        
        if not user.check_password(password):
            return jsonify({'error': 'Invalid email or password', 'code': 'INVALID_CREDENTIALS'}), 401
        
        # Generate JWT token
        token = generate_jwt_token(user.id)
        
        return jsonify({
            'success': True,
            'message': 'Login successful',
            'code': 'LOGIN_SUCCESS',
            'token': token,
            'user': user.to_dict()
        }), 200
    
    except Exception as e:
        print(f"[ERROR] Login error: {e}")
        return jsonify({'error': str(e), 'code': 'LOGIN_ERROR'}), 500


@app.route('/auth/logout', methods=['POST'])
@token_required
def logout():
    """
    Logout user (JWT tokens are stateless, so just return success)
    """
    return jsonify({
        'success': True,
        'message': 'Logged out successfully',
        'code': 'LOGOUT_SUCCESS'
    }), 200


# ==================== PREDICTION ROUTES ====================

@app.route('/predict', methods=['POST'])
@token_required
def predict():
    """
    Predict disease from image and store result
    """
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'No image part in the request'}), 400
        
        file = request.files['image']
        
        if file.filename == '':
            return jsonify({'error': 'No selected file'}), 400

        # Read image
        file_bytes = np.frombuffer(file.read(), np.uint8)
        img = cv2.imdecode(file_bytes, cv2.IMREAD_COLOR)

        if img is None:
            return jsonify({'error': 'Failed to read image'}), 400

        # Process image
        img = cv2.resize(img, (224, 224))
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        img_array = preprocess_input(img)
        img_batch = np.expand_dims(img_array, axis=0)

        # Predict
        prediction = model.predict(img_batch, verbose=0)
        class_index = int(np.argmax(prediction[0]))
        confidence = float(np.max(prediction[0]))
        predicted_disease = class_names[class_index]
        clean_disease_name = predicted_disease.split('___')[-1].replace('_', ' ')
        
        # Fetch Gemini info
        prompt = f"""You are a plant pathology expert. A crop disease has been identified as: {clean_disease_name}.
Provide the response ONLY as valid JSON (no markdown, no code blocks) with these exact keys:
{{"cause": "A brief explanation of what causes the disease", "prevention": "A brief explanation of how to prevent it", "treatment": "A brief explanation of how to treat it", "farming_advice": "Some general farming advice related to this"}}
Keep text concise, informative, and professional. Return ONLY valid JSON, nothing else."""
        
        gemini_data = fetch_gemini_info(clean_disease_name, prompt)

        # Store analysis result
        analysis = AnalysisResult(
            user_id=request.current_user_id,
            image_filename=file.filename,
            predicted_disease=predicted_disease,
            clean_name=clean_disease_name,
            confidence=confidence,
            gemini_data=gemini_data
        )
        
        db.session.add(analysis)
        db.session.commit()

        return jsonify({
            'success': True,
            'analysis_id': analysis.id,
            'disease': predicted_disease,
            'clean_name': clean_disease_name,
            'confidence': round(confidence, 4),
            'gemini_data': gemini_data
        }), 200

    except Exception as e:
        print(f"[ERROR] Prediction error: {e}")
        db.session.rollback()
        return jsonify({'error': str(e)}), 500


@app.route('/rescan/<int:analysis_id>', methods=['POST'])
@token_required
def rescan(analysis_id):
    """
    Rescan with new image (replaces previous image in same analysis)
    """
    try:
        # Get previous analysis
        analysis = AnalysisResult.query.filter_by(id=analysis_id, user_id=request.current_user_id).first()
        
        if not analysis:
            return jsonify({'error': 'Analysis not found', 'code': 'NOT_FOUND'}), 404
        
        if 'image' not in request.files:
            return jsonify({'error': 'No image part in the request'}), 400
        
        file = request.files['image']
        
        if file.filename == '':
            return jsonify({'error': 'No selected file'}), 400

        # Read image
        file_bytes = np.frombuffer(file.read(), np.uint8)
        img = cv2.imdecode(file_bytes, cv2.IMREAD_COLOR)

        if img is None:
            return jsonify({'error': 'Failed to read image'}), 400

        # Process image
        img = cv2.resize(img, (224, 224))
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        img_array = preprocess_input(img)
        img_batch = np.expand_dims(img_array, axis=0)

        # Predict
        prediction = model.predict(img_batch, verbose=0)
        class_index = int(np.argmax(prediction[0]))
        confidence = float(np.max(prediction[0]))
        predicted_disease = class_names[class_index]
        clean_disease_name = predicted_disease.split('___')[-1].replace('_', ' ')
        
        # Fetch Gemini info
        prompt = f"""You are a plant pathology expert. A crop disease has been identified as: {clean_disease_name}.
Provide the response ONLY as valid JSON (no markdown, no code blocks) with these exact keys:
{{"cause": "A brief explanation of what causes the disease", "prevention": "A brief explanation of how to prevent it", "treatment": "A brief explanation of how to treat it", "farming_advice": "Some general farming advice related to this"}}
Keep text concise, informative, and professional. Return ONLY valid JSON, nothing else."""
        
        gemini_data = fetch_gemini_info(clean_disease_name, prompt)

        # Update analysis
        analysis.image_filename = file.filename
        analysis.predicted_disease = predicted_disease
        analysis.clean_name = clean_disease_name
        analysis.confidence = confidence
        analysis.gemini_data = gemini_data
        analysis.updated_at = datetime.utcnow()
        
        db.session.commit()

        return jsonify({
            'success': True,
            'message': 'Rescan completed successfully',
            'analysis_id': analysis.id,
            'disease': predicted_disease,
            'clean_name': clean_disease_name,
            'confidence': round(confidence, 4),
            'gemini_data': gemini_data
        }), 200

    except Exception as e:
        print(f"[ERROR] Rescan error: {e}")
        db.session.rollback()
        return jsonify({'error': str(e)}), 500


@app.route('/analysis/history', methods=['GET'])
@token_required
def get_analysis_history():
    """
    Get user's analysis history
    """
    try:
        page = request.args.get('page', 1, type=int)
        limit = request.args.get('limit', 10, type=int)
        
        analyses = AnalysisResult.query.filter_by(user_id=request.current_user_id)\
            .order_by(AnalysisResult.created_at.desc())\
            .paginate(page=page, per_page=limit)
        
        return jsonify({
            'success': True,
            'total': analyses.total,
            'page': page,
            'limit': limit,
            'results': [a.to_dict() for a in analyses.items]
        }), 200
    
    except Exception as e:
        print(f"[ERROR] History error: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/analysis/<int:analysis_id>', methods=['GET'])
@token_required
def get_analysis(analysis_id):
    """
    Get specific analysis result
    """
    try:
        analysis = AnalysisResult.query.filter_by(id=analysis_id, user_id=request.current_user_id).first()
        
        if not analysis:
            return jsonify({'error': 'Analysis not found', 'code': 'NOT_FOUND'}), 404
        
        return jsonify({
            'success': True,
            'analysis': analysis.to_dict()
        }), 200
    
    except Exception as e:
        print(f"[ERROR] Get analysis error: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/user/profile', methods=['GET'])
@token_required
def get_profile():
    """
    Get user profile
    """
    try:
        user = request.current_user
        return jsonify({
            'success': True,
            'user': user.to_dict()
        }), 200
    
    except Exception as e:
        print(f"[ERROR] Profile error: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/user/profile', methods=['PUT'])
@token_required
def update_profile():
    """
    Update user profile
    """
    try:
        data = request.get_json()
        user = request.current_user
        
        if 'full_name' in data:
            user.full_name = data['full_name']
        if 'phone' in data:
            user.phone = data['phone']
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Profile updated',
            'user': user.to_dict()
        }), 200
    
    except Exception as e:
        print(f"[ERROR] Update profile error: {e}")
        db.session.rollback()
        return jsonify({'error': str(e)}), 500



# ==================== GEMINI HELPER FUNCTIONS ====================

def fetch_gemini_info(disease_name, prompt, max_retries=3):
    """Fetch disease information from Gemini API with retry logic"""
    for attempt in range(max_retries):
        try:
            print(f"[ATTEMPT] Gemini API call (attempt {attempt + 1}/{max_retries}) for: {disease_name}")
            
            gemini_model = genai.GenerativeModel('gemini-1.5-flash')
            response = gemini_model.generate_content(
                prompt,
                generation_config=genai.types.GenerationConfig(
                    temperature=0.3,
                    top_p=0.8,
                    top_k=40,
                ),
                timeout=30
            )
            
            if not response or not response.text:
                print(f"[WARNING] Empty response from Gemini (attempt {attempt + 1})")
                time.sleep(1)
                continue
            
            response_text = response.text.strip()
            gemini_data = parse_json_response(response_text)
            
            if gemini_data:
                print(f"[OK] Successfully fetched Gemini data for: {disease_name}")
                return gemini_data
            else:
                print(f"[WARNING] Failed to parse JSON (attempt {attempt + 1})")
                if attempt < max_retries - 1:
                    time.sleep(2)
                continue
                
        except Exception as e:
            print(f"[ERROR] Gemini API error (attempt {attempt + 1}): {type(e).__name__}: {e}")
            if attempt < max_retries - 1:
                time.sleep(2)
            continue
    
    print(f"[FALLBACK] All Gemini API retries failed for {disease_name}, using fallback")
    return generate_fallback_data(disease_name)


def parse_json_response(response_text):
    """Parse JSON from Gemini response with multiple fallback strategies"""
    try:
        return json.loads(response_text)
    except json.JSONDecodeError:
        pass
    
    try:
        match = re.search(r'```(?:json)?\s*({.*?})\s*```', response_text, re.DOTALL)
        if match:
            json_str = match.group(1)
            return json.loads(json_str)
    except (json.JSONDecodeError, AttributeError):
        pass
    
    try:
        match = re.search(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}', response_text)
        if match:
            json_str = match.group(0)
            return json.loads(json_str)
    except (json.JSONDecodeError, AttributeError):
        pass
    
    try:
        cleaned = response_text.strip()
        if cleaned.startswith('```'):
            cleaned = re.sub(r'^```(?:json)?', '', cleaned)
            cleaned = re.sub(r'```$', '', cleaned)
            cleaned = cleaned.strip()
        return json.loads(cleaned)
    except json.JSONDecodeError:
        pass
    
    print(f"[WARNING] Could not parse JSON from: {response_text[:100]}...")
    return None


def generate_fallback_data(disease_name):
    """Generate contextually relevant fallback data"""
    fallback_db = {
        'healthy': {
            'cause': 'Plant is healthy with no visible disease.',
            'prevention': 'Maintain proper watering, sunlight, and soil nutrients to keep the plant healthy.',
            'treatment': 'Continue regular maintenance and care routines.',
            'farming_advice': 'Monitor regularly for any changes in leaf appearance or plant vigor.'
        },
        'Early blight': {
            'cause': 'Fungal disease caused by Alternaria solani that infects lower leaves first.',
            'prevention': 'Remove infected leaves, improve air circulation, use disease-free seeds, rotate crops.',
            'treatment': 'Apply fungicide sprays, remove infected foliage, ensure proper plant spacing.',
            'farming_advice': 'Avoid overhead watering, practice crop rotation, mulch soil to prevent spore splash.'
        },
        'Late blight': {
            'cause': 'Oomycete pathogen (Phytophthora infestans) thriving in cool, wet conditions.',
            'prevention': 'Use resistant varieties, improve drainage, avoid overhead irrigation.',
            'treatment': 'Apply copper or mancozeb fungicides, remove severely infected plants.',
            'farming_advice': 'Monitor weather, spray preventatively during humid periods, practice good sanitation.'
        },
        'Leaf spot': {
            'cause': 'Fungal or bacterial pathogens causing circular or irregular spots on leaves.',
            'prevention': 'Use clean seeds, avoid overhead watering, remove infected leaves promptly.',
            'treatment': 'Apply fungicide sprays, remove infected foliage, improve air circulation.',
            'farming_advice': 'Space plants properly for air flow, remove debris, sanitize tools between plants.'
        },
        'Powdery mildew': {
            'cause': 'Fungal infection causing white powder coating on leaves.',
            'prevention': 'Improve air circulation, avoid crowding, reduce humidity.',
            'treatment': 'Apply sulfur or neem oil sprays, remove heavily infected leaves.',
            'farming_advice': 'Plant in sunny locations, space plants adequately, monitor regularly.'
        },
        'Rust': {
            'cause': 'Fungal disease causing rust-colored pustules on leaf undersides.',
            'prevention': 'Use disease-resistant varieties, improve drainage, remove infected plants.',
            'treatment': 'Apply fungicides, remove infected leaves, improve air circulation.',
            'farming_advice': 'Monitor leaf undersides regularly, avoid overhead watering, clean up debris.'
        },
        'Scab': {
            'cause': 'Fungal disease causing rough, scabby lesions on fruits and leaves.',
            'prevention': 'Use scab-resistant varieties, apply protective fungicides early.',
            'treatment': 'Prune infected branches, apply copper fungicides, improve air flow.',
            'farming_advice': 'Remove fallen fruit, practice good orchard sanitation, thin branches.'
        },
        'Black rot': {
            'cause': 'Fungal pathogen causing dark, sunken lesions on fruits and leaves.',
            'prevention': 'Remove infected fruit, prune infected branches, ensure good air circulation.',
            'treatment': 'Apply copper or sulfur-based fungicides, remove and destroy infected material.',
            'farming_advice': 'Practice crop sanitation, remove mummified fruit, improve drainage.'
        },
        'Bacterial spot': {
            'cause': 'Bacterial pathogens causing water-soaked spots with yellow halos.',
            'prevention': 'Use disease-free seeds, avoid overhead irrigation, practice crop rotation.',
            'treatment': 'Remove infected foliage, apply copper-based bactericides, improve air flow.',
            'farming_advice': 'Sanitize pruning tools, avoid handling wet plants, remove debris.'
        }
    }
    
    for key, data in fallback_db.items():
        if key.lower() in disease_name.lower() or disease_name.lower() in key.lower():
            print(f"[OK] Using fallback data for: {disease_name}")
            return data
    
    return {
        'cause': f'{disease_name} is a plant disease that affects crop health and productivity.',
        'prevention': 'Maintain proper plant care, ensure good air circulation, remove infected material promptly.',
        'treatment': 'Apply appropriate fungicide or bactericide, remove heavily infected parts, isolate affected plants.',
        'farming_advice': 'Monitor plants regularly, practice crop rotation, maintain clean growing environment.'
    }


# ==================== DATABASE INITIALIZATION ====================

@app.route('/init-db', methods=['POST'])
def init_db():
    """Initialize database tables (call once)"""
    try:
        db.create_all()
        return jsonify({
            'success': True,
            'message': 'Database initialized successfully'
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# ==================== ERROR HANDLERS ====================

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Endpoint not found', 'code': 'NOT_FOUND'}), 404


@app.errorhandler(500)
def internal_error(error):
    db.session.rollback()
    return jsonify({'error': 'Internal server error', 'code': 'SERVER_ERROR'}), 500


# ==================== RUN SERVER ====================

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
        print("[OK] Database tables created")
    
    print("[OK] Starting Flask server...")
    app.run(host='0.0.0.0', port=5000, debug=True)
