import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../calendar/widgets/calendar_screen.dart';
import '../../event/view_model/event_view_model.dart';

class SplashViewModel extends ChangeNotifier {
  Future<void> initializeApp(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 3));
    navigateToCalendar(context); // call public method
  }

  void navigateToCalendar(BuildContext context) {
    final eventVM = Provider.of<EventViewModel>(context, listen: false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CalendarScreen(eventVM: eventVM),
      ),
    );
  }
}
