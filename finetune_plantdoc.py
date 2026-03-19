# --- IMPORTS ---
import tensorflow as tf
from tensorflow.keras import layers
from tensorflow.keras.callbacks import ReduceLROnPlateau, EarlyStopping, ModelCheckpoint
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
    shuffle=True,
    label_mode='categorical' # Let Keras handle one-hot directly
)

val_ds = tf.keras.utils.image_dataset_from_directory(
    TEST_PATH,
    image_size=IMAGE_SIZE,
    batch_size=BATCH_SIZE,
    shuffle=False,
    label_mode='categorical'
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
    # To compute class weights, we need integer labels, so we temporarily create a dataset with integer labels
    temp_ds_int_labels = tf.keras.utils.image_dataset_from_directory(
        TRAIN_PATH,
        image_size=IMAGE_SIZE,
        batch_size=BATCH_SIZE,
        shuffle=True,
        label_mode='int' # Use integer labels for class weight calculation
    )
    for images, labels in temp_ds_int_labels.unbatch():
        class_counts[labels.numpy()] += 1
        total_samples += 1
    
    # Inverse frequency weighting
    weights = (1.0 / class_counts) * (total_samples / num_classes)
    class_weight_dict = {i: weight for i, weight in enumerate(weights)}
    return class_weight_dict

class_weight_dict = get_class_weights(train_ds)

# --- PREPROCESS DATASET ---
# CRITICAL: We map preprocessing here rather than inside the model layer. 
# Putting preprocess_input inside the Keras Model head creates scaling bugs during save/load.
preprocess_input = tf.keras.applications.mobilenet_v2.preprocess_input

def format_image_batch(images, labels):
    return preprocess_input(images), labels

AUTOTUNE = tf.data.AUTOTUNE
train_ds = train_ds.map(format_image_batch, num_parallel_calls=AUTOTUNE)
val_ds = val_ds.map(format_image_batch, num_parallel_calls=AUTOTUNE)


# --- DATA AUGMENTATION (As a separate layer block) ---
# Strong augmentation to prevent overfitting
data_augmentation = tf.keras.Sequential([
    layers.RandomFlip("horizontal_and_vertical"),
    layers.RandomRotation(0.2),
    layers.RandomZoom(height_factor=(-0.2, 0.2), width_factor=(-0.2, 0.2)),
    layers.RandomTranslation(height_factor=0.1, width_factor=0.1),
])

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
x = base_model(x, training=False)
x = layers.GlobalAveragePooling2D()(x)
x = layers.Dense(128, activation='relu')(x)
x = layers.Dropout(0.3)(x) 
outputs = layers.Dense(num_classes, activation="softmax")(x)

model = tf.keras.Model(inputs, outputs)

# Callbacks
callbacks = [
    ReduceLROnPlateau(monitor='val_accuracy', factor=0.5, patience=3, min_lr=1e-6, verbose=1),
    EarlyStopping(monitor='val_accuracy', patience=8, restore_best_weights=True, verbose=1)
]

# --- PHASE 1: TRAIN CLASSIFICATION HEAD ONLY ---
print("--- PHASE 1: Training newly added classification head ---")
model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=1e-3),
    loss="categorical_crossentropy",
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
    optimizer=tf.keras.optimizers.Adam(learning_rate=1e-5), # Keep LR very small to stop weight destruction
    loss="categorical_crossentropy",
    metrics=["accuracy"]
)

# Crucial fix: ModelCheckpoint guarantees we ALWAYS save the epoch with the highest validation accuracy
save_path = "plantdoc_mobilenetv2_finetuned.keras"
callbacks.append(ModelCheckpoint(save_path, save_best_only=True, monitor='val_accuracy', mode='max'))

history_finetune = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=30, # Let it run longer, EarlyStopping will catch it
    initial_epoch=history_head.epoch[-1],
    class_weight=class_weight_dict,
    callbacks=callbacks
)

print(f"Fine-tuned model successfully saved to '{save_path}'")