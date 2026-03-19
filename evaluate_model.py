import tensorflow as tf
import os

TEST_PATH = r"D:\crop detection\PlantDoc-Dataset\test"
IMAGE_SIZE = (224, 224)
BATCH_SIZE = 16

print("Loading validation dataset...")
val_ds = tf.keras.utils.image_dataset_from_directory(
    TEST_PATH,
    image_size=IMAGE_SIZE,
    batch_size=BATCH_SIZE,
    shuffle=False
)

num_classes = len(val_ds.class_names)

def one_hot_encode(image, label):
    return image, tf.one_hot(label, num_classes)

val_ds = val_ds.map(one_hot_encode)

preprocess_input = tf.keras.applications.mobilenet_v2.preprocess_input
val_ds = val_ds.map(lambda x, y: (preprocess_input(x), y))

AUTOTUNE = tf.data.AUTOTUNE
val_ds = val_ds.prefetch(AUTOTUNE)

print("Loading finetuned model...")
model = tf.keras.models.load_model("plantdoc_mobilenetv2_finetuned.keras", compile=False)

import numpy as np
print("Evaluating manually...")
correct = 0
total = 0

for images, labels in val_ds:
    preds = model.predict(images, verbose=0)
    pred_classes = np.argmax(preds, axis=1)
    true_classes = np.argmax(labels.numpy(), axis=1)
    
    correct += np.sum(pred_classes == true_classes)
    total += len(true_classes)

print(f"Final Validation Accuracy (Manual): {(correct/total)*100:.2f}%")
