import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class KenwellSignatureField extends StatelessWidget {
  const KenwellSignatureField({
    super.key,
    required this.controller,
    required this.onClear,
    this.height = 160,
    this.label = 'Kindly provide your signature below',
    this.backgroundColor,
    this.prefilledBase64,
  });

  final SignatureController controller;
  final VoidCallback onClear;
  final double height;
  final String? label;
  final Color? backgroundColor;

  /// Base64-encoded PNG from the consent form HP signature.
  /// When set and the drawing pad is empty, this image is shown as a visual
  /// preview with an auto-fill banner.  The drawing pad is always available
  /// so the nurse can override it by signing directly.
  final String? prefilledBase64;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final padIsEmpty = controller.isEmpty;
        final hasPrefilled =
            prefilledBase64 != null && prefilledBase64!.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null)
              Text(
                '$label:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            if (label != null) const SizedBox(height: 8),

            // ── Auto-fill banner ──────────────────────────────────────────
            if (hasPrefilled && padIsEmpty) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_fix_high,
                        size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'HP signature auto-filled from consent form. '
                        'Sign below to override.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Prefilled signature image
              Container(
                height: height,
                decoration: BoxDecoration(
                  color: backgroundColor ?? Colors.white,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(12)),
                  child: Image.memory(
                    base64Decode(prefilledBase64!),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Text(
                        'Signature preview unavailable',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Draw below to override:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 4),
            ],

            // ── Drawing pad ───────────────────────────────────────────────
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
      },
    );
  }
}
