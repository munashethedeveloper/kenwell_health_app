import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:provider/provider.dart';
import '../../../../data/repositories_dcl/auth_repository_dcl.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import 'package:kenwell_health_app/utils/validators.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/login_view_model.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';

// Login Screen Widget
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(AuthRepository()),
      child: const _LoginScreenBody(),
    );
  }
}

class _LoginScreenBody extends StatefulWidget {
  const _LoginScreenBody();

  @override
  State<_LoginScreenBody> createState() => _LoginScreenBodyState();
}

class _LoginScreenBodyState extends State<_LoginScreenBody> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    final viewModel = context.read<LoginViewModel>();
    viewModel.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(builder: (context, viewModel, _) {
      if (viewModel.navigationTarget != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          final profileVM = context.read<ProfileViewModel>();
          final authVM = context.read<AuthViewModel>();
          await profileVM.loadProfile();
          await authVM.checkLoginStatus();
          viewModel.clearNavigationTarget();
          if (mounted) context.go('/');
        });
      }

      if (viewModel.errorMessage != null && !viewModel.needsEmailVerification) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          AppSnackbar.showError(context, viewModel.errorMessage!);
          viewModel.clearError();
        });
      }

      return Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        body: Stack(
          children: [
            // ── Gradient top-half ─────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.42,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1454), Color(0xFF0B6B49)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App icon
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 2),
                        ),
                        child: const Icon(
                          Icons.health_and_safety_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'KenWell365',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Supporting wellbeing, 365 days a year',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Form card ─────────────────────────────────────────────────
            Positioned.fill(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.34),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: KenwellColors.secondaryNavy,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Welcome back — enter your credentials',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 28),
                            KenwellTextField(
                              label: 'Email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              padding: EdgeInsets.zero,
                              validator: Validators.validateEmail,
                            ),
                            const SizedBox(height: 16),
                            KenwellTextField(
                              label: 'Password',
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              padding: EdgeInsets.zero,
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                              validator: Validators.validatePasswordPresence,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () =>
                                    context.pushNamed('forgotPassword'),
                                style: TextButton.styleFrom(
                                    padding: const EdgeInsets.only(
                                        top: 4, bottom: 4)),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: KenwellColors.secondaryNavy,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // ── Lockout banner ─────────────────────────────
                            if (viewModel.isLockedOut) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  border:
                                      Border.all(color: Colors.orange.shade300),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.lock_clock_outlined,
                                        size: 18,
                                        color: Colors.orange.shade700),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Too many failed attempts. '
                                        'Try again in '
                                        '${viewModel.lockoutSecondsRemaining}s.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.orange.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],

                            // ── Email verification banner ──────────────────
                            if (viewModel.needsEmailVerification) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  border:
                                      Border.all(color: Colors.amber.shade400),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.mark_email_unread_outlined,
                                            size: 18,
                                            color: Colors.amber.shade800),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Email not verified. Check your '
                                            'inbox for a verification link.',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.amber.shade900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    GestureDetector(
                                      onTap: () async {
                                        await viewModel
                                            .resendVerificationEmail();
                                        if (mounted) {
                                          AppSnackbar.showSuccess(
                                              context,
                                              'Verification email sent — '
                                              'please check your inbox.');
                                        }
                                      },
                                      child: Text(
                                        'Resend verification email',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.amber.shade900,
                                          fontWeight: FontWeight.w700,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],

                            CustomPrimaryButton(
                              label: 'Sign In',
                              minHeight: 20,
                              labelStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              onPressed:
                                  viewModel.isLockedOut ? null : _handleLogin,
                              isBusy: viewModel.isLoading,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
