import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../view_model/settings_view_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: Scaffold(
        appBar: const KenwellAppBar(
          title: 'Settings',
          automaticallyImplyLeading: false,
        ),
        body: Consumer<SettingsViewModel>(
          builder: (context, viewModel, _) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCard(
                  child: SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: viewModel.darkMode,
                    onChanged: viewModel.toggleDarkMode,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCard(
                  child: SwitchListTile(
                    title: const Text('Enable Notifications'),
                    value: viewModel.notificationsEnabled,
                    onChanged: viewModel.toggleNotifications,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCard(
                  child: ListTile(
                    title: const Text('Language'),
                    trailing: DropdownButton<String>(
                      value: viewModel.language,
                      items: const [
                        DropdownMenuItem(
                            value: 'English', child: Text('English')),
                        DropdownMenuItem(
                            value: 'French', child: Text('French')),
                        DropdownMenuItem(
                            value: 'Spanish', child: Text('Spanish')),
                      ],
                      onChanged: (value) {
                        if (value != null) viewModel.changeLanguage(value);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                CustomPrimaryButton(
                  label: 'Save Settings',
                  onPressed: () async {
                    await viewModel.saveSettings();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings saved!')),
                    );
                  },
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
