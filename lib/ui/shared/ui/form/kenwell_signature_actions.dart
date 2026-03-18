import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import 'kenwell_form_card.dart';
import 'kenwell_signature_field.dart';

/// Combines a signature capture card with trailing action buttons/navigation.
///
/// When [prefilledBase64] is provided, the consent form's HP signature is shown
/// as a read-only image below a banner.  The live drawing pad is still shown
/// so the nurse can override the prefilled signature if needed.
class KenwellSignatureActions extends StatelessWidget {
  final SignatureController controller;
  final VoidCallback onClear;
  final Widget? navigation;
  final String? title;
  final double spacing;

  /// Base64-encoded PNG of the HP signature captured during the consent form.
  /// When set (and the drawing pad is empty), the image is displayed to
  /// indicate that the signature has been auto-populated.
  final String? prefilledBase64;

  const KenwellSignatureActions({
    super.key,
    required this.controller,
    required this.onClear,
    this.navigation,
    this.title,
    this.spacing = 24,
    this.prefilledBase64,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KenwellFormCard(
          title: title,
          child: KenwellSignatureField(
            controller: controller,
            onClear: onClear,
            prefilledBase64: prefilledBase64,
          ),
        ),
        if (navigation != null) ...[
          SizedBox(height: spacing),
          navigation!,
        ],
      ],
    );
  }
}
