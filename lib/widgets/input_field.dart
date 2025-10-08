import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final Widget? suffixIcon;
  final int minLines;
  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType keyboardType; // DITAMBAHKAN

  const InputField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.suffixIcon,
    this.minLines = 1,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text, // DITAMBAHKAN
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          minLines: minLines,
          maxLines: maxLines,
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboardType, // DIGUNAKAN
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF7B7F95)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 12,
            ),
            suffixIcon: suffixIcon,
            isDense: true,
          ),
          style: const TextStyle(fontSize: 15, color: Colors.black),
        ),
      ],
    );
  }
}
