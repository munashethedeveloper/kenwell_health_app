import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import 'kenwell_form_card.dart';
import 'kenwell_signature_field.dart';

/// Combines a signature capture card with trailing action buttons/navigation.
class KenwellSignatureActions extends StatelessWidget {
  final SignatureController controller;
  final VoidCallback onClear;
  final Widget navigation;
  final String? title;
  final double spacing;

  const KenwellSignatureActions({
    super.key,
    required this.controller,
    required this.onClear,
    required this.navigation,
    this.title,
    this.spacing = 24,
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
          ),
        ),
        SizedBox(height: spacing),
        navigation,
      ],
    );
  }
}
