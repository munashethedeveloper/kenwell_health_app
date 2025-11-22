import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class KenwellSignatureField extends StatelessWidget {
  const KenwellSignatureField({
    super.key,
    required this.controller,
    required this.onClear,
    this.height = 160,
    this.label = 'Signature',
    this.backgroundColor,
  });

  final SignatureController controller;
  final VoidCallback onClear;
  final double height;
  final String? label;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF201C58),
            ),
          ),
        if (label != null) const SizedBox(height: 8),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.all(8),
          child: Signature(
            controller: controller,
            backgroundColor: backgroundColor ?? Colors.grey[100]!,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onClear,
            child: const Text('Clear Signature'),
          ),
        ),
      ],
    );
  }
}
