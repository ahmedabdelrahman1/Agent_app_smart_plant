import os
import cv2
import numpy as np
import joblib
import matplotlib.pyplot as plt
from sklearn.ensemble import RandomForestClassifier
from sklearn.svm import SVC
from sklearn.model_selection import train_test_split
from sklearn.metrics import (
    confusion_matrix,
    ConfusionMatrixDisplay,
    accuracy_score,
    classification_report
)
from tqdm import tqdm
import random
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input
from tensorflow.keras.preprocessing import image as keras_image
import pickle

# Settings - UPDATE THIS PATH TO YOUR DATASET LOCATION
DATASET_DIR = r"C:\Users\Ahmed Abd El Rahman\Desktop\Ai Agent Project\MoneyPlant\MoneyPlant"
CATEGORIES = ["Healthy", "Manganese Toxicity", "Bacterial wilt disease"]
IMAGE_SIZE = (128, 128)
MAX_IMAGES_PER_CLASS = 1500
AUGMENT = True

# Load MobileNetV2 model
print("Loading MobileNetV2...")
feature_model = MobileNetV2(weights='imagenet', include_top=False, pooling='avg', input_shape=(128, 128, 3))

def basic_preprocessing(img):
    img = cv2.resize(img, IMAGE_SIZE)
    img = cv2.GaussianBlur(img, (3, 3), 0)
    ycrcb = cv2.cvtColor(img, cv2.COLOR_BGR2YCrCb)
    ycrcb[:, :, 0] = cv2.equalizeHist(ycrcb[:, :, 0])
    img = cv2.cvtColor(ycrcb, cv2.COLOR_YCrCb2BGR)
    img = cv2.normalize(img.astype("float32"), None, 0, 1, cv2.NORM_MINMAX)
    return img

def augment_image(image):
    angle = random.randint(-20, 20)
    h, w = image.shape[:2]
    M = cv2.getRotationMatrix2D((w // 2, h // 2), angle, 1)
    image = cv2.warpAffine(image, M, (w, h))
    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    hsv[..., 2] = cv2.add(hsv[..., 2], random.randint(-20, 20))
    image = cv2.cvtColor(hsv, cv2.COLOR_HSV2BGR)
    return image

def load_data():
    X, y = [], []
    
    # Check if dataset directory exists
    if not os.path.exists(DATASET_DIR):
        print(f"ERROR: Dataset directory not found: {DATASET_DIR}")
        print("Please update DATASET_DIR to the correct path on your laptop")
        return None, None
    
    for idx, category in enumerate(CATEGORIES):
        folder = os.path.join(DATASET_DIR, category)
        if not os.path.exists(folder):
            print(f"WARNING: Category folder not found: {folder}")
            continue
            
        images = os.listdir(folder)[:MAX_IMAGES_PER_CLASS]
        print(f"Found {len(images)} images in {category}")
        
        for img_name in tqdm(images, desc=f"Loading {category}"):
            img_path = os.path.join(folder, img_name)
            img = cv2.imread(img_path)
            if img is None or img.shape[0] == 0 or img.shape[1] == 0:
                continue
            try:
                img = basic_preprocessing(img)
                if AUGMENT:
                    img = augment_image(img)
                img = cv2.resize(img, IMAGE_SIZE)
                img = keras_image.img_to_array(img)
                img = np.expand_dims(img, axis=0)
                img = preprocess_input(img)
                features = feature_model.predict(img, verbose=0).flatten()
                X.append(features)
                y.append(idx)
            except Exception as e:
                print(f"Error processing {img_name}: {e}")
                continue
    
    return np.array(X), np.array(y)

# Load dataset
print("Loading dataset...")
X, y = load_data()

if X is None or len(X) == 0:
    print("ERROR: No data loaded. Please check your dataset path.")
    exit()

print(f"Loaded {len(X)} images")

# Split data
X_train, X_test, y_train, y_test = train_test_split(X, y, stratify=y, test_size=0.2, random_state=42)

# Models to compare
models = {
    "Random Forest": RandomForestClassifier(n_estimators=200, random_state=42),
    "SVM (RBF Kernel)": SVC(kernel='rbf', C=10, gamma='scale', probability=True)
}

accuracies = {}

# Evaluate each model
for name, model in models.items():
    print(f"\n=== {name} ===")
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)
    acc = accuracy_score(y_test, y_pred)
    accuracies[name] = acc
    print(f"Accuracy: {acc:.4f}")

    # Confusion Matrix
    cm = confusion_matrix(y_test, y_pred)
    disp = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=CATEGORIES)
    disp.plot(cmap=plt.cm.Blues)
    plt.title(f"{name} - Confusion Matrix")
    plt.show()

    # Classification Report
    print(f"\nClassification Report for {name}:")
    print(classification_report(y_test, y_pred, target_names=CATEGORIES))

