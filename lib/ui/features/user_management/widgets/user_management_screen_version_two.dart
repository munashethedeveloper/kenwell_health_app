import 'package:flutter/material.dart';
import 'package:kenwell_health_app/domain/constants/user_roles.dart';
import 'package:kenwell_health_app/ui/features/auth/widgets/login_screen.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';
import 'package:kenwell_health_app/utils/validators.dart';
import '../../../../data/services/auth_service.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
import '../../../shared/ui/logo/app_logo.dart';

class UserManagementScreenVersionTwo extends StatelessWidget {
  const UserManagementScreenVersionTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Create User'),
              Tab(text: 'View Users'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CreateUserTab(), // <-- full registration form
            ViewUsersTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------- Create User Tab (Full Registration Form) ----------------
class CreateUserTab extends StatefulWidget {
  const CreateUserTab({super.key});

  @override
  State<CreateUserTab> createState() => _CreateUserTabState();
}

class _CreateUserTabState extends State<CreateUserTab> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  String? _selectedRole;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final role = _selectedRole;
    if (role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await AuthService().register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: role,
        phoneNumber: _phoneController.text.trim(),
        username: _usernameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      if (!mounted) return;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Registration successful! Please log in.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Registration failed. Email may already exist.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Registration error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                title: "Register Account",
                subtitle: "Complete your details or continue with social media",
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
                        allowHyphen: true,
                      ),
                      padding: EdgeInsets.zero,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? "Enter First Name" : null,
                    ),
                    const SizedBox(height: 24),
                    KenwellTextField(
                      label: "Last Name",
                      controller: _lastNameController,
                      inputFormatters: AppTextInputFormatters.lettersOnly(
                        allowHyphen: true,
                      ),
                      padding: EdgeInsets.zero,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? "Enter Last Name" : null,
                    ),
                    const SizedBox(height: 24),
                    KenwellDropdownField<String>(
                      label: "Role",
                      value: _selectedRole,
                      items: UserRoles.values,
                      padding: EdgeInsets.zero,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? "Select Role" : null,
                      onChanged: (value) =>
                          setState(() => _selectedRole = value),
                    ),
                    const SizedBox(height: 24),
                    KenwellTextField(
                      label: "Phone Number",
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        AppTextInputFormatters.saPhoneNumberFormatter()
                      ],
                      padding: EdgeInsets.zero,
                      validator: Validators.validateSouthAfricanPhoneNumber,
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
                      padding: EdgeInsets.zero,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 24),
                    KenwellTextField(
                      label: "Password",
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      padding: EdgeInsets.zero,
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
                isBusy: _isLoading,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- View Users Tab ----------------
class ViewUsersTab extends StatelessWidget {
  const ViewUsersTab({super.key});

  final List<Map<String, String>> users = const [
    {'email': 'user1@example.com'},
    {'email': 'user2@example.com'},
  ];

  void _resetPassword(String email) {
    // TODO: Implement password reset logic
    print('Reset password for $email');
  }

  void _deleteUser(String email) {
    // TODO: Implement delete logic
    print('Deleted $email');
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text(user['email']!),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset Password',
                  onPressed: () => _resetPassword(user['email']!),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete User',
                  onPressed: () => _deleteUser(user['email']!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
