import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../view_model/profile_view_model.dart';

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(100)),
);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: const _ProfileScreenBody(),
    );
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
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _roleController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
  }

  void _syncControllersWithViewModel(ProfileViewModel vm) {
    _emailController.text = vm.email;
    _passwordController.text = vm.password;
    _confirmPasswordController.text = vm.password;
    _roleController.text = vm.role;
    _phoneController.text = vm.phoneNumber;
    _usernameController.text = vm.username;
    _firstNameController.text = vm.firstName;
    _lastNameController.text = vm.lastName;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(ProfileViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    vm
      ..firstName = _firstNameController.text.trim()
      ..lastName = _lastNameController.text.trim()
      ..username = _usernameController.text.trim()
      ..role = _roleController.text.trim()
      ..phoneNumber = _phoneController.text.trim()
      ..email = _emailController.text.trim()
      ..password = _passwordController.text.trim();

    await vm.updateProfile();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, vm, _) => Scaffold(
        backgroundColor: Colors.white,
        appBar: const KenwellAppBar(
          title: 'User Profile',
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AbsorbPointer(
                  absorbing: vm.isSavingProfile || vm.isLoadingProfile,
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          const Text(
                            "Update Profile",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Complete your details or update your information",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF757575)),
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(_firstNameController, "First Name"),
                          const SizedBox(height: 16),
                          _buildTextField(_lastNameController, "Last Name"),
                          const SizedBox(height: 16),
                          _buildTextField(_usernameController, "Username"),
                          const SizedBox(height: 16),
                          _buildTextField(_roleController, "Role"),
                          const SizedBox(height: 16),
                          _buildTextField(_phoneController, "Phone Number",
                              keyboardType: TextInputType.phone),
                          const SizedBox(height: 16),
                          _buildTextField(_emailController, "Email",
                              keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 16),
                          _buildPasswordField(
                            _passwordController,
                            "Password",
                            _obscurePassword,
                            () => setState(() {
                              _obscurePassword = !_obscurePassword;
                            }),
                          ),
                          const SizedBox(height: 16),
                          _buildPasswordField(
                            _confirmPasswordController,
                            "Confirm Password",
                            _obscureConfirmPassword,
                            () => setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            }),
                          ),
                          const SizedBox(height: 24),
                          CustomPrimaryButton(
                            label: "Save Profile",
                            onPressed: (vm.isLoadingProfile || vm.isSavingProfile)
                                ? null
                                : () => _saveProfile(vm),
                            isBusy: vm.isSavingProfile,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (vm.isLoadingProfile)
                const Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(
                      color: Color(0x66FFFFFF),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (v) => (v == null || v.isEmpty) ? "Enter $label" : null,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: "Enter $label",
        hintStyle: const TextStyle(color: Color(0xFF757575)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        border: authOutlineInputBorder,
        enabledBorder: authOutlineInputBorder,
        focusedBorder: authOutlineInputBorder.copyWith(
          borderSide: const BorderSide(color: Color(0xFFFF7643)),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label,
      bool obscureText, VoidCallback toggleObscure) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: (v) => (v == null || v.isEmpty) ? "Enter $label" : null,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: "Enter $label",
        hintStyle: const TextStyle(color: Color(0xFF757575)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        border: authOutlineInputBorder,
        enabledBorder: authOutlineInputBorder,
        focusedBorder: authOutlineInputBorder.copyWith(
          borderSide: const BorderSide(color: Color(0xFFFF7643)),
        ),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleObscure,
        ),
      ),
    );
  }
}
