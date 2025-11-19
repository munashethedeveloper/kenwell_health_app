import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
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
                _buildCard(
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About the App'),
                    subtitle: Text(
                        'Version: ${viewModel.appVersion}\nDeveloper: ${viewModel.developer}'),
                  ),
                ),
                const SizedBox(height: 12),
                _buildCard(
                  child: ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('FAQs / Help Center'),
                    onTap: viewModel.openFAQs,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCard(
                  child: ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Contact Support'),
                    subtitle: const Text('mapiyem@kenwellhealthcare.co.za'),
                    onTap: viewModel.contactSupport,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCard(
                  child: ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('Terms & Conditions / Privacy Policy'),
                    onTap: viewModel.openTermsAndPrivacy,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- Card wrapper for modern look ---
  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: child,
      ),
    );
  }
}
