import 'package:flutter/widgets.dart';

typedef KenwellFormStepBuilder = Widget Function(BuildContext context);

/// Declarative representation of a form section/step within a screen.
class KenwellFormStep {
  final KenwellFormStepBuilder builder;
  final double spacingAfter;

  const KenwellFormStep({
    required this.builder,
    this.spacingAfter = 24,
  });
}
