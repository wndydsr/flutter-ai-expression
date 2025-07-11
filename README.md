# Aitubes – Facial Expression Detection App 😄🤖

**Aitubes** is a Flutter-based mobile and desktop application for detecting facial expressions using a TensorFlow Lite (TFLite) model. The app supports Android, Web, and Windows platforms, with a clean UI, custom fonts, and a friendly user experience.

---

## ✨ Features

- 📸 Select image from gallery using `image_picker`
- 🧠 Detect facial expressions using a lightweight AI model (`expresi.tflite`)
- 🧍 Face detection using `google_mlkit_face_detection`
- 🎨 Clean UI with custom fonts (`OpalOrbit`, `Cute Days`)
- 🚀 Built with Material 3 and responsive design

---

## 📁 Project Structure

```
lib/
├── main.dart              # Main entry point
├── splash.dart            # Splash screen
└── home_page.dart         # Main detection page
assets/
└── models/expresi.tflite  # AI model (TFLite format)
```
---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/wndydsr/flutter-ai-expression.git
cd flutter-ai-expression
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run the App
```bash
flutter run
```
---
## 🧠 About the AI Model
| Item           | Value                                                           |
| -------------- | --------------------------------------------------------------- |
| **File**       | `assets/models/expresi.tflite`                                  |
| **Format**     | TensorFlow Lite (8‑bit quantized)                               |
| **Input size** | 48 × 48 grayscale                                               |
| **Output**     | 7 classes (Angry, Disgust, Fear, Happy, Sad, Surprise, Neutral) |
| **Load call**  | `Interpreter.fromAsset('assets/models/expresi.tflite')`         |
---
## 📦 Dependencies
| Package                       | Purpose                                     |
| ----------------------------- | ------------------------------------------- |
| `image_picker`                | Import images from gallery                  |
| `tflite_flutter`              | Load + run the TFLite model                 |
| `ffi`                         | Native bridge required by TFLite            |
| `image`                       | Basic bitmap manipulation                   |
| `google_mlkit_face_detection` | Face detection (bounding boxes & landmarks) |
---
## 🎨 UI & Design
- Custom fonts: OpalOrbit & Cute Days
- Primary color palette: #FFF3FF (background) and #FB64C1 (accent)
- Material 3 (useMaterial3: true) for modern widgets
- Simple, focused layout—ideal for enhancement
---
## 🧭 Roadmap
- Live camera preview with real‑time detection
- Extra animations for result cards
- Export/share detection result (image + label)
- Multi‑face support & better accuracy**
