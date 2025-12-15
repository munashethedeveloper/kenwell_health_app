import 'package:flutter/material.dart';
import 'package:kenwell_health_app/domain/constants/user_roles.dart';
import 'package:kenwell_health_app/routing/route_names.dart';
import 'package:kenwell_health_app/ui/features/auth/widgets/login_screen.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';
import 'package:kenwell_health_app/utils/validators.dart';
import '../../../../data/services/auth_service.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
import '../../../shared/ui/logo/app_logo.dart';

class UserManagementScreenVersionTwo extends StatefulWidget {
  const UserManagementScreenVersionTwo({super.key});

  @override
  State<UserManagementScreenVersionTwo> createState() =>
      _UserManagementScreenVersionTwoState();
}

class _UserManagementScreenVersionTwoState
    extends State<UserManagementScreenVersionTwo> {
  Future<void> _logout() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: KenwellAppBar(
          title: 'User Management',
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(color: Color(0xFF90C048)),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.person_add), text: 'Create User'),
              Tab(icon: Icon(Icons.group), text: 'View Users'),
              //Tab(text: 'Create User'),
              //Tab(text: 'View Users'),
            ],
          ),
          actions: [
            PopupMenuButton<int>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) async {
                switch (value) {
                  case 0:
                    if (mounted) {
                      Navigator.pushNamed(context, RouteNames.profile);
                    }
                    break;
                  case 1:
                    if (mounted) {
                      Navigator.pushNamed(context, RouteNames.help);
                    }
                    break;
                  case 2:
                    await _logout();
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<int>(
                  value: 0,
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Profile'),
                  ),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  child: ListTile(
                    leading: Icon(Icons.help_outline),
                    title: Text('Help'),
                  ),
                ),
                PopupMenuItem<int>(
                  value: 2,
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            CreateUserTab(),
            ViewUsersTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------- Create User Tab ----------------
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

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (_selectedRole == null) {
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
        role: _selectedRole!,
        phoneNumber: _phoneController.text.trim(),
        username: _usernameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      if (!mounted) return;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed')),
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
                title: "Register User Account",
                subtitle:
                    "Complete the user's details below to create an account.",
              ),
              KenwellFormCard(
                title: 'Personal Information',
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    KenwellTextField(
                      label: "First Name",
                      controller: _firstNameController,
                      inputFormatters:
                          AppTextInputFormatters.lettersOnly(allowHyphen: true),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter First Name' : null,
                    ),
                    const SizedBox(height: 24),
                    KenwellTextField(
                      label: "Last Name",
                      controller: _lastNameController,
                      inputFormatters:
                          AppTextInputFormatters.lettersOnly(allowHyphen: true),
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
                    KenwellTextField(
                      label: "Phone Number",
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        AppTextInputFormatters.saPhoneNumberFormatter()
                      ],
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
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 24),
                    KenwellTextField(
                      label: "Password",
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const AppLogo(size: 200),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                child: ListTile(
                  title: Text(user['email']!),
                  trailing: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh),
                      Icon(Icons.delete),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
