import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/settings_view_model.dart';
import '../../../core/ui/shared/shared.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
      return ChangeNotifierProvider(
        create: (_) => SettingsViewModel(),
        child: Scaffold(
          appBar: const KenwellAppBar(
            title: 'Settings',
          ),
          body: Consumer<SettingsViewModel>(
            builder: (context, viewModel, _) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                // Dark Mode Toggle
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: viewModel.darkMode,
                  onChanged: viewModel.toggleDarkMode,
                ),

                const Divider(),

                // Notifications Toggle
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  value: viewModel.notificationsEnabled,
                  onChanged: viewModel.toggleNotifications,
                ),

                const Divider(),

                // Language Dropdown
                ListTile(
                  title: const Text('Language'),
                  trailing: DropdownButton<String>(
                    value: viewModel.language,
                    items: const [
                      DropdownMenuItem(
                          value: 'English', child: Text('English')),
                      DropdownMenuItem(value: 'French', child: Text('French')),
                      DropdownMenuItem(
                          value: 'Spanish', child: Text('Spanish')),
                    ],
                    onChanged: (value) {
                      if (value != null) viewModel.changeLanguage(value);
                    },
                  ),
                ),

                const SizedBox(height: 20),

                  // Save Button
                  KenwellFilledButton(
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
}
