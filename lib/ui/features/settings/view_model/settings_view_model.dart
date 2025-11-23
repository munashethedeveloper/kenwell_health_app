import 'package:flutter/foundation.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({bool initialDarkMode = false}) : _darkMode = initialDarkMode;

  bool _darkMode;
  bool _notificationsEnabled = true;
  String _language = 'English';

  bool get darkMode => _darkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String get language => _language;

  // Toggle Dark Mode
  void toggleDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  // Toggle Notifications
  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  // Change App Language
  void changeLanguage(String newLang) {
    _language = newLang;
    notifyListeners();
  }

  // Simulate saving to local storage or cloud
  Future<void> saveSettings() async {
    await Future.delayed(const Duration(seconds: 1));
    // Save logic here (e.g., SharedPreferences or API)
    debugPrint(
        "Settings saved: DarkMode=$_darkMode, Notifications=$_notificationsEnabled, Language=$_language");
  }
}
