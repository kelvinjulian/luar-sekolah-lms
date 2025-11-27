import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luar_sekolah_lms/app/presentation/widgets/input_field.dart';

void main() {
  testWidgets('InputField toggles password visibility', (
    WidgetTester tester,
  ) async {
    final controller = TextEditingController();

    // Gunakan StatefulBuilder untuk simulasi state lokal (toggle icon)
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

    // ASSERT: Elemen ada
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('InputField shows validator error', (WidgetTester tester) async {
    final controller = TextEditingController();
    // PENTING: Kita butuh GlobalKey untuk memicu validasi dari luar
    final formKey = GlobalKey<FormState>();

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
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Error Test' : null,
                ),
                // Tombol untuk memicu validasi
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

    // 1. Pastikan error belum muncul
    expect(find.text('Error Test'), findsNothing);

    // 2. ACT: Tekan tombol submit untuk memicu formKey.currentState.validate()
    await tester.tap(find.text("Submit"));
    await tester.pump(); // Rebuild UI untuk menampilkan pesan error

    // 3. ASSERT: Pastikan pesan error muncul
    expect(find.text('Error Test'), findsOneWidget);
  });
}
