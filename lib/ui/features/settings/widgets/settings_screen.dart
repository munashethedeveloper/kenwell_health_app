import 'package:flutter/material.dart';
import 'package:kenwell_health_app/providers/theme_provider.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../view_model/settings_view_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingsViewModel(
        initialDarkMode: context.read<ThemeProvider>().isDarkMode,
      ),
      child: Scaffold(
        appBar: const KenwellAppBar(
          title: 'Settings',
          automaticallyImplyLeading: false,
        ),
        body: Consumer2<SettingsViewModel, ThemeProvider>(
          builder: (context, viewModel, themeProvider, _) {
            final colorScheme = Theme.of(context).colorScheme;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                KenwellFormCard(
                  margin: EdgeInsets.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: SwitchListTile.adaptive(
                    title: const Text('Dark Mode'),
                    subtitle: Text(
                      themeProvider.isDarkMode
                          ? 'Using Kenwell Dark theme'
                          : 'Using Kenwell Light theme',
                    ),
                    secondary: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: colorScheme.secondary,
                    ),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleDarkMode(value);
                      viewModel.toggleDarkMode(value);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                KenwellFormCard(
                  margin: EdgeInsets.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: SwitchListTile(
                    title: const Text('Enable Notifications'),
                    value: viewModel.notificationsEnabled,
                    onChanged: viewModel.toggleNotifications,
                  ),
                ),
                const SizedBox(height: 12),
                KenwellFormCard(
                  margin: EdgeInsets.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    title: const Text('Language'),
                    trailing: DropdownButton<String>(
                      value: viewModel.language,
                      items: const [
                        DropdownMenuItem(
                            value: 'English', child: Text('English')),
                        DropdownMenuItem(value: 'Zulu', child: Text('Zulu')),
                        DropdownMenuItem(
                            value: 'Afrikaans', child: Text('Afrikaans')),
                      ],
                      onChanged: (value) {
                        if (value != null) viewModel.changeLanguage(value);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                CustomPrimaryButton(
                  backgroundColor: KenwellColors.primaryGreen,
                  label: 'Save Settings',
                  onPressed: () async {
                    await viewModel.saveSettings();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        'Settings saved · ${themeProvider.isDarkMode ? 'Dark' : 'Light'} mode active',
                      ),
                    ));
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
