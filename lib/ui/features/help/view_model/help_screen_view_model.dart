import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

// ViewModel for HelpScreen
class HelpScreenViewModel extends ChangeNotifier {
  // App version and developer info
  String _appVersion = '';
  final String _developer = 'Munashe Mapiye'; // Example developer name

  String get appVersion => _appVersion;
  String get developer => _developer;

  // Constructor
  HelpScreenViewModel() {
    _loadAppInfo();
  }

  // Load app version info
  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    _appVersion = '${info.version} (${info.buildNumber})';
    notifyListeners();
  }

  // Open FAQs URL
  Future<void> openFAQs() async {
    final url = Uri.parse('https://kenwellhealth.co.za/');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  // Contact support via email
  Future<void> contactSupport() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'mapiyem@kenwellhealthcare.co.za',
      query: 'subject=App Support Request',
    );
    if (await canLaunchUrl(emailLaunchUri)) await launchUrl(emailLaunchUri);
  }

  // Open Terms and Privacy URL
  Future<void> openTermsAndPrivacy() async {
    final url = Uri.parse('https://kenwellhealth.co.za/');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }
}
