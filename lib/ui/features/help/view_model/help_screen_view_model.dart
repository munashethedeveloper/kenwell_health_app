import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HelpScreenViewModel extends ChangeNotifier {
  String _appVersion = '';
  final String _developer = 'Munashe Mapiye'; // Example developer name

  String get appVersion => _appVersion;
  String get developer => _developer;

  HelpScreenViewModel() {
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    _appVersion = '${info.version} (${info.buildNumber})';
    notifyListeners();
  }

  Future<void> openFAQs() async {
    final url = Uri.parse('https://kenwellhealth.co.za/');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> contactSupport() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'mapiyem@kenwellhealthcare.co.za',
      query: 'subject=App Support Request',
    );
    if (await canLaunchUrl(emailLaunchUri)) await launchUrl(emailLaunchUri);
  }

  Future<void> openTermsAndPrivacy() async {
    final url = Uri.parse('https://kenwellhealth.co.za/');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }
}
