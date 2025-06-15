from flask import Flask, request, jsonify
import joblib
import numpy as np
from PIL import Image
import cv2
import io
import base64
from flask_cors import CORS
import os
import traceback
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input
from tensorflow.keras.preprocessing import image as keras_image
import pickle

app = Flask(__name__)
CORS(app)

# Model path
MODEL_PATH = r"C:\Users\Ahmed Abd El Rahman\Desktop\Ai Agent Project\Random_Forest_best_model.joblib"
# Check if model file exists
if not os.path.exists(MODEL_PATH):
    print(f"ERROR: Model file not found at {MODEL_PATH}")
    model = None
else:
    print(f"Model file found at {MODEL_PATH}")
    try:
        # Try loading with pickle instead of joblib
        with open(MODEL_PATH, 'rb') as file:
            model = pickle.load(file)
        print(f"Model loaded successfully with pickle")
    except Exception as e:
        print(f"Error loading model with pickle: {e}")
        
        # If pickle fails, try joblib
        try:
            import joblib
            model = joblib.load(MODEL_PATH)
            print(f"Model loaded successfully with joblib")
        except Exception as e2:
            print(f"Error loading model with joblib: {e2}")
            model = None
# Load MobileNetV2 for feature extraction
try:
    feature_model = MobileNetV2(
        weights='imagenet', 
        include_top=False, 
        pooling='avg', 
        input_shape=(128, 128, 3)
    )
    print("MobileNetV2 loaded successfully")
except Exception as e:
    print(f"Error loading MobileNetV2: {e}")
    feature_model = None

# Define disease classes (from your model)
DISEASE_CLASSES = [
    "Healthy", 
    "Manganese Toxicity", 
    "Bacterial wilt disease"
]

# Image processing settings (same as training)
IMAGE_SIZE = (128, 128)

# Health scores for each disease
HEALTH_SCORES = {
    'Healthy': 95.0,
    'Manganese Toxicity': 55.0,
    'Bacterial wilt disease': 35.0
}

# Recommendations for each disease
RECOMMENDATIONS = {
    'Healthy': [
        'Continue regular watering schedule',
        'Monitor plant growth regularly',
        'Maintain current care routine',
        'Ensure adequate indirect sunlight',
        'Check soil moisture before watering'
    ],
    'Manganese Toxicity': [
        'Reduce manganese-containing fertilizers immediately',
        'Check and adjust soil pH (should be 6.0-7.0)',
        'Flush soil with clean water to remove excess minerals',
        'Improve drainage to prevent mineral buildup',
        'Consider repotting with fresh, well-draining soil',
        'Avoid tap water high in minerals - use filtered water'
    ],
    'Bacterial wilt disease': [
        'Isolate infected plant immediately to prevent spread',
        'Remove all infected leaves and stems',
        'Apply copper-based bactericide',
        'Reduce watering frequency - bacteria thrive in wet conditions',
        'Improve air circulation around the plant',
        'Sterilize all tools after use',
        'Consider propagating healthy cuttings before plant deteriorates'
    ]
}

def basic_preprocessing(img):
    """Apply the same preprocessing as in training"""
    img = cv2.resize(img, IMAGE_SIZE)
    img = cv2.GaussianBlur(img, (3, 3), 0)
    ycrcb = cv2.cvtColor(img, cv2.COLOR_BGR2YCrCb)
    ycrcb[:, :, 0] = cv2.equalizeHist(ycrcb[:, :, 0])
    img = cv2.cvtColor(ycrcb, cv2.COLOR_YCrCb2BGR)
    img = cv2.normalize(img.astype("float32"), None, 0, 1, cv2.NORM_MINMAX)
    return img

def preprocess_image(image_data):
    """Preprocess the image for model prediction"""
    try:
        print("Starting image preprocessing...")
        
        # Decode base64 image
        image_bytes = base64.b64decode(image_data)
        print(f"Decoded image bytes: {len(image_bytes)} bytes")
        
        # Convert to numpy array
        nparr = np.frombuffer(image_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if img is None:
            raise ValueError("Could not decode image")
        
        print(f"Original image shape: {img.shape}")
        
        # Apply the same preprocessing as training
        img = basic_preprocessing(img)
        print(f"After basic preprocessing: {img.shape}")
        
        # Prepare for MobileNetV2
        img = cv2.resize(img, IMAGE_SIZE)
        img = keras_image.img_to_array(img)
        img = np.expand_dims(img, axis=0)
        img = preprocess_input(img)
        print(f"After MobileNetV2 preprocessing: {img.shape}")
        
        # Extract features using MobileNetV2
        features = feature_model.predict(img, verbose=0).flatten()
        print(f"Extracted features shape: {features.shape}")
        
        # Reshape for the Random Forest model
        features = features.reshape(1, -1)
        print(f"Final features shape: {features.shape}")
        
        return features
        
    except Exception as e:
        print(f"Error in preprocessing: {str(e)}")
        traceback.print_exc()
        raise

@app.route('/predict', methods=['POST'])
def predict():
    try:
        print("\n=== New prediction request ===")
        
        if model is None:
            print("ERROR: Model is not loaded")
            return jsonify({'error': 'Model not loaded', 'success': False}), 500
        
        if feature_model is None:
            print("ERROR: Feature model is not loaded")
            return jsonify({'error': 'Feature model not loaded', 'success': False}), 500
            
        data = request.get_json()
        
        if 'image' not in data:
            return jsonify({'error': 'No image data provided', 'success': False}), 400
        
        print("Image data received")
        
        # Preprocess the image
        features = preprocess_image(data['image'])
        print("Image preprocessing completed")
        
        # Make prediction
        prediction = model.predict(features)[0]
        print(f"Prediction: {prediction}")
        
        # Get prediction probabilities if available
        try:
            probabilities = model.predict_proba(features)[0]
            confidence = float(probabilities[prediction]) * 100
            print(f"Confidence: {confidence}%")
        except Exception as e:
            print(f"Could not get probabilities: {e}")
            confidence = 85.0
        
        # Get disease name
        disease_name = DISEASE_CLASSES[prediction]
        print(f"Disease: {disease_name}")
        
        # Prepare response
        response = {
            'success': True,
            'disease': disease_name,
            'confidence': f'{confidence:.1f}%',
            'health_score': HEALTH_SCORES.get(disease_name, 50.0),
            'recommendations': RECOMMENDATIONS.get(disease_name, []),
            'model_type': 'Random Forest with MobileNetV2 Features'
        }
        
        print("Sending successful response")
        return jsonify(response)
    
    except Exception as e:
        print(f"ERROR in prediction: {str(e)}")
        traceback.print_exc()
        return jsonify({'error': str(e), 'success': False}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({
        'status': 'healthy', 
        'model_loaded': model is not None,
        'feature_model_loaded': feature_model is not None,
        'model_path': MODEL_PATH,
        'feature_extractor': 'MobileNetV2'
    })

@app.route('/test', methods=['GET'])
def test():
    """Test endpoint to verify server is running"""
    return jsonify({
        'message': 'Money Plant Disease Detection API is running',
        'endpoints': ['/predict', '/health', '/test'],
        'model_classes': DISEASE_CLASSES,
        'model_type': 'Random Forest with MobileNetV2 feature extraction',
        'model_loaded': model is not None,
        'feature_model_loaded': feature_model is not None
    })

if __name__ == '__main__':
    print("Starting Flask server...")
    print(f"Model loaded: {model is not None}")
    print(f"Feature model loaded: {feature_model is not None}")
    app.run(host='192.168.1.4', port=5000, debug=True)