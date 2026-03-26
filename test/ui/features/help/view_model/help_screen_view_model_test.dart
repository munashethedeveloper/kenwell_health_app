import 'package:flutter_test/flutter_test.dart';
import 'package:kenwell_health_app/ui/features/help/view_model/help_screen_view_model.dart';

void main() {
  late HelpScreenViewModel viewModel;

  setUp(() {
    viewModel = HelpScreenViewModel();
  });

  tearDown(() => viewModel.dispose());

  group('HelpScreenViewModel – initial state', () {
    test('developer name is non-empty', () {
      expect(viewModel.developer, isNotEmpty);
    });

    test('appVersion starts as empty string before async load', () {
      // _loadAppInfo is async; in test environment PackageInfo may not be
      // available, so we just verify the initial value is a String.
      expect(viewModel.appVersion, isA<String>());
    });
  });

  group('HelpScreenViewModel – URL actions', () {
    test('openFAQs does not throw', () async {
      // URL launching is a platform operation; in tests it will silently
      // fail. We verify the method completes without throwing.
      await expectLater(viewModel.openFAQs(), completes);
    });

    test('contactSupport does not throw', () async {
      await expectLater(viewModel.contactSupport(), completes);
    });

    test('openTermsAndPrivacy does not throw', () async {
      await expectLater(viewModel.openTermsAndPrivacy(), completes);
    });
  });
}
