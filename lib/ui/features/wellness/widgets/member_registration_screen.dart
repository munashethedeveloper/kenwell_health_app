import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/logo/app_logo.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:kenwell_health_app/domain/models/member.dart';
import 'package:kenwell_health_app/data/repositories_dcl/member_repository.dart';
import 'package:kenwell_health_app/data/local/app_database.dart';

class MemberRegistrationScreen extends StatefulWidget {
  final Function(Member member) onMemberFound;
  final VoidCallback onGoToMemberDetails;
  final VoidCallback onPrevious;

  const MemberRegistrationScreen({
    super.key,
    required this.onMemberFound,
    required this.onGoToMemberDetails,
    required this.onPrevious,
  });

  @override
  State<MemberRegistrationScreen> createState() =>
      _MemberRegistrationScreenState();
}

class _MemberRegistrationScreenState extends State<MemberRegistrationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MemberRepository _memberRepository = MemberRepository(AppDatabase.instance);
  String _searchType = 'ID'; // 'ID' or 'Passport'
  Member? _foundMember;
  bool _searched = false;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    final searchQuery = _searchController.text.trim();
    if (searchQuery.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a search query'),
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _searched = false;
      _foundMember = null;
    });

    try {
      // Search for member in database
      if (_searchType == 'ID') {
        _foundMember = await _memberRepository.getMemberByIdNumber(searchQuery);
      } else {
        _foundMember = await _memberRepository.getMemberByPassportNumber(searchQuery);
      }

      setState(() {
        _searched = true;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching: $e')),
        );
      }
    }
  }

  String get _searchFieldLabel {
    return _searchType == 'ID' ? 'RSA ID Number' : 'Passport Number';
  }

  String get _searchFieldHint {
    return _searchType == 'ID'
        ? 'Enter RSA ID number'
        : 'Enter passport number';
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
          const Text(
            'Member Registration',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF201C58),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // ID/Passport dropdown
          DropdownButtonFormField<String>(
            value: _searchType,
            decoration: InputDecoration(
              labelText: 'Identification Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: const [
              DropdownMenuItem(value: 'ID', child: Text('RSA ID Number')),
              DropdownMenuItem(value: 'Passport', child: Text('Passport Number')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _searchType = value;
                  _searchController.clear();
                  _searched = false;
                  _foundMember = null;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: _searchFieldLabel,
              hintText: _searchFieldHint,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            enabled: !_isSearching,
          ),
          const SizedBox(height: 16),
          CustomPrimaryButton(
            label: 'Search',
            onPressed: _isSearching ? null : _handleSearch,
            isBusy: _isSearching,
          ),
          const SizedBox(height: 24),
          // Show results after search
          if (_searched) ...[
            if (_foundMember != null) ...[
              // Member found - show member info and continue button
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Member Found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Name: ${_foundMember!.name} ${_foundMember!.surname}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (_foundMember!.idNumber != null)
                        Text(
                          'ID: ${_foundMember!.idNumber}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      if (_foundMember!.passportNumber != null)
                        Text(
                          'Passport: ${_foundMember!.passportNumber}',
                          style: const TextStyle(fontSize: 14),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomPrimaryButton(
                label: 'Continue to Event Details',
                onPressed: () => widget.onMemberFound(_foundMember!),
              ),
            ] else ...[
              // Member not found - show message and register button
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Member Not Found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No member found with ${_searchType == 'ID' ? 'ID number' : 'passport number'}: ${_searchController.text}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please register this member to continue.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomPrimaryButton(
                label: 'Go to Member Details',
                onPressed: widget.onGoToMemberDetails,
              ),
            ],
          ],
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
