import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../view_model/profile_view_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: Consumer<ProfileViewModel>(
        builder: (context, vm, _) => Scaffold(
          appBar: const KenwellAppBar(
              title: 'User Profile', automaticallyImplyLeading: false),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildCardField(
                    child: TextFormField(
                      initialValue: vm.firstName,
                      decoration:
                          const InputDecoration(labelText: 'First Name'),
                      onChanged: (val) => vm.firstName = val,
                    ),
                  ),
                  _buildCardField(
                    child: TextFormField(
                      initialValue: vm.lastName,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                      onChanged: (val) => vm.lastName = val,
                    ),
                  ),
                  _buildCardField(
                    child: TextFormField(
                      initialValue: vm.username,
                      decoration: const InputDecoration(labelText: 'Username'),
                      onChanged: (val) => vm.username = val,
                    ),
                  ),
                  _buildCardField(
                    child: TextFormField(
                      initialValue: vm.role,
                      decoration: const InputDecoration(labelText: 'Role'),
                      onChanged: (val) => vm.role = val,
                    ),
                  ),
                  _buildCardField(
                    child: TextFormField(
                      initialValue: vm.phoneNumber,
                      decoration:
                          const InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                      onChanged: (val) => vm.phoneNumber = val,
                    ),
                  ),
                  _buildCardField(
                    child: TextFormField(
                      initialValue: vm.email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (val) => vm.email = val,
                    ),
                  ),
                  _buildCardField(
                    child: TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                      onChanged: (val) => vm.password = val,
                    ),
                  ),
                  const SizedBox(height: 30),
                  vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: vm.updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF201C58),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text(
                              'Save Profile',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardField({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: child,
        ),
      ),
    );
  }
}
