import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/logo/app_logo.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';

class MemberRegistrationScreen extends StatefulWidget {
  final VoidCallback onGoToMemberDetails;
  final VoidCallback onPrevious;

  const MemberRegistrationScreen({
    super.key,
    required this.onGoToMemberDetails,
    required this.onPrevious,
  });

  @override
  State<MemberRegistrationScreen> createState() =>
      _MemberRegistrationScreenState();
}

class _MemberRegistrationScreenState extends State<MemberRegistrationScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final searchQuery = _searchController.text.trim();
    if (searchQuery.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a search query'),
        ),
      );
      return;
    }
    // Handle search logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for: $searchQuery'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const AppLogo(size: 200),
          const SizedBox(height: 32),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Member',
              hintText: 'Enter member name or ID',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          CustomPrimaryButton(
            label: 'Search',
            onPressed: _handleSearch,
          ),
          const SizedBox(height: 24),
          CustomPrimaryButton(
            label: 'Go to Member Details',
            onPressed: widget.onGoToMemberDetails,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: widget.onPrevious,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}
