import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/logo/app_logo.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../view_model/help_screen_view_model.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HelpScreenViewModel(),
      child: Scaffold(
        appBar: const KenwellAppBar(
          title: 'Help & Support',
          automaticallyImplyLeading: false,
        ),
        body: Consumer<HelpScreenViewModel>(
          builder: (context, viewModel, _) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 16),
                const AppLogo(size: 200),
                const SizedBox(height: 16),
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
