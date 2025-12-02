# 🎓 Luar Sekolah LMS - Mobile Application

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-orange?logo=firebase)
![RestAPI](https://img.shields.io/badge/Backend-REST%20API-green?logo=postman)
![GetX](https://img.shields.io/badge/State%20Management-GetX-purple)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Code-lightgrey)
![Testing](https://img.shields.io/badge/Testing-Unit%20%26%20Widget-red)

**Luar Sekolah LMS** is a mobile learning management and productivity application developed as a **Final Internship Project**. This application implements a _Hybrid Backend_ architecture (REST API & Firebase) with _Clean Architecture_ standards to ensure scalability, performance, and maintainability.

---

## 🌟 Key Features

This application was built incrementally over 12 weeks of development. Below are the complete features:

### 1. 🔐 Authentication & Security (Advanced Auth)

Comprehensive security features using **Firebase Auth** integration and custom validation.

- **Slider Captcha (Puzzle):** Interactive anti-bot security verification on registration page.
- **Form Validation:** Real-time input validation (Email regex, Password strength, Phone format +62).
- **Realtime Profile Sync:** Instant synchronization of profile photos and usernames between Account and Home pages using _Local Caching_.
- **Auto-Redirect:** Automatic navigation based on user login status.

### 2. 📚 Course Management (Core Business - REST API)

Complete migration from Firebase to **Company REST API** for core business data management.

- **Hybrid Backend:** Uses REST API for course data, reducing dependency on Firebase quota.
- **CRUD Operations:** Supports Create, Read, Update (with `PUT` method), and Delete courses.
- **File Upload:** Upload course thumbnail images using `Multipart Request`.
- **Server-Side Logic:** Implementation of **Lazy Loading (Pagination)** and **Filtering (Tags)** directly on server-side for data efficiency.
- **Fixed Header UI:** Modern interface design with static header and scrollable content.

### 3. ✅ Productivity & Todo List

Task management module integrated with **Firebase Firestore**.

- **Scheduled Deadlines:** Set task deadlines with date and time.
- **Smart Sorting:** Automatic sorting algorithm (Incomplete tasks with nearest deadlines always on top).
- **Visual Status:** Card color indicators (🔴 Overdue, 🟠 < 24 Hours, 🔵 Normal, 🟢 Completed).
- **Local Alarm:** Local notification integration for task reminders.

### 4. 🛠️ Architecture & Code Quality

- **Clean Architecture:** Code separation into _Domain_, _Data_, and _Presentation_ layers.
- **GetX State Management:** Reactive and efficient state management.
- **Comprehensive Testing:** Coverage of Unit Tests (UseCase, Repository, Controller) and Widget Tests using `mocktail`.

---

## 🗺️ Development Roadmap

This application was developed through a series of weekly _milestones_:

- **Week 02-03:** UI initialization, Widget Layout, and Bottom Navigation.
- **Week 04:** Implementation of strict Form Validation.
- **Week 05:** Route management & Page Transitions.
- **Week 07-08:** Refactoring to **Clean Architecture** & GetX Implementation.
- **Week 09:** Firebase Auth & Firestore Integration (Initial).
- **Week 10:** Push Notification Implementation (Local Notifications).
- **Week 11:** Implementation of **Unit & Widget Testing** suite.
- **Week 12 (Final):** Hybrid Migration (API), Advanced Todo, Captcha, & Dashboarding.

---

## 🛠️ Tech Stack & Libraries

- **Framework:** Flutter SDK
- **Language:** Dart
- **State Management:** GetX
- **Backend:**
  - **REST API (Zoidify):** Course Management & File Upload.
  - **Firebase Firestore:** Todo List & User Data Database.
  - **Firebase Auth:** User Authentication Management.
- **Key Packages:**
  - `http`: REST API communication.
  - `slider_captcha`: Interactive UI security.
  - `flutter_local_notifications`: Notification & alarm system.
  - `intl`: Date and currency formatting (Rupiah).
  - `image_picker`: Gallery and camera access.
  - `shared_preferences`: Lightweight local data caching.
  - `mocktail` & `flutter_test`: Application testing.

---

## 📂 Folder Structure (Clean Architecture)

```text
lib/app/
├── data/                  # Data Layer (Technical Implementation)
│   ├── datasources/       # Remote (API) & Firestore Sources
│   ├── models/            # Data Models (JSON Parsing)
│   └── repositories/      # Repository Implementation
├── domain/                # Domain Layer (Pure Business Logic)
│   ├── entities/          # Core Business Objects
│   ├── repositories/      # Contract Interfaces (Abstract)
│   └── usecases/          # Business Logic per Feature (AddTodo, Login, etc.)
├── presentation/          # UI Layer (View)
│   ├── controllers/       # GetX Controllers (UI Logic)
│   ├── pages/             # Screen Pages
│   └── widgets/           # Reusable Components (Card, InputField)
└── core/                  # Utilities, Config, & Constants
```

---

## 🚀 Installation Guide

### 1. Clone Repository

```bash
git clone https://github.com/username/luar-sekolah-lms.git
cd luar_sekolah_lms
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Configuration

- Ensure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) files are placed in the appropriate folders.
- Download configuration files from your Firebase Console project.
- Place the files at:
  - **Android:** `android/app/google-services.json`
  - **iOS:** `ios/Runner/GoogleService-Info.plist`

### 4. REST API Configuration (Optional)

If using a custom API endpoint, adjust the base URL in the configuration file:

```dart
// lib/core/config/api_config.dart
static const String baseUrl = 'https://your-api-endpoint.com';
```

### 5. Run Application

```bash
flutter run
```

> **Note:** Ensure emulator/device is connected before running the application.

---

## 📸 Screenshots

<div align="center">

|                                                         Register                                                         |                                                         Login                                                         |                                                         Home                                                         |
| :----------------------------------------------------------------------------------------------------------------------: | :-------------------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------: |
| <img width="200" alt="Register" src="https://github.com/user-attachments/assets/1a447e10-c902-46df-948d-8f45ddbd686d" /> | <img width="200" alt="Login" src="https://github.com/user-attachments/assets/d2bc5513-4fbb-47bd-a1cb-1b35a11d6420" /> | <img width="200" alt="Home" src="https://github.com/user-attachments/assets/a35ae78f-6de2-4c85-901f-ac70bb6f3c23" /> |

|                                                         Courses                                                         |                                                         Todos                                                         |                                                         Account                                                         |
| :---------------------------------------------------------------------------------------------------------------------: | :-------------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------: |
| <img width="200" alt="Courses" src="https://github.com/user-attachments/assets/cf1e554c-febd-4754-80a4-b7e8f33a1c3a" /> | <img width="200" alt="Todos" src="https://github.com/user-attachments/assets/84026873-3447-495d-936f-ec63ac58f701" /> | <img width="200" alt="Account" src="https://github.com/user-attachments/assets/98b39bca-3337-4fd2-a323-e023516a7b1f" /> |

</div>

---

## 🧪 Testing

### Running Unit Tests

```bash
flutter test
```

### Running Widget Tests with Coverage

```bash
flutter test --coverage
```

### Viewing Coverage Report

```bash
# Install lcov first
# Linux/Mac: brew install lcov
# Windows: Use Chocolatey or manual install

genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 📝 License

This project was developed as a **Final Internship Project** and is licensed for **Learning & Portfolio** purposes.

---

## 👨‍💻 Developer

**Kelvin Julian**  
_Internship Final Project - 2025_

[![GitHub](https://img.shields.io/badge/GitHub-Profile-black?logo=github)](https://github.com/kelvinjulian)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?logo=linkedin)](https://linkedin.com/in/kelvinjulianputra)
[![Email](https://img.shields.io/badge/Email-Contact-red?logo=gmail)](mailto:julianputrakelvin@gmail.com)

---

## 🙏 Acknowledgments

- **Luar Sekolah Team** - Mentorship & API Backend Support
- **Flutter Community** - Open source packages & documentation
- **Firebase** - Backend infrastructure

---

**⭐ If you find this project helpful, don't forget to give it a Star on the repository!**
