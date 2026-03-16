import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/headers/kenwell_gradient_header.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../view_model/profile_view_model.dart';
import 'sections/profile_form_section.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileScreenBody();
  }
}

class _ProfileScreenBody extends StatefulWidget {
  const _ProfileScreenBody();

  @override
  State<_ProfileScreenBody> createState() => _ProfileScreenBodyState();
}

class _ProfileScreenBodyState extends State<_ProfileScreenBody> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  String? _selectedRole;

  // Store original values to detect changes

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndPopulateProfile();
    });
  }

  Future<void> _loadAndPopulateProfile() async {
    final vm = context.read<ProfileViewModel>();
    await vm.loadProfile();
    if (!mounted) return;

    setState(() {
      _syncControllersWithViewModel(vm);
    });

    // Show error if load failed
    if (vm.errorMessage != null && mounted) {
      AppSnackbar.showError(context, vm.errorMessage!);
    }
  }

  void _syncControllersWithViewModel(ProfileViewModel vm) {
    _emailController.text = vm.email;
    _phoneController.text = vm.phoneNumber;
    _firstNameController.text = vm.firstName;
    _lastNameController.text = vm.lastName;
    _selectedRole = vm.role.isNotEmpty && vm.availableRoles.contains(vm.role)
        ? vm.role
        : null;
  }

  /// Check if profile has unsaved changes

  /// Handle cancel with unsaved changes confirmation

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vm = context.read<ProfileViewModel>();

    final success = await vm.updateProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phoneNumber: _phoneController.text,
      email: _emailController.text,
    );

    if (!mounted) return;

    if (success) {
      // No original values to update after successful save

      AppSnackbar.showSuccess(
          context, vm.successMessage ?? 'Profile updated successfully');
    } else if (vm.errorMessage != null) {
      AppSnackbar.showError(context, vm.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, vm, _) => Scaffold(
        backgroundColor: KenwellColors.neutralBackground,
        appBar: KenwellAppBar(
          title: 'KenWell365',
          titleStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          automaticallyImplyLeading: true,
          actions: [
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () async {
                await _loadAndPopulateProfile();
                if (!context.mounted) return;
                AppSnackbar.showSuccess(context, 'Profile refreshed',
                    duration: const Duration(seconds: 1));
              },
            ),
            TextButton.icon(
              onPressed: () {
                if (mounted) {
                  context.pushNamed('help');
                }
              },
              icon: const Icon(Icons.help_outline, color: Colors.white),
              label: const Text(
                'Help',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // ── Gradient section header ─────────────────────────────
            const KenwellGradientHeader(
              //label: 'MY PROFILE',
              title: 'Edit\nProfile',
              subtitle: 'Update your personal information',
            ),

            // ── Scrollable form ─────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  AbsorbPointer(
                    absorbing: vm.isLoading,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProfileFormSection(
                              firstNameController: _firstNameController,
                              lastNameController: _lastNameController,
                              phoneController: _phoneController,
                              emailController: _emailController,
                              selectedRole: _selectedRole,
                              onRoleChanged: (value) =>
                                  setState(() => _selectedRole = value),
                            ),
                            CustomPrimaryButton(
                              label: "Save Profile",
                              onPressed: vm.isLoading ? null : _saveProfile,
                              isBusy: vm.isLoading,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (vm.isLoading)
                    const Positioned.fill(
                      child: IgnorePointer(
                        child: ColoredBox(
                          color: Color(0x66FFFFFF),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