# Print comparison
print("\n=== Model Accuracy Comparison ===")
for model_name, acc in accuracies.items():
    print(f"{model_name}: {acc:.4f}")

# Choose the best model
best_model_name = max(accuracies, key=accuracies.get)
clf = models[best_model_name]
print(f"\nUsing best model for prediction: {best_model_name}")

# Create directory for saving models
save_dir = r"C:\Users\Ahmed Abd El Rahman\Desktop\Ai Agent Project"
os.makedirs(save_dir, exist_ok=True)

# Save the best model in multiple formats
# 1. Save with joblib (recommended)
model_joblib_path = os.path.join(save_dir, f"{best_model_name.replace(' ', '_')}_best_model.joblib")
joblib.dump(clf, model_joblib_path, compress=3)
print(f"Model saved with joblib: {model_joblib_path}")

# 2. Save with pickle (compatibility)
model_pkl_path = os.path.join(save_dir, f"{best_model_name.replace(' ', '_')}_best_model.pkl")
with open(model_pkl_path, 'wb') as f:
    pickle.dump(clf, f, protocol=4)
print(f"Model saved with pickle: {model_pkl_path}")

# 3. Save MobileNetV2 feature extractor
feature_model_path = os.path.join(save_dir, "mobilenetv2_feature_extractor.h5")
feature_model.save(feature_model_path)
print(f"Feature extractor saved: {feature_model_path}")

# 4. Save model configuration
import json
import sklearn
import tensorflow as tf

config = {
    'model_type': best_model_name,
    'categories': CATEGORIES,
    'image_size': IMAGE_SIZE,
    'accuracy': accuracies[best_model_name],
    'sklearn_version': sklearn.__version__,
    'numpy_version': np.__version__,
    'tensorflow_version': tf.__version__,
    'n_features': X.shape[1] if len(X) > 0 else 0
}

config_path = os.path.join(save_dir, "model_config.json")
with open(config_path, 'w') as f:
    json.dump(config, f, indent=4)
print(f"Configuration saved: {config_path}")

print(f"\nAll models saved to: {save_dir}")

# Prediction Function
def predict_image(img_path):
    img = cv2.imread(img_path)
    if img is None:
        print(f"Image not readable: {img_path}")
        return
    original = cv2.cvtColor(img.copy(), cv2.COLOR_BGR2RGB)
    img = basic_preprocessing(img)
    img = cv2.resize(img, IMAGE_SIZE)
    img = keras_image.img_to_array(img)
    img = np.expand_dims(img, axis=0)
    img = preprocess_input(img)
    features = feature_model.predict(img, verbose=0).flatten().reshape(1, -1)
    pred = clf.predict(features)[0]
    predicted_label = CATEGORIES[pred]
    filename = os.path.basename(img_path)

    plt.figure(figsize=(4, 4))
    plt.imshow(original)
    plt.title(f"{filename}\nPredicted: {predicted_label}", fontsize=10)
    plt.axis('off')
    plt.tight_layout()
    plt.show()

    return pred

# Test predictions using best model
test_images = [
    r"C:\Users\Ahmed Abd El Rahman\Desktop\Ai Agent Project\pothos1.jpg",
    r"C:\Users\Ahmed Abd El Rahman\Desktop\Ai Agent Project\pothos2.jpg",
    r"C:\Users\Ahmed Abd El Rahman\Desktop\Ai Agent Project\pothos3.jpg",
    r"C:\Users\Ahmed Abd El Rahman\Desktop\Ai Agent Project\pothos5b.jpg",
    r"C:\Users\Ahmed Abd El Rahman\Desktop\Ai Agent Project\pothos6h.jpg",
    r"C:\Users\Ahmed Abd El Rahman\Desktop\Ai Agent Project\pothos6m.jpg"
]

print("\nTesting predictions...")
for img_path in test_images:
    if os.path.exists(img_path):
        predict_image(img_path)
    else:
        print(f"Test image not found: {img_path}")