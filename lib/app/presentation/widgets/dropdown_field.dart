// lib/widgets/dropdown_field.dart

import 'package:flutter/material.dart';
import 'custom_dropdown.dart'; // Menggunakan CustomDropdown yang sudah ada

class DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final void Function(String?) onChanged;
  final double? labelSize;
  final FontWeight? labelWeight;

  const DropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.labelSize,
    this.labelWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bagian Label yang fleksibel
        Text(
          label,
          style: TextStyle(
            fontSize: labelSize ?? 16, // Default ke 16
            fontWeight: labelWeight ?? FontWeight.bold, // Default ke bold
          ),
        ),
        const SizedBox(height: 8),

        // Menggunakan CustomDropdown yang sudah Anda buat
        CustomDropdown(value: value, options: options, onChanged: onChanged),
      ],
    );
  }
}
