# 🎙️ AI Voice Companion App (Frontend)

Welcome to the frontend of the **AI Voice Companion App**, built with Flutter.  
This app delivers news, weather, health alerts, and personal story sharing features — all powered by voice input and output for enhanced accessibility.

---

## 🌟 Features

✅ **Kakao / Naver Social Login**  
- Authenticate using social platforms  
- Supports auto-login and initial screen routing based on login status

✅ **News & Weather Information**  
- View summarized news articles  
- Check current weather conditions

✅ **Health Notification Alerts**  
- Receive scheduled health reminders via popup  
- Dedicated health management screen

✅ **User Story Storage**  
- Save personal voice-based stories  
- Browse other users' shared stories

✅ **Voice Input & Output (TTS/STT)**  
- Record voice and play AI-generated responses

---

## 🏗️ Project Structure
```bash
lib/
├── main.dart                          # App entry point, handles routing and theme setup

├── controllers/                       # State management controllers
│   └── kakao_auth_controller.dart     # Manages Kakao login state and user information

├── models/                            # Data model definitions
│   ├── kakao_user_model.dart          # Kakao user data model
│   └── news_model.dart                # News article data model

├── screens/                           # Main UI screen components
│   ├── auth/                          # Login and signup screens
│   │   ├── login_page.dart            # Kakao login screen
│   │   ├── signup_page.dart           # General signup screen
│   │   ├── username_login_page.dart   # Nickname input screen
│   │   └── kakao_extra_info_page.dart # Additional info screen after Kakao login

│   ├── health/                        # Health-related screens
│   │   ├── alarm_popup.dart           # Health notification popup UI
│   │   └── health_screen.dart         # Main health management screen

│   ├── home/                          # Home screen and information sections
│   │   ├── home_screen.dart           # Main home screen
│   │   ├── news_screen.dart           # News list screen
│   │   ├── news_history_screen.dart   # News viewing history screen
│   │   └── weather_screen.dart        # Weather information screen

│   ├── splash/                        # Initial app launch screen
│   │   └── splash_screen.dart         # Loading and initialization UI

│   ├── user_profile/                  # My Page / profile settings
│   │   └── my_page.dart               # User profile and settings screen

│   ├── userstore/                     # User story storage
│   │   ├── user_store.dart            # List of user’s own stories
│   │   ├── user_store_detail.dart     # Detailed view of a story
│   │   └── other_user_store_screen.dart # View stories from other users

│   └── root_decider.dart              # Screen routing based on login status

├── services/                          # Service / business logic modules
│   ├── auth_service.dart              # Authentication utility functions
│   ├── kakao_auth_service.dart        # Kakao login API handler
│   ├── naver_auth_service.dart        # Naver login API handler
│   ├── custom_http_client.dart        # Custom HTTP client for API requests
│   ├── news_service.dart              # News fetching and parsing
│   └── notification_service.dart      # Notification handling service

├── utils/                             # Common utility functions
│   └── audio_utils.dart               # TTS/audio playback utilities

├── widgets/                           # Reusable UI components
│   ├── custom_app_bar.dart            # Custom top app bar
│   ├── custom_layout.dart             # Base layout widget
│   └── news_card.dart                 # News card-style component
assets/
├── fonts/                             # Custom fonts used in the app
└── images/                            # Image assets used in the UI

test/
└── widget_test.dart                   # Basic widget test example

web/
├── index.html                         # Web entry point for Flutter Web
├── manifest.json                      # PWA manifest configuration
└── icons/                             # App icons for web/PWA use

Others:
- `.gitignore`, `.metadata`, `pubspec.lock`, etc.: Default Flutter project setup files  
- `linux/`, `macos/`, `windows/`: Platform-specific build directories


> ℹ️ Platform directories like `linux/`, `macos/`, `windows/` are included by default for Flutter multi-platform support.
```

---

## ⚙️ Installation

1. **Clone the Repository**

2. **Install Dependencies**
```bash
flutter pub get
```
  
3. **▶️ Running the App**
```bash
flutter run            # Mobile
flutter run -d chrome  # Web
```
4. **🧪 Running Tests**
```bash
flutter test
```
---
## 🖼️ Screens Overview
| Screen           | Description                                |
| ---------------- | ------------------------------------------ |
| 🏠 Home          | News and weather overview                  |
| 🔐 Login         | Kakao / Naver login screen                 |
| 💬 Story Storage | View and manage personal or shared stories |
| ❤️ Health        | Health notifications and management UI     |
| 📄 My Page       | Profile editing and user settings          |

---
## 🧠 Tech Stack
| Category              | Technology                                                   |
| --------------------- | ------------------------------------------------------------ |
| **Framework**         | Flutter 3.x                                                  |
| **Language**          | Dart                                                         |
| **State Management**  | `flutter_riverpod`                                           |
| **API & Config**      | `http`, `flutter_dotenv`                                     |
| **Social Login**      | `kakao_flutter_sdk`, `flutter_appauth`, `flutter_web_auth_2` |
| **Local Storage**     | `shared_preferences`                                         |
| **Location Services** | `geolocator`, `geocoding`                                    |
| **Audio Features**    | `record`, `just_audio`, `audioplayers`, `just_audio_windows` |
| **Notifications**     | `flutter_local_notifications`, `timezone`                    |
| **UI Enhancements**   | `flutter_svg`, `image_picker`, `flutter_spinkit`             |
| **Web Support**       | `image_picker_web`, `web`                                    |
| **Utilities**         | `intl`, `file_picker`                                        |

---
## 📂 File Descriptions
📌 main.dart

📌 controllers/

📌 models/

📌 screens/auth/

📌 screens/home/, health/, userstore/, etc.

📌 services/

📌 utils/

📌 widgets/

📌 assets/

📌 test/

📌 web/

---
### If you have any issues or questions, feel free to open an issue or contribute to the project.
Thanks for checking out this Flutter frontend repository! 🎉 

