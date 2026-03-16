import cv2
import numpy as np
import tensorflow as tf
from tensorflow.keras.models import load_model
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input

# Load trained model
model = load_model("plant_disease_mobilenetv2.h5")

# Class names (same order as training)
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

# ---- SETTING UP THE CAMERA ----
# 0 is usually the default webcam for your PC. 
# If you want to use your phone's camera over WiFi, you can install an app like "IP Webcam"
# on your phone, start the server, and replace 0 with the URL from the app.
# Example: cap = cv2.VideoCapture("http://192.168.1.100:8080/video")
cap = cv2.VideoCapture("http://192.168.1.253:8080/video")

print("Starting Camera... Press 'q' to quit.")

while True:
    ret, frame = cap.read()
    if not ret:
        print("Failed to grab frame. Make sure the camera is connected.")
        break

    # Process a copy of the camera frame
    # We must resize it to (224, 224) to match the expected input shape of MobileNetV2
    img = cv2.resize(frame, (224, 224))
    
    # Convert from BGR (OpenCV format) to RGB (Tensorflow format)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    # Preprocess image and add batch dimension
    img_array = preprocess_input(img)
    img_batch = np.expand_dims(img_array, axis=0)

    # ---- MAKE PREDICTION ----
    # verbose=0 stops Keras from printing predict logs per frame which would make it super slow
    prediction = model.predict(img_batch, verbose=0)
    
    class_index = np.argmax(prediction[0])
    confidence = np.max(prediction[0])
    predicted_disease = class_names[class_index]

    # ---- DISPLAY RESULT ON SCREEN ----
    text = f"{predicted_disease} ({confidence*100:.1f}%)"
    
    # Put a rectangle background behind the text so it's easy to read
    (text_width, text_height), baseline = cv2.getTextSize(text, cv2.FONT_HERSHEY_SIMPLEX, 0.7, 2)
    cv2.rectangle(frame, (10, 10 - text_height - baseline), (10 + text_width, 10 + baseline), (0, 0, 0), cv2.FILLED)
    
    # Draw logic on the image
    cv2.putText(frame, text, (10, 10), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)

    # Display video stream window
    cv2.imshow("CropGuard AI - Real-time Detection", frame)

    # Quit listener 'q'
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Release the camera and close the window
cap.release()
cv2.destroyAllWindows()
