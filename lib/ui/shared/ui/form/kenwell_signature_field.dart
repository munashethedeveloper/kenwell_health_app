import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

/// Signature capture widget used in health screening forms.
///
/// **Behaviour when [prefilledBase64] is set:**
///  - Shows the consent-form HP signature as a read-only image.
///  - Shows a "Override Signature" button.
///  - The drawing pad is hidden by default and revealed only when the
///    user taps "Override Signature".
///
/// **Behaviour when [prefilledBase64] is null:**
///  - Shows only the drawing pad (standard flow).
class KenwellSignatureField extends StatefulWidget {
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
  /// When set, the image is shown and the drawing pad is hidden until
  /// the user explicitly chooses to override.
  final String? prefilledBase64;

  @override
  State<KenwellSignatureField> createState() => _KenwellSignatureFieldState();
}

class _KenwellSignatureFieldState extends State<KenwellSignatureField> {
  /// Whether the user has tapped "Override Signature" to reveal the pad.
  bool _showOverridePad = false;

  @override
  Widget build(BuildContext context) {
    final hasPrefilled =
        widget.prefilledBase64 != null && widget.prefilledBase64!.isNotEmpty;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (hasPrefilled && !_showOverridePad) {
          // ── Prefilled-image mode ──────────────────────────────────
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.label != null) ...[
                Text(
                  '${widget.label}:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Banner
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
                    Icon(Icons.verified_rounded,
                        size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'HP signature from consent form',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Signature image
              Container(
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? Colors.white,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12)),
                  child: Image.memory(
                    base64Decode(widget.prefilledBase64!),
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

              const SizedBox(height: 8),

              // Override button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () =>
                      setState(() => _showOverridePad = true),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Override Signature'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange.shade700,
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ],
          );
        }

        // ── Drawing-pad mode ────────────────────────────────────────
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              Text(
                '${widget.label}:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // If we revealed the pad from override mode, show info banner
            if (hasPrefilled && _showOverridePad) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded,
                        size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Draw a new signature to override the consent signature.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.onClear();
                        setState(() => _showOverridePad = false);
                      },
                      child: Icon(Icons.close_rounded,
                          size: 16, color: Colors.orange.shade700),
                    ),
                  ],
                ),
              ),
            ],

            // Drawing pad
            Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Colors.grey[100],
                borderRadius: (hasPrefilled && _showOverridePad)
                    ? const BorderRadius.vertical(
                        bottom: Radius.circular(12))
                    : BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.all(8),
              child: Signature(
                controller: widget.controller,
                backgroundColor:
                    widget.backgroundColor ?? Colors.grey[100]!,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.onClear,
                child: const Text('Clear Signature'),
              ),
            ),
          ],
        );
      },
    );
  }
}
