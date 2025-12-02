# 🎓 Luar Sekolah LMS - Mobile App

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-orange?logo=firebase)
![RestAPI](https://img.shields.io/badge/Backend-REST%20API-green?logo=postman)
![GetX](https://img.shields.io/badge/State%20Management-GetX-purple)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Code-lightgrey)
![Testing](https://img.shields.io/badge/Testing-Unit%20%26%20Widget-red)

**Luar Sekolah LMS** adalah aplikasi mobile manajemen pembelajaran dan produktivitas yang dikembangkan sebagai **Final Project Internship**. Aplikasi ini menerapkan arsitektur _Hybrid Backend_ (REST API & Firebase) dengan standar _Clean Architecture_ untuk memastikan skalabilitas, performa, dan kemudahan pemeliharaan.

---

## 🌟 Fitur Utama (Highlight Features)

Aplikasi ini dibangun secara bertahap selama 12 minggu pengembangan. Berikut adalah fitur lengkapnya:

### 1. 🔐 Autentikasi & Keamanan (Advanced Auth)

Fitur keamanan lengkap menggunakan integrasi **Firebase Auth** dan validasi kustom.

- **Slider Captcha (Puzzle):** Verifikasi keamanan anti-bot interaktif pada halaman registrasi.
- **Form Validation:** Validasi input real-time (Email regex, Password strength, Phone format +62).
- **Realtime Profile Sync:** Sinkronisasi foto profil dan nama pengguna secara instan antara Halaman Akun dan Beranda menggunakan _Local Caching_.
- **Auto-Redirect:** Navigasi otomatis berbasis status login pengguna.

### 2. 📚 Manajemen Kelas (Core Business - REST API)

Migrasi total dari Firebase ke **REST API Perusahaan** untuk manajemen data bisnis utama.

- **Hybrid Backend:** Menggunakan REST API untuk data kursus, mengurangi ketergantungan pada kuota Firebase.
- **CRUD Operations:** Mendukung Create, Read, Update (dengan metode `PUT`), dan Delete kelas.
- **File Upload:** Upload gambar thumbnail kelas menggunakan `Multipart Request`.
- **Server-Side Logic:** Implementasi **Lazy Loading (Pagination)** dan **Filtering (Tags)** langsung di sisi server untuk efisiensi data.
- **Fixed Header UI:** Desain antarmuka modern dengan header statis dan konten yang dapat digulir.

### 3. ✅ Produktivitas & Todo List

Modul manajemen tugas yang terintegrasi dengan **Firebase Firestore**.

- **Scheduled Deadlines:** Menetapkan tanggal dan jam tenggat waktu tugas.
- **Smart Sorting:** Algoritma pengurutan otomatis (Tugas belum selesai dengan deadline terdekat selalu di atas).
- **Visual Status:** Indikator warna kartu (🔴 Terlewat, 🟠 < 24 Jam, 🔵 Normal, 🟢 Selesai).
- **Local Alarm:** Integrasi notifikasi lokal untuk pengingat tugas.

### 4. 🛠️ Arsitektur & Kualitas Kode

- **Clean Architecture:** Pemisahan kode menjadi layer _Domain_, _Data_, dan _Presentation_.
- **GetX State Management:** Manajemen state yang reaktif dan efisien.
- **Comprehensive Testing:** Cakupan Unit Test (UseCase, Repository, Controller) dan Widget Test menggunakan `mocktail`.

---

## 🗺️ Perjalanan Pengembangan (Development Roadmap)

Aplikasi ini dikembangkan melalui serangkaian _milestone_ mingguan:

- **Week 02-03:** Inisiasi UI, Widget Layout, dan Bottom Navigation.
- **Week 04:** Implementasi Form Validation yang ketat.
- **Week 05:** Routing manajemen & Page Transitions.
- **Week 07-08:** Refactoring ke **Clean Architecture** & Implementasi GetX.
- **Week 09:** Integrasi Firebase Auth & Firestore (Awal).
- **Week 10:** Implementasi Push Notification (Local Notifications).
- **Week 11:** Implementasi **Unit & Widget Testing** suite.
- **Week 12 (Final):** Migrasi Hybrid (API), Advanced Todo, Captcha, & Dashboarding.

---

## 🛠️ Tech Stack & Libraries

- **Framework:** Flutter SDK
- **Language:** Dart
- **State Management:** GetX
- **Backend:**
  - **REST API (Zoidify):** Manajemen Kelas & Upload File.
  - **Firebase Firestore:** Database Todo List & User Data.
  - **Firebase Auth:** Manajemen User Authentication.
- **Key Packages:**
  - `http`: Komunikasi REST API.
  - `slider_captcha`: Keamanan UI interaktif.
  - `flutter_local_notifications`: Sistem notifikasi & alarm.
  - `intl`: Format tanggal dan mata uang (Rupiah).
  - `image_picker`: Akses galeri dan kamera.
  - `shared_preferences`: Caching data lokal ringan.
  - `mocktail` & `flutter_test`: Pengujian aplikasi.

---

## 📂 Struktur Folder (Clean Architecture)

```text
lib/app/
├── data/                  # Layer Data (Implementasi Teknis)
│   ├── datasources/       # Remote (API) & Firestore Sources
│   ├── models/            # Model Data (JSON Parsing)
│   └── repositories/      # Implementasi Repository
├── domain/                # Layer Domain (Business Logic Murni)
│   ├── entities/          # Objek Bisnis Utama
│   ├── repositories/      # Interface Kontrak (Abstract)
│   └── usecases/          # Logika Bisnis per Fitur (AddTodo, Login, etc.)
├── presentation/          # Layer UI (Tampilan)
│   ├── controllers/       # GetX Controllers (Logic UI)
│   ├── pages/             # Halaman Screen
│   └── widgets/           # Komponen Reusable (Card, InputField)
└── core/                  # Utilities, Config, & Constants
```

---

## 🚀 Cara Instalasi

### 1. Clone Repository

```bash
git clone https://github.com/username/luar-sekolah-lms.git
cd luar_sekolah_lms
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Konfigurasi Firebase

- Pastikan file `google-services.json` (Android) atau `GoogleService-Info.plist` (iOS) ditempatkan di folder yang sesuai.
- Download file konfigurasi dari Firebase Console project Anda.
- Letakkan file tersebut di:
  - **Android:** `android/app/google-services.json`
  - **iOS:** `ios/Runner/GoogleService-Info.plist`

### 4. Konfigurasi REST API (Opsional)

Jika menggunakan endpoint API kustom, sesuaikan base URL di file konfigurasi:

```dart
// lib/core/config/api_config.dart
static const String baseUrl = 'https://your-api-endpoint.com';
```

### 5. Jalankan Aplikasi

```bash
flutter run
```

> **Catatan:** Pastikan emulator/device sudah terhubung sebelum menjalankan aplikasi.

---

## 📸 Screenshots

<div align="center">

|                                                         Register                                                         |                                                         Login                                                         |                                                         Home                                                         |
| :----------------------------------------------------------------------------------------------------------------------: | :-------------------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------: |
| <img width="200" alt="Register" src="https://github.com/user-attachments/assets/1a447e10-c902-46df-948d-8f45ddbd686d" /> | <img width="200" alt="Login" src="https://github.com/user-attachments/assets/d2bc5513-4fbb-47bd-a1cb-1b35a11d6420" /> | <img width="200" alt="Home" src="https://github.com/user-attachments/assets/a35ae78f-6de2-4c85-901f-ac70bb6f3c23" /> |

|                                                         Courses                                                         |                                                         Todos                                                         |                                                         Account                                                         |
| :---------------------------------------------------------------------------------------------------------------------: | :-------------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------: |
| <img width="200" alt="Courses" src="https://github.com/user-attachments/assets/cf1e554c-febd-4754-80a4-b7e8f33a1c3a" /> | <img width="200" alt="Todos" src="https://github.com/user-attachments/assets/84026873-3447-495d-936f-ec63ac58f701" /> | <img width="200" alt="Account" src="https://github.com/user-attachments/assets/98b39bca-3337-4fd2-a323-e023516a7b1f" /> |

## </div>

## 🧪 Testing

### Menjalankan Unit Tests

```bash
flutter test
```

### Menjalankan Widget Tests dengan Coverage

```bash
flutter test --coverage
```

### Melihat Coverage Report

```bash
# Install lcov terlebih dahulu
# Linux/Mac: brew install lcov
# Windows: Gunakan Chocolatey atau manual install

genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 📝 Lisensi

Project ini dikembangkan sebagai **Final Project Internship** dan dilisensikan untuk keperluan **Pembelajaran & Portfolio**.

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

**⭐ Jika project ini bermanfaat, jangan lupa berikan Star di repository!**
