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
            title: 'Help & Support', automaticallyImplyLeading: false),
        body: Consumer<HelpScreenViewModel>(
          builder: (context, viewModel, _) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('FAQs / Help Center'),
                  onTap: viewModel.openFAQs,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Contact Support'),
                  subtitle: const Text('support@yourapp.com'),
                  onTap: viewModel.contactSupport,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About the App'),
                  subtitle: Text(
                      'Version: ${viewModel.appVersion}\nDeveloper: ${viewModel.developer}'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Terms & Conditions / Privacy Policy'),
                  onTap: viewModel.openTermsAndPrivacy,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
