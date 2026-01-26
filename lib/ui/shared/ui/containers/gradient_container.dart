import 'package:flutter/material.dart';

/// A reusable container with a gradient background
class GradientContainer extends StatelessWidget {
  final Widget child;
  final List<Color> gradientColors;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  const GradientContainer({
    super.key,
    required this.child,
    required this.gradientColors,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.padding,
    this.margin,
    this.borderRadius = 12,
    this.boxShadow,
  });

  /// Purple to Green gradient (Brand colors)
  factory GradientContainer.purpleGreen({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = 12,
  }) {
    return GradientContainer(
      gradientColors: const [Color(0xFF90C048), Color(0xFF201C58)],
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF201C58).withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      child: child,
    );
  }

  /// Purple gradient
  factory GradientContainer.purple({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = 12,
  }) {
    return GradientContainer(
      gradientColors: const [Color(0xFF201C58), Color(0xFF2D2770)],
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF201C58).withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      child: child,
    );
  }

  /// Green gradient
  factory GradientContainer.green({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = 12,
  }) {
    return GradientContainer(
      gradientColors: const [Color(0xFF90C048), Color(0xFF7DA83E)],
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF90C048).withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: gradientBegin,
          end: gradientEnd,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}
