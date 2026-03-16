# --- IMPORTS ---
import tensorflow as tf
from tensorflow.keras import layers
from tensorflow.keras.callbacks import ReduceLROnPlateau, EarlyStopping
import os
import numpy as np

# --- PATHS ---
TRAIN_PATH = r"D:\crop detection\PlantDoc-Dataset\train"
TEST_PATH = r"D:\crop detection\PlantDoc-Dataset\test"

IMAGE_SIZE = (224, 224)
BATCH_SIZE = 16 

# --- LOAD DATASET ---
print("Loading datasets...")
train_ds = tf.keras.utils.image_dataset_from_directory(
    TRAIN_PATH,
    image_size=IMAGE_SIZE,
    batch_size=BATCH_SIZE,
    shuffle=True
)

val_ds = tf.keras.utils.image_dataset_from_directory(
    TEST_PATH,
    image_size=IMAGE_SIZE,
    batch_size=BATCH_SIZE,
    shuffle=False
)

class_names = train_ds.class_names
num_classes = len(class_names)
print(f"Found {num_classes} classes.")

# --- COMPUTE CLASS WEIGHTS ---
# PlantDoc is highly imbalanced. This forces the model to care about rare classes.
def get_class_weights(dataset):
    class_counts = np.zeros(num_classes)
    total_samples = 0
    print("Computing class weights (this takes a moment)...")
    for images, labels in dataset.unbatch():
        class_counts[labels.numpy()] += 1
        total_samples += 1
    
    # Inverse frequency weighting
    weights = (1.0 / class_counts) * (total_samples / num_classes)
    class_weight_dict = {i: weight for i, weight in enumerate(weights)}
    return class_weight_dict

class_weight_dict = get_class_weights(train_ds)

# --- ONE-HOT ENCODING FOR LABEL SMOOTHING ---
# We need one-hot labels to apply label smoothing
def one_hot_encode(image, label):
    return image, tf.one_hot(label, num_classes)

train_ds = train_ds.map(one_hot_encode)
val_ds = val_ds.map(one_hot_encode)


# --- DATA AUGMENTATION ---
# Strong augmentation to prevent overfitting
data_augmentation = tf.keras.Sequential([
    layers.RandomFlip("horizontal_and_vertical"),
    layers.RandomRotation(0.3),                 # Increased rotation
    layers.RandomZoom(height_factor=(-0.2, 0.2), width_factor=(-0.2, 0.2)), # Stronger zoom
    layers.RandomTranslation(height_factor=0.2, width_factor=0.2), # Added shift
    layers.RandomContrast(0.2),                 # Increased contrast
    layers.RandomBrightness(0.2),               # Added brightness
])

# --- PREPROCESS ---
preprocess_input = tf.keras.applications.mobilenet_v2.preprocess_input

AUTOTUNE = tf.data.AUTOTUNE
train_ds = train_ds.prefetch(AUTOTUNE)
val_ds = val_ds.prefetch(AUTOTUNE)

# --- LOAD BASE MODEL ---
print("Loading base MobileNetV2 model...")
base_model = tf.keras.applications.MobileNetV2(
    input_shape=IMAGE_SIZE + (3,),
    include_top=False,
    weights='imagenet' 
)

base_model.trainable = False

# --- BUILD NEW MODEL HEAD FOR PLANTDOC ---
inputs = tf.keras.Input(shape=IMAGE_SIZE + (3,))
x = data_augmentation(inputs)
x = preprocess_input(x)
x = base_model(x, training=False)
x = layers.GlobalAveragePooling2D()(x)
# Add a dense layer with L2 Regularization before the final output
x = layers.Dense(256, activation='relu', kernel_regularizer=tf.keras.regularizers.l2(0.01))(x)
x = layers.BatchNormalization()(x)
x = layers.Dropout(0.5)(x) # 50% Dropout for heavier regularization
outputs = layers.Dense(num_classes, activation="softmax")(x)

model = tf.keras.Model(inputs, outputs)

# Callbacks
callbacks = [
    ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=3, min_lr=1e-6, verbose=1),
    EarlyStopping(monitor='val_loss', patience=8, restore_best_weights=True, verbose=1)
]

# --- PHASE 1: TRAIN CLASSIFICATION HEAD ONLY ---
print("--- PHASE 1: Training newly added classification head ---")
# Use label smoothing to prevent 100% confidence over-optimizations
loss_fn = tf.keras.losses.CategoricalCrossentropy(label_smoothing=0.1)

model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=1e-3),
    loss=loss_fn,
    metrics=["accuracy"]
)

history_head = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=15, 
    class_weight=class_weight_dict,
    callbacks=callbacks
)

# --- PHASE 2: FINE-TUNE ENTIRE MODEL ---
print("--- PHASE 2: Fine-tuning MORE of the model ---")
base_model.trainable = True

# Unfreeze MORE layers. MobileNetV2 has 154 layers. 
# We freeze the first 50 (basic edges), and fine-tune the remaining 100+ for domain-specific features
fine_tune_at = 50
for layer in base_model.layers[:fine_tune_at]:
    layer.trainable = False

model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=5e-5), # Slightly higher than before to encourage movement
    loss=loss_fn,
    metrics=["accuracy"]
)

history_finetune = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=30, # Let it run longer, EarlyStopping will catch it
    initial_epoch=history_head.epoch[-1],
    class_weight=class_weight_dict,
    callbacks=callbacks
)

# --- SAVE NEW MODEL ---
save_path = "plantdoc_mobilenetv2_finetuned.keras"
model.save(save_path)
print(f"Fine-tuned model successfully saved to '{save_path}'")