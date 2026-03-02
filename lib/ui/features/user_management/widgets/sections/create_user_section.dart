import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/international_form_field.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/kenwell_modern_section_header.dart';
import 'package:provider/provider.dart';
import '../../../../../domain/constants/user_roles.dart';
import '../../../../../utils/input_formatters.dart';
import '../../../../../utils/validators.dart';
import '../../../../shared/ui/buttons/custom_primary_button.dart';
import '../../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../../shared/ui/form/custom_text_field.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import '../../viewmodel/user_management_view_model.dart';

/// Create user form section
class CreateUserSection extends StatefulWidget {
  final VoidCallback? onUserCreated;

  const CreateUserSection({super.key, this.onUserCreated});

  @override
  State<CreateUserSection> createState() => _CreateUserSectionState();
}

class _CreateUserSectionState extends State<CreateUserSection> {
  bool _verificationSent = false;
  bool _isVerified = false;

  Future<void> _checkEmailVerified() async {
    final viewModel = context.read<UserManagementViewModel>();
    final verified = await viewModel.isEmailVerified();
    setState(() {
      _isVerified = verified;
    });

    // If verified, sync the status to Firestore so it's reflected everywhere
    if (verified) {
      await viewModel.syncCurrentUserVerificationStatus();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Email verified! Status synced to database.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email not yet verified.')),
      );
    }
  }

  Future<void> _resendVerification() async {
    final viewModel = context.read<UserManagementViewModel>();
    await viewModel.sendEmailVerification();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification email resent.')),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  String? _selectedRole;
  bool _obscurePassword = true;
  //bool _obscureConfirmPassword = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role')),
      );
      return;
    }

    final viewModel = context.read<UserManagementViewModel>();

    final success = await viewModel.registerUser(
      email: _emailController.text,
      password: _passwordController.text,
      //confirmPassword: _confirmPasswordController.text,
      role: _selectedRole!,
      phoneNumber: _phoneController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _verificationSent = true;
        _isVerified = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(viewModel.successMessage ??
                'User registered successfully! Password reset email sent.')),
      );
      // Clear the form
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _phoneController.clear();
      _firstNameController.clear();
      _lastNameController.clear();
      setState(() => _selectedRole = null);
      widget.onUserCreated?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(viewModel.errorMessage ?? 'Registration failed')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagementViewModel>(
      builder: (context, viewModel, child) {
        final theme = Theme.of(context);

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  /*   // Compact section header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.person_add_rounded,
                          color: theme.primaryColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New User Registration',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF201C58),
                            ),
                          ),
                          Text(
                            'Complete the form to register a new user',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ), */

                  const KenwellModernSectionHeader(
                    title: 'New User Registration',
                    subtitle: 'Complete the form to register a new user',
                  ),
                  const SizedBox(height: 20),
                  KenwellFormCard(
                    title: 'Personal Information',
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        KenwellTextField(
                          label: "First Name",
                          controller: _firstNameController,
                          inputFormatters: AppTextInputFormatters.lettersOnly(
                              allowHyphen: true),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Enter First Name'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        KenwellTextField(
                          label: "Last Name",
                          controller: _lastNameController,
                          inputFormatters: AppTextInputFormatters.lettersOnly(
                              allowHyphen: true),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Enter Last Name' : null,
                        ),
                        const SizedBox(height: 24),
                        KenwellDropdownField<String>(
                          label: "Role",
                          value: _selectedRole,
                          items: UserRoles.values,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Select Role' : null,
                          onChanged: (value) =>
                              setState(() => _selectedRole = value),
                        ),
                        const SizedBox(height: 24),
                        InternationalPhoneField(
                          label: "Phone Number",
                          controller: _phoneController,
                          padding: EdgeInsets.zero,
                          validator:
                              Validators.validateInternationalPhoneNumber,
                        ),
                      ],
                    ),
                  ),
                  KenwellFormCard(
                    title: 'Account Credentials',
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      children: [
                        KenwellTextField(
                          label: "Email",
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 24),
                        KenwellTextField(
                          label: "Temporary Password",
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          validator: Validators.validateStrongPassword,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  CustomPrimaryButton(
                    label: "Register User",
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      //color: KenwellColors.secondaryNavy,
                      color: Colors.white,
                    ),
                    onPressed: _register,
                    isBusy: viewModel.isLoading,
                  ),
                  if (_verificationSent) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _isVerified
                            ? const Color(0xFF10B981).withValues(alpha: 0.08)
                            : theme.primaryColor.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isVerified
                              ? const Color(0xFF10B981).withValues(alpha: 0.3)
                              : theme.primaryColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isVerified
                                ? Icons.verified_rounded
                                : Icons.mark_email_unread_rounded,
                            color: _isVerified
                                ? const Color(0xFF10B981)
                                : theme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _isVerified
                                  ? 'Email verified successfully!'
                                  : 'Verification email sent – check inbox',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _isVerified
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF201C58),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.refresh_rounded,
                              size: 18,
                              color: theme.primaryColor,
                            ),
                            tooltip: 'Check verification status',
                            onPressed: _checkEmailVerified,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 4),
                          TextButton(
                            onPressed: _resendVerification,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Resend',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
