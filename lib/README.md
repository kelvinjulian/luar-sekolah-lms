# Proyek Refaktor Clean Architecture (LMS App)

Proyek ini adalah hasil refaktor dari aplikasi LMS (Learning Management System) untuk memenuhi tugas **Minggu 8: Pengenalan Clean Architecture & Separation of Concerns**.

Tujuan utama dari refaktor ini adalah untuk memisahkan logika bisnis, logika UI, dan logika pengambilan data, sehingga aplikasi menjadi lebih:

- **Mudah Dikelola (Maintainable):** Mengubah satu bagian (misal: UI) tidak merusak bagian lain (misal: API).
- **Mudah Diuji (Testable):** Setiap bagian (UseCase, Controller) dapat diuji secara terpisah.
- **Skalabel (Scalable):** Mudah untuk menambah fitur baru tanpa merusak fitur lama.

Kami menggunakan **GetX** sebagai _framework_ untuk _State Management_, _Dependency Injection_, dan _Routing_.

---

## 📁 Struktur Folder Arsitektur

Struktur folder baru kita secara jelas mencerminkan 3 area utama (Presentation, Domain, Data) dan 1 folder Core untuk utilitas.

```text
└── lib/
    ├── main.dart                 (<- Titik masuk aplikasi, inisialisasi GetMaterialApp)
    ├── README.md                 (<- Dokumentasi ini)
    └── app/
        ├── presentation/         (<- 1. LAYER UI: Apa yang dilihat pengguna)
        │   ├── widgets/            (<- Komponen UI kecil, cth: button, input)
        │   │   ├── checklist_item.dart
        │   │   ├── custom_cards.dart
        │   │   ├── custom_dropdown.dart
        │   │   ├── dropdown_field.dart
        │   │   ├── input_field.dart
        │   │   └── input_label.dart
        │   ├── pages/              (<- Setiap layar di aplikasi, cth: login, home)
        │   │   ├── account_page.dart
        │   │   ├── home_page.dart
        │   │   ├── login_page.dart
        │   │   ├── main_content_page.dart
        │   │   ├── register_page.dart
        │   │   ├── todo/
        │   │   │   ├── todo_detail_page.dart
        │   │   │   └── todo_list_page.dart
        │   │   └── course/
        │   │       ├── class_form_page.dart
        │   │       └── class_page.dart
        │   └── controllers/        (<- "Otak" UI, Manajer State, cth: TodoController)
        │       ├── class_controller.dart
        │       └── todo_controller.dart
        │
        ├── domain/                 (<- 2. LAYER DOMAIN: Aturan bisnis murni)
        │   ├── repositories/       (<- Kontrak/Buku Menu, cth: "Bisa ambil Todo")
        │   │   ├── i_course_repository.dart
        │   │   └── i_todo_repository.dart
        │   ├── entities/           (<- Model data murni, cth: Todo, Course)
        │   │   ├── course.dart
     _B(B    │   └── todo.dart
        │   └── usecases/           (<- Resep/Satu tugas spesifik, cth: "Ambil Semua Todo")
        │       ├── todo/
        │       │   ├── add_todo.dart
        │       │   ├── delete_todo.dart
        │       │   ├── get_all_todos.dart
        │       │   └── update_todo.dart
        │       └── course/
        │           ├── add_course.dart
        │           ├── delete_course.dart
        │           ├── get_all_courses.dart
        │           └── update_course.dart
        │
        ├── data/                   (<- 3. LAYER DATA: Sumber data & implementasi)
        │   ├── repositories/       (<- "Kepala Koki" / Implementasi kontrak)
        │   │   ├── course_repository_impl.dart
        │   │   └── todo_repository_impl.dart
        │   └── datasources/        (<- "Supplier" / API atau Dummy Data)
        │       ├── course_dummy_data_source.dart
        │       └── todo_remote_data_source.dart
        │
        └── core/                   (<- 4. LAYER CORE: Penyatuan & Utilitas)
            ├── routes/             (<- Peta navigasi aplikasi (GetPage))
            │   └── app_routes.dart
            └── bindings/           (<- "Penyuntik" dependensi (Get.lazyPut))
                 ├── class_binding.dart
                 └── todo_binding.dart
```

## 🏛️ Penjelasan Detail Layer

### 1. **Presentation Layer** (`lib/app/presentation`)

**Tanggung Jawab:**  
Segala sesuatu yang dilihat atau dapat berinteraksi dengan pengguna.

**Komponen:**

- **`pages/`** – Widget untuk setiap halaman (View), seperti `login_page.dart`, `home_page.dart`, `todo_list_page.dart`, dan lainnya.
- **`controllers/`** – Kelas `GetxController` (misal: `TodoController`) yang menyimpan state (misal `.obs`) dan merespons input pengguna (misal `onPressed`).
- **`widgets/`** – Komponen UI kustom yang dapat digunakan kembali (misal: `InputField`, `CustomCards`).

**Alur:**  
`View (Page)` memanggil fungsi di `Controller`.  
`Controller` kemudian memanggil `Use Case`.

---

### 2. **Domain Layer** (`lib/app/domain`)

