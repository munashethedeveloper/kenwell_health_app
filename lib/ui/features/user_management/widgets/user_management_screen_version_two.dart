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
  final GlobalKey<_ViewUsersTabState> _viewUsersKey = GlobalKey();

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
        body: TabBarView(
          children: [
            CreateUserTab(
              onUserCreated: () {
                _viewUsersKey.currentState?.refreshUsers();
              },
            ),
            ViewUsersTab(key: _viewUsersKey),
          ],
        ),
      ),
    );
  }
}

// ---------------- Create User Tab ----------------
class CreateUserTab extends StatefulWidget {
  final VoidCallback? onUserCreated;

  const CreateUserTab({super.key, this.onUserCreated});

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
        // username: _usernameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      if (!mounted) return;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        // Clear the form
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _phoneController.clear();
        _firstNameController.clear();
        _lastNameController.clear();
        setState(() => _selectedRole = null);
        // Notify parent to refresh user list
        widget.onUserCreated?.call();
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
class ViewUsersTab extends StatefulWidget {
  const ViewUsersTab({super.key});

  @override
  State<ViewUsersTab> createState() => _ViewUsersTabState();
}

class _ViewUsersTabState extends State<ViewUsersTab> {
  final AuthService _authService = AuthService();
  List<Map<String, String>> users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final fetchedUsers = await _authService.getAllUsers();
      setState(() {
        users = fetchedUsers
            .map((user) => {
                  'id': user.id,
                  'email': user.email,
                  'firstName': user.firstName,
                  'lastName': user.lastName,
                  'role': user.role,
                  'phoneNumber': user.phoneNumber,
                })
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void refreshUsers() {
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const AppLogo(size: 200),
        const SizedBox(height: 16),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : users.isEmpty
                  ? const Center(
                      child: Text(
                        'No users registered yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadUsers,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final firstName = user['firstName'] ?? '';
                          final lastName = user['lastName'] ?? '';
                          final email = user['email'] ?? '';
                          final role = user['role'] ?? '';
                          final phoneNumber = user['phoneNumber'] ?? '';
                          
                          // Create initials safely
                          final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
                          final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
                          final initials = firstInitial + lastInitial;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF201C58),
                                child: Text(
                                  initials.isNotEmpty ? initials : '?',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                '$firstName $lastName',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(email),
                                  Text(
                                    '$role • $phoneNumber',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
