# Proyek Integrasi Push Notification (LMS App)

Proyek ini adalah kelanjutan dari tugas Minggu 9 dan memenuhi tugas **Minggu 10: Push Notification & Local Notification**. Fokus utama minggu ini adalah meningkatkan **User Engagement** dengan mengintegrasikan **Firebase Cloud Messaging (FCM)** untuk notifikasi jarak jauh (remote) dan **Flutter Local Notifications** untuk umpan balik instan (feedback) saat pengguna berinteraksi dengan aplikasi.

---

## 📋 Daftar Isi

- [Fitur Baru Minggu 10](#-fitur-baru-minggu-10)
- [Struktur Folder Arsitektur](#-struktur-folder-arsitektur-update-minggu-10)
- [Konfigurasi Teknis (PENTING)](#️-konfigurasi-teknis-penting)
- [Alur Kerja Notifikasi](#-alur-kerja-notifikasi)
- [Skenario Notifikasi](#-skenario-notifikasi-yang-diimplementasikan)
- [Cara Testing (Pengujian)](#-cara-testing-pengujian)
- [Dependencies Baru](#-dependencies-baru)
- [Troubleshooting](#-troubleshooting)

---

## 🔔 Fitur Baru Minggu 10

Kami telah mengimplementasikan sistem notifikasi hibrida:

- **Push Notification (FCM)**: Menangani notifikasi dari server Firebase saat aplikasi berada di **Background** atau **Terminated**.
- **Local Notification (Foreground)**: Menangani notifikasi saat aplikasi sedang dibuka (**Foreground**) untuk memastikan banner/heads-up muncul.
- **Action-Based Notification**: Notifikasi otomatis yang muncul saat user melakukan aksi CRUD (Create, Update, Delete) pada Todo.
- **Dynamic Content**: Pesan notifikasi tidak statis, melainkan mengambil judul dan status Todo secara real-time.

---

## 📁 Struktur Folder Arsitektur (Update Minggu 10)

Struktur folder diperbarui dengan penambahan Service baru di layer **Core**.

```
└── lib/
    ├── main.dart                                (<- Inisialisasi NotificationService)
    └── app/
        ├── core/
        │   ├── services/
        │   │   └── notification_service.dart    (<- BARU: Handler Pusat Notifikasi)
        │   └── ...
        │
        ├── presentation/
        │   └── controllers/
        │       └── todo_controller.dart         (<- UPDATE: Trigger notifikasi setelah sukses CRUD)
        │   └── ...

        (Layer Domain & Data sama seperti Minggu 9)
```

### Penjelasan Komponen Baru:

- **NotificationService**: Service global (Singleton) yang menangani izin, inisialisasi saluran notifikasi Android (Channel), dan mendengarkan pesan masuk dari FCM.
- **\_firebaseMessagingBackgroundHandler**: Fungsi top-level untuk menangani pesan saat aplikasi dimatikan total.

---

## ⚙️ Konfigurasi Teknis (PENTING)

Untuk mendukung fitur notifikasi modern, proyek ini memerlukan konfigurasi khusus pada level Android (Gradle).

### 1. Java Desugaring (Wajib)

Library `flutter_local_notifications` versi terbaru memerlukan fitur Java 8+.

**File:** `android/app/build.gradle.kts`

**Perubahan:**

Mengaktifkan `coreLibraryDesugaring`.

```kotlin
compileOptions {
    isCoreLibraryDesugaringEnabled = true  // <-- WAJIB
    sourceCompatibility = JavaVersion.VERSION_1_8
    targetCompatibility = JavaVersion.VERSION_1_8
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")  // <-- WAJIB
}
```

### 2. Android Manifest

Pastikan izin internet dan notifikasi sudah ada (biasanya otomatis ditambahkan library, namun pastikan untuk Android 13+).

---

## 🔄 Alur Kerja Notifikasi

### 1. Saat User Menambah/Mengedit Data (Local)

Aplikasi tidak menunggu server Firebase mengirim balik notifikasi. Sebaliknya, aplikasi langsung memicu notifikasi lokal setelah operasi Firestore berhasil.

```
graph LR
A[User Action] --> B[TodoController]
B --> C{Firestore Success?}
C -->|Yes| D[NotificationService]
D --> E[Show Local Banner]
C -->|No| F[Show Error Snackbar]
```

### 2. Saat Admin Mengirim Kampanye (FCM)

```
graph TD
A[Firebase Console] --> B[FCM Server]
B --> C{App State?}
C -->|Foreground| D[OnMessage Listen] --> E[Show Local Banner]
C -->|Background| F[System Tray Notification]
C -->|Terminated| F
```

---

## 📱 Skenario Notifikasi yang Diimplementasikan

Berikut adalah perilaku notifikasi yang telah kami kodekan di `TodoController`:

| Aksi User     | Judul Notifikasi         | Isi Pesan (Body)                                      |
| ------------- | ------------------------ | ----------------------------------------------------- |
| Tambah Todo   | Catatan Baru Ditambahkan | "Tugas '[Nama Todo]' berhasil disimpan ke daftar! 📝" |
| Toggle Status | Status Diperbarui        | "Tugas '[Nama Todo]' kini [Selesai/Belum Selesai] 🎉" |
| Hapus Todo    | Catatan Dihapus          | "Tugas '[Nama Todo]' telah dihapus dari daftar 🗑️"    |
| FCM Push      | (Sesuai Input Console)   | (Sesuai Input Console)                                |

---

## 🧪 Cara Testing (Pengujian)

### Skenario A: Interaksi Lokal (CRUD)

1. Jalankan aplikasi.
2. Masuk ke halaman Todo.
3. **Tambah Todo baru**: Masukkan teks, klik Simpan.  
   → Harus muncul banner notifikasi dengan nama todo tersebut.
4. **Checklist Todo**: Klik checkbox.  
   → Harus muncul notifikasi status berubah.
5. **Hapus Todo**: Geser/Hapus item.  
   → Harus muncul notifikasi item telah dihapus.

### Skenario B: Remote Notification (FCM)

1. Jalankan aplikasi dan lihat Terminal/Debug Console.
2. Salin **FCM Token** yang muncul (diawali `🔔 FCM TOKEN: ...`).
3. Buka **Firebase Console → Messaging → New Campaign**.
4. Masukkan Judul & Pesan Test.
5. Klik **Test → Paste Token → Kirim**.

**Hasil yang diharapkan:**

- **App Dibuka**: Muncul Banner di atas (via Local Notification).
- **App Minimize/Closed**: Muncul Notifikasi di System Tray Android.

---

## 📦 Dependencies Baru

Tambahkan paket berikut ke `pubspec.yaml`:

```yaml
dependencies:
  firebase_messaging: ^16.0.4 # Untuk komunikasi ke Firebase Cloud Messaging
  flutter_local_notifications: ^18.0.1 # Untuk memunculkan banner saat Foreground
```

---

## 🐛 Troubleshooting

### 1. Notifikasi tidak muncul saat aplikasi dibuka

**Penyebab:** Channel Android belum diset ke `Importance.max`.

**Solusi:** Uninstall aplikasi dari emulator, lalu install ulang (`flutter run`) agar channel notifikasi dibuat ulang dengan prioritas tinggi.

### 2. Error Desugaring saat build

**Penyebab:** Versi Gradle/Java tidak kompatibel dengan library notifikasi baru.

**Solusi:** Ikuti panduan **Konfigurasi Teknis** di atas untuk mengupdate `build.gradle`.

### 3. Icon Notifikasi Kotak Putih

**Penyebab:** Aset icon aplikasi tidak memiliki transparent background (Alpha channel) sesuai standar Android terbaru.

**Solusi:** Gunakan aset icon khusus notifikasi yang transparan, atau abaikan jika hanya untuk testing development.

---
