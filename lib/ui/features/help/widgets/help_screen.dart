import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/logo/app_logo.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../view_model/help_screen_view_model.dart';

// HelpScreen provides help and support information to users
class HelpScreen extends StatelessWidget {
  // Constructor
  const HelpScreen({super.key});

  // Build method
  @override
  Widget build(BuildContext context) {
    // Provide HelpScreenViewModel to the widget tree
    return ChangeNotifierProvider(
      create: (_) => HelpScreenViewModel(),
      child: Scaffold(
        // App bar
        appBar: const KenwellAppBar(
          title: 'Help & Support',
          titleColor: Color(0xFF201C58),
          titleStyle: TextStyle(
            color: Color(0xFF201C58),
            fontWeight: FontWeight.bold,
          ),
          automaticallyImplyLeading: false,
        ),
        // Body of the screen
        body: Consumer<HelpScreenViewModel>(
          builder: (context, viewModel, _) {
            // Main content
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 16),
                const AppLogo(size: 200),
                const SizedBox(height: 16),
                //  About the App section
                KenwellFormCard(
                  margin: EdgeInsets.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About the App'),
                    subtitle: Text(
                      'Version: ${viewModel.appVersion}\nDeveloper: ${viewModel.developer}',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // FAQs / Help Center section
                KenwellFormCard(
                  margin: EdgeInsets.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('FAQs / Help Center'),
                    onTap: viewModel.openFAQs,
                  ),
                ),
                const SizedBox(height: 12),
                // Contact Support section
                KenwellFormCard(
                  margin: EdgeInsets.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Contact Support'),
                    subtitle: const Text('mapiyem@kenwellhealthcare.co.za'),
                    onTap: viewModel.contactSupport,
                  ),
                ),
                const SizedBox(height: 12),
                // Terms & Conditions / Privacy Policy section
                KenwellFormCard(
                  margin: EdgeInsets.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('Terms & Conditions / Privacy Policy'),
                    onTap: viewModel.openTermsAndPrivacy,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: KenwellColors.primaryGreen, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: KenwellColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
