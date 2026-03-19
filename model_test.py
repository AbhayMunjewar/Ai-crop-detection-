import tensorflow as tf
try:
    from tensorflow.keras.applications import MobileNetV2
    from tensorflow.keras.applications.mobilenet_v2 import preprocess_input
    from tensorflow.keras.preprocessing import image
except ImportError:
    from keras.applications import MobileNetV2
    from keras.applications.mobilenet_v2 import preprocess_input
    from keras.preprocessing import image
import numpy as np

# Load pretrained MobileNetV2 model
model = MobileNetV2(weights='imagenet')

print("Model loaded successfully")
print("Input shape:", model.input_shape)
