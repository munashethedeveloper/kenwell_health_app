import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/logo/app_logo.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
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
          //titleColor: Color(0xFF201C58),
          titleColor: Colors.white,
          titleStyle: TextStyle(
            //color: Color(0xFF201C58),
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          automaticallyImplyLeading: true,
        ),
        // Body of the screen
        body: Consumer<HelpScreenViewModel>(
          builder: (context, viewModel, _) {
            // Main content
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 16),
                const AppLogo(size: 150),
                const SizedBox(height: 16),
                const SizedBox(height: 12),
                // Menu items
                _ProfileMenuItem(
                  icon: Icons.info_outline,
                  title: 'About the App',
                  subtitle:
                      'Version: ${viewModel.appVersion}\nDeveloper: ${viewModel.developer}',
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                //Contact support menu item
                _ProfileMenuItem(
                  icon: Icons.email_outlined,
                  title: 'Contact Support',
                  subtitle: 'mapiyem@kenwellhealthcare.co.za',
                  onTap: viewModel.contactSupport,
                ),
                const SizedBox(height: 24),
                // Menu items
                _ProfileMenuItem(
                  icon: Icons.help_outline,
                  title: 'FAQs / Help Center',
                  subtitle: 'Find answers to common questions and get help',
                  onTap: viewModel.openFAQs,
                ),
                const SizedBox(height: 12),
                // Menu items
                _ProfileMenuItem(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions / Privacy Policy',
                  subtitle: 'Read our terms and privacy policy',
                  onTap: viewModel.openTermsAndPrivacy,
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDestructive
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? Colors.red.withValues(alpha: 0.1)
                        : const Color(0xFF90C048).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive ? Colors.red : const Color(0xFF201C58),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDestructive
                              ? Colors.red
                              : const Color(0xFF201C58),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDestructive
                      ? Colors.red.withValues(alpha: 0.5)
                      : Colors.grey.shade400,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
