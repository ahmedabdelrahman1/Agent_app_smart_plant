# import os
# import numpy as np
# import tensorflow as tf
# from tensorflow.keras.preprocessing.image import ImageDataGenerator
# from tensorflow.keras.applications import ResNet50, VGG19
# from tensorflow.keras.applications.resnet50 import preprocess_input as resnet_preprocess
# from tensorflow.keras.applications.vgg19 import preprocess_input as vgg_preprocess
# from tensorflow.keras.models import Model, Sequential
# from tensorflow.keras.layers import Dense, Flatten, GlobalAveragePooling2D
# from tensorflow.keras.optimizers import Adam
# from sklearn.metrics import classification_report, accuracy_score

# # Paths
# base_dir = r"C:\Users\admin\OneDrive\Desktop\Ai Agent Project\Cotton Disease"  # Replace this with your dataset path
# train_dir = os.path.join(base_dir, 'train')
# val_dir = os.path.join(base_dir, 'val')
# test_dir = os.path.join(base_dir, 'test')

# # Parameters
# IMAGE_SIZE = (224, 224)
# BATCH_SIZE = 32
# NUM_CLASSES = 4
# EPOCHS = 10  # Increase if needed

# # Function to create data generators
# def create_generators(preprocess_func):
#     train_datagen = ImageDataGenerator(preprocessing_function=preprocess_func, horizontal_flip=True, rotation_range=20, zoom_range=0.2)
#     val_test_datagen = ImageDataGenerator(preprocessing_function=preprocess_func)

#     train_gen = train_datagen.flow_from_directory(train_dir, target_size=IMAGE_SIZE, batch_size=BATCH_SIZE, class_mode='categorical')
#     val_gen = val_test_datagen.flow_from_directory(val_dir, target_size=IMAGE_SIZE, batch_size=BATCH_SIZE, class_mode='categorical')
#     test_gen = val_test_datagen.flow_from_directory(test_dir, target_size=IMAGE_SIZE, batch_size=BATCH_SIZE, class_mode='categorical', shuffle=False)
    
#     return train_gen, val_gen, test_gen

# # Function to build model
# def build_model(base_model):
#     model = Sequential([
#         base_model,
#         GlobalAveragePooling2D(),
#         Dense(128, activation='relu'),
#         Dense(NUM_CLASSES, activation='softmax')
#     ])
#     return model

# # Train and evaluate function
# def train_and_evaluate(model_name, base_model_class, preprocess_func):
#     print(f"\nTraining {model_name}...")
#     train_gen, val_gen, test_gen = create_generators(preprocess_func)

#     base_model = base_model_class(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
#     base_model.trainable = False  # Freeze base model

#     model = build_model(base_model)
#     model.compile(optimizer=Adam(), loss='categorical_crossentropy', metrics=['accuracy'])

#     model.fit(train_gen, validation_data=val_gen, epochs=EPOCHS)

#     # Evaluation
#     print(f"\nEvaluating {model_name} on test data...")
#     predictions = model.predict(test_gen)
#     predicted_classes = np.argmax(predictions, axis=1)
#     true_classes = test_gen.classes
#     class_labels = list(test_gen.class_indices.keys())

#     acc = accuracy_score(true_classes, predicted_classes)
#     print(f"{model_name} Test Accuracy: {acc:.4f}")
#     print(classification_report(true_classes, predicted_classes, target_names=class_labels))

# # Run for both models
# train_and_evaluate("ResNet50", ResNet50, resnet_preprocess)
# train_and_evaluate("VGG19", VGG19, vgg_preprocess)
# #######################################################################################
# #######################################################################################
# #########################################################################################

import os
import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator, load_img, img_to_array
from tensorflow.keras.applications import ResNet50, VGG19
from tensorflow.keras.applications.resnet50 import preprocess_input as resnet_preprocess
from tensorflow.keras.applications.vgg19 import preprocess_input as vgg_preprocess
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D
from tensorflow.keras.optimizers import Adam
from sklearn.metrics import classification_report, accuracy_score

# Paths
base_dir = r"C:\Users\admin\OneDrive\Desktop\Ai Agent Project\Cotton Disease"  # Update as needed
train_dir = os.path.join(base_dir, 'train')
val_dir = os.path.join(base_dir, 'val')
test_dir = os.path.join(base_dir, 'test')

# Parameters
IMAGE_SIZE = (224, 224)
BATCH_SIZE = 32
NUM_CLASSES = 4
EPOCHS = 10

# Data generators
def create_generators(preprocess_func):
    train_datagen = ImageDataGenerator(preprocessing_function=preprocess_func, horizontal_flip=True, rotation_range=20, zoom_range=0.2)
    val_test_datagen = ImageDataGenerator(preprocessing_function=preprocess_func)

    train_gen = train_datagen.flow_from_directory(train_dir, target_size=IMAGE_SIZE, batch_size=BATCH_SIZE, class_mode='categorical')
    val_gen = val_test_datagen.flow_from_directory(val_dir, target_size=IMAGE_SIZE, batch_size=BATCH_SIZE, class_mode='categorical')
    test_gen = val_test_datagen.flow_from_directory(test_dir, target_size=IMAGE_SIZE, batch_size=BATCH_SIZE, class_mode='categorical', shuffle=False)

    return train_gen, val_gen, test_gen

# Model builder
def build_model(base_model):
    model = Sequential([
        base_model,
        GlobalAveragePooling2D(),
        Dense(128, activation='relu'),
        Dense(NUM_CLASSES, activation='softmax')
    ])
    return model

# Train + evaluate function
def train_and_evaluate(model_name, base_model_class, preprocess_func):
    print(f"\nTraining {model_name}...")
    train_gen, val_gen, test_gen = create_generators(preprocess_func)

    base_model = base_model_class(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
    base_model.trainable = False

    model = build_model(base_model)
    model.compile(optimizer=Adam(), loss='categorical_crossentropy', metrics=['accuracy'])

    model.fit(train_gen, validation_data=val_gen, epochs=EPOCHS)

    print(f"\nEvaluating {model_name} on test data...")
    predictions = model.predict(test_gen)
    predicted_classes = np.argmax(predictions, axis=1)
    true_classes = test_gen.classes
    class_labels = list(test_gen.class_indices.keys())

    acc = accuracy_score(true_classes, predicted_classes)
    print(f"{model_name} Test Accuracy: {acc:.4f}")
    print(classification_report(true_classes, predicted_classes, target_names=class_labels))

    return model, class_labels, preprocess_func

# Predict single image
def predict_image(model, img_path, preprocess_func, class_labels):
    img = load_img(img_path, target_size=(224, 224))  # Load and resize
    img_array = img_to_array(img)  # Convert to array
    img_array = np.expand_dims(img_array, axis=0)  # Add batch dimension
    img_array = preprocess_func(img_array)  # Preprocess

    prediction = model.predict(img_array)
    predicted_class = np.argmax(prediction, axis=1)[0]
    predicted_label = class_labels[predicted_class]
    
    print(f"Predicted class: {predicted_label}")
    return predicted_label

# Train and evaluate both models
resnet_model, resnet_labels, resnet_prep = train_and_evaluate("ResNet50", ResNet50, resnet_preprocess)
vgg_model, vgg_labels, vgg_prep = train_and_evaluate("VGG19", VGG19, vgg_preprocess)

# Predict on a new image (update this path)
sample_image_path = r"C:\Users\admin\OneDrive\Desktop\Ai Agent Project\cotton_test.jpeg"
predict_image(resnet_model, sample_image_path, resnet_prep, resnet_labels)
predict_image(vgg_model, sample_image_path, vgg_prep, vgg_labels)
