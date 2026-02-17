import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/international_form_field.dart';
import 'package:provider/provider.dart';
import '../../../../../domain/constants/user_roles.dart';
import '../../../../../utils/input_formatters.dart';
import '../../../../../utils/validators.dart';
import '../../../../shared/ui/buttons/custom_primary_button.dart';
import '../../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../../shared/ui/form/custom_text_field.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import '../../../../shared/ui/form/kenwell_section_header.dart';
import '../../../../shared/ui/logo/app_logo.dart';
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
  bool _obscureConfirmPassword = true;

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
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const AppLogo(size: 200),
                  const SizedBox(height: 24),
                  const KenwellSectionHeader(
                    title: "User Registration Form",
                    subtitle:
                        "Complete the user's details below to create an account.",
                    icon: Icons.person_add_alt_1,
                  ),
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
                    label: "Register",
                    onPressed: _register,
                    isBusy: viewModel.isLoading,
                  ),
                  if (_verificationSent) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(_isVerified
                              ? 'Email verified!'
                              : 'Please verify your email (check inbox)'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Check verification',
                          onPressed: _checkEmailVerified,
                        ),
                        TextButton(
                          onPressed: _resendVerification,
                          child: const Text('Resend Email'),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
