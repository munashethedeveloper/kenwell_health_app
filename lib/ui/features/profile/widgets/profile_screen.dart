import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/profile_view_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: Consumer<ProfileViewModel>(
        builder: (context, vm, _) => Scaffold(
          appBar: AppBar(
            title: const Text(
              'Profile',
              style: TextStyle(
                color: Color(0xFF201C58),
                fontWeight: FontWeight.bold,
              ),
            ),
            automaticallyImplyLeading: true,
            centerTitle: true,
            backgroundColor: const Color(0xFF90C048),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: vm.firstName,
                    decoration: const InputDecoration(labelText: 'First Name'),
                    onChanged: (val) => vm.firstName = val,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: vm.lastName,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    onChanged: (val) => vm.lastName = val,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: vm.username,
                    decoration: const InputDecoration(labelText: 'Username'),
                    onChanged: (val) => vm.username = val,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: vm.role,
                    decoration: const InputDecoration(labelText: 'Role'),
                    onChanged: (val) => vm.role = val,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: vm.phoneNumber,
                    decoration:
                        const InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                    onChanged: (val) => vm.phoneNumber = val,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: vm.email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (val) => vm.email = val,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    onChanged: (val) => vm.password = val,
                  ),
                  const SizedBox(height: 30),
                  vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: vm.updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF201C58),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: const Text('Save Profile'),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
