import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignatureField extends StatelessWidget {
  const SignatureField({
    super.key,
    required this.controller,
    this.title = 'Signature',
    this.height = 150,
    this.onClear,
    this.padding = const EdgeInsets.only(bottom: 12),
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.grey,
  });

  final SignatureController controller;
  final String title;
  final double height;
  final VoidCallback? onClear;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            height: height,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
            ),
            child: Signature(
              controller: controller,
              backgroundColor: backgroundColor,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onClear ?? controller.clear,
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
