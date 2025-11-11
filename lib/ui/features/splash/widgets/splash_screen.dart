import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/logo/app_logo.dart';
import '../../auth/widgets/auth_wrapper.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../../event/view_model/event_view_model.dart';
import '../../calendar/widgets/calendar_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _startSplash();
  }

  Future<void> _startSplash() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    await authVM.checkLoginStatus(); // checks if user is logged in

    if (!mounted) return;
    final isLoggedIn = authVM.isLoggedIn;

    if (isLoggedIn) {
      // Navigate to CalendarScreen and pass the EventViewModel
      final eventVM = Provider.of<EventViewModel>(context, listen: false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CalendarScreen(eventVM: eventVM),
        ),
      );
    } else {
      // Navigate to AuthWrapper if not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: FadeTransition(
        opacity: _animation,
        child: const Center(child: AppLogo(size: 150)),
      ),
    );
  }
}
