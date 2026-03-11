import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/headers/kenwell_gradient_header.dart';

import '../app_bar/kenwell_app_bar.dart';

/// Reusable page shell that standardizes Kenwell form layouts.
///
/// Renders a solid-green [KenwellAppBar] followed by a [KenwellGradientHeader]
/// (when [sectionTitle] is provided) that is fixed at the top of the viewport.
/// The form children scroll beneath the header inside an [Expanded] view.
class KenwellFormPage extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final GlobalKey<FormState>? formKey;
  final PreferredSizeWidget? appBar;
  final EdgeInsetsGeometry padding;
  final String? sectionTitle;
  final String? sectionLabel;
  final String? subtitle;
  final bool uppercaseSectionTitle;
  final double sectionSpacing;
  final bool automaticallyImplyLeading;

  const KenwellFormPage({
    super.key,
    required this.title,
    required this.children,
    this.formKey,
    this.appBar,
    this.padding = const EdgeInsets.all(16),
    this.sectionTitle,
    this.sectionLabel,
    this.subtitle,
    this.uppercaseSectionTitle = true,
    this.sectionSpacing = 16,
    this.automaticallyImplyLeading = false,
  });

  @override
  Widget build(BuildContext context) {
    final preferredAppBar = appBar ??
        KenwellAppBar(
          title: title,
          backgroundColor: KenwellColors.primaryGreen,
          automaticallyImplyLeading: automaticallyImplyLeading,
        );

    final scrollChild = formKey != null
        ? Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          );

    return Scaffold(
      appBar: preferredAppBar,
      body: Column(
        children: [
          // ── Gradient section header ──────────────────────────────────
          if (sectionTitle != null)
            KenwellGradientHeader(
              label: sectionLabel ?? title.toUpperCase(),
              title: sectionTitle!,
              subtitle: subtitle ?? '',
            ),
          // ── Scrollable form content ──────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: padding,
              child: scrollChild,
            ),
          ),
        ],
      ),
    );
  }
}
