import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/logo/app_logo.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:kenwell_health_app/ui/shared/ui/dialogs/info_dialog.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';

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
      AppSnackbar.showWarning(
        context,
        'Please enter a search query',
      );
      return;
    }
    // TODO: Implement member search functionality
    // This should search for existing members by name or ID
    // and display results for selection
    AppSnackbar.showInfo(
      context,
      'Searching for: $searchQuery',
    );
  }

  void _showSearchHelp() {
    InfoDialog.show(
      context,
      title: 'Member Search Help',
      message:
          'You can search for existing members by their name or ID number. '
          'If the member is not found, you can proceed to register them as a new member.',
      icon: Icons.help_outline,
      iconColor: Colors.blue,
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
          Row(
            children: [
              Expanded(
                child: TextField(
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
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.blue),
                tooltip: 'Search Help',
                onPressed: _showSearchHelp,
              ),
            ],
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
