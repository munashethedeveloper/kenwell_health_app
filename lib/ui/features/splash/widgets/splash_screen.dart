import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/logo/app_logo.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../view_model/splash_view_model.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SplashViewModel(),
      child: const _SplashScreenBody(),
    );
  }
}

class _SplashScreenBody extends StatefulWidget {
  const _SplashScreenBody();

  @override
  State<_SplashScreenBody> createState() => _SplashScreenBodyState();
}

class _SplashScreenBodyState extends State<_SplashScreenBody>
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

    // Initialize app through ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final splashVM = context.read<SplashViewModel>();
      final authVM = context.read<AuthViewModel>();
      splashVM.initializeApp(authVM);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SplashViewModel>(
      builder: (context, viewModel, _) {
        // Handle navigation when target is determined
        if (viewModel.navigationTarget != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            final target = viewModel.navigationTarget!;
            viewModel.clearNavigationTarget();

            switch (target) {
              case SplashNavigationTarget.mainNavigation:
                context.go('/');
                break;
              case SplashNavigationTarget.authWrapper:
                context.go('/login');
                break;
            }
          });
        }

        return Scaffold(
          backgroundColor: Colors.blueAccent,
          body: FadeTransition(
            opacity: _animation,
            child: const Center(child: AppLogo(size: 150)),
          ),
        );
      },
    );
  }
}