**Tanggung Jawab:**  
Logika bisnis inti aplikasi. Layer ini murni Dart dan **tidak boleh bergantung pada Flutter** atau sumber data seperti API/Database.

**Komponen:**

- **`entities/`** – Model data murni (Plain Old Dart Object / PODO) yang digunakan oleh aplikasi (misal: `Todo`, `Course`).
  > Di sini, misalnya `Course` diperbaiki agar tidak menyimpan `Color`, melainkan `List<String> tagColorsHex` untuk menjaga kemurnian data.
- **`repositories/`** – Interface (kontrak) abstrak yang mendefinisikan apa yang harus dilakukan oleh layer data (misal: `ITodoRepository`, `ICourseRepository`).
- **`usecases/`** – Kelas dengan satu tanggung jawab yang berisi logika bisnis spesifik (misal: `GetAllTodosUseCase`, `AddTodoUseCase`).

**Alur:**  
`Use Case` dipanggil oleh `Controller`, dan `Use Case` memanggil fungsi dari `Interface Repository`.

---

### 3. **Data Layer** (`lib/app/data`)

**Tanggung Jawab:**  
Mengambil dan menyimpan data dari berbagai sumber. Ini adalah implementasi dari **kontrak Domain Layer**.

**Komponen:**

- **`datasources/`** – Kelas yang berinteraksi langsung dengan sumber data.
  - `todo_remote_data_source.dart` → Terhubung ke API Todo (`https://ls-lms.zoidify.my.id...`) menggunakan paket `http`.
  - `course_dummy_data_source.dart` → Mensimulasikan data `Course` secara lokal (data hardcoded) sesuai permintaan tugas.
- **`repositories/`** – Implementasi konkret dari `Interface Repository` (misal: `TodoRepositoryImpl`).

**Alur:**  
`RepositoryImpl` dipanggil oleh `Use Case`.  
Kemudian `RepositoryImpl` memanggil `DataSource` (API/Dummy) untuk mendapatkan data mentah, mengubahnya menjadi `Entity`, dan mengembalikannya ke `Domain Layer`.

---

### 4. **Core Layer** (`lib/app/core`)

**Tanggung Jawab:**  
Utilitas inti yang **menyatukan seluruh aplikasi**.

**Komponen:**

- **`routes/app_routes.dart`** – Mendefinisikan semua rute (`GetPage`) yang digunakan dalam aplikasi, seperti `/login`, `/home`, `/todo-detail`.
- **`bindings/`** – Kelas untuk _Dependency Injection (DI)_ menggunakan GetX, memastikan semua dependensi diinisialisasi sebelum halaman dimuat.

---

## 💉 Dependency Injection (DI)

Kami menggunakan **GetX Bindings** (`lib/app/core/bindings`) untuk mengatur dependensi antar-layer.

Setiap **Binding** (misal: `TodoBinding`) bertanggung jawab untuk menginisialisasi (`Get.lazyPut`) semua dependensi yang dibutuhkan oleh satu fitur, **dari belakang ke depan**:

1. **DataSource** → Misalnya `TodoRemoteDataSource`
2. **Repository (Interface + Implementasi)** → Misalnya `TodoRepositoryImpl` yang disuntik dengan `TodoRemoteDataSource`
3. **UseCase** → Misalnya `GetAllTodosUseCase` yang disuntik dengan `ITodoRepository`
4. **Controller** → Misalnya `TodoController` yang disuntik dengan semua `UseCases`

Binding ini kemudian dilampirkan pada route (misal `/home`) di `app_routes.dart`, dan digunakan oleh `GetMaterialApp`.

---

## ✅ Status Implementasi Data

Bagian ini menjelaskan **implementasi data final** yang menggantikan rencana integrasi API sebelumnya.

### 🔹 Modul Todo

Telah sepenuhnya **terhubung ke API live**  
`https://ls-lms.zoidify.my.id/api/todos`  
menggunakan `TodoRemoteDataSource`.

### 🔹 Modul Course

Masih **menggunakan data dummy** melalui `CourseDummyDataSource`,  
sesuai instruksi tugas untuk simulasi data lokal.

---

## ⚙️ Cara Integrasi API (Contoh: Todo)

Alih-alih sekadar rencana, berikut adalah **implementasi nyata** pada `TodoBinding`:

### Langkah-langkah:

1. **Daftarkan Supplier API (DataSource)**
2. **Daftarkan Kepala Koki (Repository) dan suntikkan DataSource-nya**
3. **Daftarkan UseCase dan Controller seperti biasa**

```dart
// File: lib/app/core/bindings/todo_binding.dart

// 1. Daftarkan Supplier API
Get.lazyPut<TodoRemoteDataSource>(
  () => TodoRemoteDataSource(),
  fenix: true,
);

// 2. Daftarkan Kepala Koki (Repo) dan suntik dengan Supplier
Get.lazyPut<ITodoRepository>(
  () => TodoRepositoryImpl(Get.find<TodoRemoteDataSource>()),
  fenix: true,
);

// 3. (Daftarkan Resep & Manajer seperti biasa...)

```
