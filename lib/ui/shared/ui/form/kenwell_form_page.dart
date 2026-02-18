import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';

import '../app_bar/kenwell_app_bar.dart';
import 'kenwell_modern_section_header.dart';

/// Reusable page shell that standardizes Kenwell form layouts.
class KenwellFormPage extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final GlobalKey<FormState>? formKey;
  final PreferredSizeWidget? appBar;
  final EdgeInsetsGeometry padding;
  final String? sectionTitle;
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
    this.uppercaseSectionTitle = true,
    this.sectionSpacing = 16,
    this.automaticallyImplyLeading = false,
  });

  @override
  Widget build(BuildContext context) {
    final contentChildren = <Widget>[
      if (sectionTitle != null) ...[
        KenwellModernSectionHeader(
          title: sectionTitle!,
          uppercase: uppercaseSectionTitle,
        ),
        SizedBox(height: sectionSpacing),
      ],
      ...children,
    ];

    final body = SingleChildScrollView(
      padding: padding,
      child: formKey != null
          ? Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: contentChildren,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: contentChildren,
            ),
    );

    final preferredAppBar = appBar ??
        KenwellAppBar(
          title: title,
          backgroundColor: KenwellColors.primaryGreen,
          automaticallyImplyLeading: automaticallyImplyLeading,
        );

    return Scaffold(
      appBar: preferredAppBar,
      body: body,
    );
  }
}
