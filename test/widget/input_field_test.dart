//* 1. IMPORT
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import widget asli yang mau dites
import 'package:luar_sekolah_lms/app/presentation/widgets/input_field.dart';

void main() {
  //* SKENARIO 1: INTERAKSI ICON (Toggle Visibility)
  testWidgets('InputField toggles password visibility', (
    WidgetTester tester,
  ) async {
    final controller = TextEditingController();

    //? ARRANGE: Render Widget
    // Kita butuh MaterialApp + Scaffold karena InputField butuh Theme/Material context.
    // Kita pakai StatefulBuilder untuk mensimulasikan perubahan state (setState) dari luar.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              bool obscureText = true;
              return InputField(
                label: 'Password',
                hint: 'Masukkan password',
                controller: controller,
                obscureText: obscureText,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ),
    );

    //? ASSERT: Verifikasi Elemen
    // Pastikan TextFormField dirender
    expect(find.byType(TextFormField), findsOneWidget);
    // Pastikan Icon Mata ada
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  //* SKENARIO 2: VALIDASI FORM
  testWidgets('InputField shows validator error', (WidgetTester tester) async {
    final controller = TextEditingController();
    //? PENTING: GlobalKey dibutuhkan untuk memicu validasi dari luar widget input
    final formKey = GlobalKey<FormState>();

    //? ARRANGE: Render Widget dalam Form
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey, // Pasang Key di sini
            child: Column(
              children: [
                InputField(
                  label: 'Email',
                  hint: 'Email',
                  controller: controller,
                  // Validator sederhana untuk test
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Error Test' : null,
                ),
                // Tombol dummy untuk trigger validasi
                ElevatedButton(
                  onPressed: () => formKey.currentState?.validate(),
                  child: const Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // 1. Cek Awal: Pastikan error belum muncul
    expect(find.text('Error Test'), findsNothing);

    // 2. ACT: Tekan tombol submit untuk memicu formKey.currentState.validate()
    await tester.tap(find.text("Submit"));
    await tester
        .pump(); // Rebuild UI untuk menampilkan pesan error (frame selanjutnya)

    // 3. ASSERT: Pastikan pesan error muncul di layar
    expect(find.text('Error Test'), findsOneWidget);
  });
}
