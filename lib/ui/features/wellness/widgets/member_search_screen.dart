import 'package:flutter/material.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_member_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/member_repository.dart';
import 'package:kenwell_health_app/data/local/app_database.dart';
import 'package:kenwell_health_app/domain/models/member.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_secondary_button.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/kenwell_form_card.dart';
import 'package:kenwell_health_app/ui/shared/ui/logo/app_logo.dart';

import '../../../shared/ui/form/kenwell_modern_section_header.dart';
// ...existing code...

class MemberSearchScreen extends StatefulWidget {
  final Function(String searchQuery) onGoToMemberDetails;
  final Function(Member member)? onMemberFound;
  final VoidCallback? onPrevious;

  const MemberSearchScreen({
    super.key,
    required this.onGoToMemberDetails,
    this.onMemberFound,
    this.onPrevious,
  });

  @override
  State<MemberSearchScreen> createState() => _MemberSearchScreenState();
}

class _MemberSearchScreenState extends State<MemberSearchScreen> {
  final TextEditingController _idController = TextEditingController();
  final FirestoreMemberRepository _firestoreMemberRepository =
      FirestoreMemberRepository();
  final MemberRepository _memberRepository =
      MemberRepository(AppDatabase.instance);
  bool _isSearching = false;
  bool? _memberFound;
  String? _memberName;
  Member? _foundMember;
  int _searchType = 0; // 0 = ID Number, 1 = Passport

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    final searchQuery = _idController.text.trim();
    if (searchQuery.isEmpty) {
      AppSnackbar.showWarning(
        context,
        'Please enter an ID or Passport number',
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _memberFound = null;
      _memberName = null;
      _foundMember = null;
    });

    try {
      Member? member;

      // Try to search by ID number first (if it looks like an SA ID number)
      if (searchQuery.length == 13 && int.tryParse(searchQuery) != null) {
        // Try Firestore first, fallback to local if permission denied
        try {
          member = await _firestoreMemberRepository
              .fetchMemberByIdNumber(searchQuery);
        } catch (firestoreError) {
          debugPrint(
              'Firestore search failed, using local database: $firestoreError');
          // Fallback to local database
          member = await _memberRepository.getMemberByIdNumber(searchQuery);
        }
      } else {
        // Search by passport number
        // Try Firestore first, fallback to local if permission denied
        try {
          member = await _firestoreMemberRepository
              .fetchMemberByPassportNumber(searchQuery);
        } catch (firestoreError) {
          debugPrint(
              'Firestore search failed, using local database: $firestoreError');
          // Fallback to local database
          member =
              await _memberRepository.getMemberByPassportNumber(searchQuery);
        }
      }

      if (mounted) {
        setState(() {
          _isSearching = false;
          _memberFound = member != null;
          _foundMember = member;
          if (member != null) {
            _memberName = '${member.name} ${member.surname}';
          }
        });

        if (member != null) {
          AppSnackbar.showSuccess(
            context,
            'Member found: ${member.name} ${member.surname}',
          );
        } else {
          AppSnackbar.showInfo(
            context,
            'No member found with ID: $searchQuery',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _memberFound = false;
        });

        AppSnackbar.showError(
          context,
          'Error searching for member: $e',
        );
      }
    }
  }

  void _proceedToRegistration() {
    widget.onGoToMemberDetails(_idController.text.trim());
  }

  void _proceedWithFoundMember() {
    if (_foundMember != null && widget.onMemberFound != null) {
      widget.onMemberFound!(_foundMember!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const AppLogo(size: 200),
            const SizedBox(height: 24),
            const KenwellModernSectionHeader(
              title: 'Search Member',
              subtitle:
                  'Find an existing member by their ID or Passport number',
              icon: Icons.person_search,
            ),
            const SizedBox(height: 24),

            // Search section with background
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Search type label and toggle buttons
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Select Search Type:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ToggleButtons(
                              isSelected: [_searchType == 0, _searchType == 1],
                              onPressed: (index) {
                                if (mounted && !_isSearching) {
                                  setState(() {
                                    _searchType = index;
                                    _idController.clear();
                                    _memberFound = null;
                                    _foundMember = null;
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              selectedColor: Colors.white,
                              color: theme.colorScheme.primary,
                              fillColor: theme.colorScheme.primary,
                              constraints: const BoxConstraints(
                                minHeight: 42,
                                minWidth: 100,
                              ),
                              children: const [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.badge, size: 18),
                                      SizedBox(width: 6),
                                      Text(
                                        'SA ID Number',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.credit_card, size: 18),
                                      SizedBox(width: 6),
                                      Text(
                                        'Passport Number',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to switch between ID or Passport search',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _idController,
                    decoration: InputDecoration(
                      labelText:
                          _searchType == 0 ? 'SA ID Number' : 'Passport Number',
                      hintText: _searchType == 0
                          ? 'Enter 13-digit South African ID number'
                          : 'Enter passport number',
                      prefixIcon: const Icon(Icons.badge),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabled: !_isSearching,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onSubmitted: (_) => _handleSearch(),
                  ),
                  const SizedBox(height: 12),

                  // Search Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomPrimaryButton(
                      label: _isSearching ? 'Searching...' : 'Search Member',
                      onPressed: _isSearching ? null : _handleSearch,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Member Not Found Card
            if (_memberFound == false) ...[
              KenwellFormCard(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_off,
                        size: 48,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Member Not Found',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No member found with this ID. You can proceed to register a new member.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: CustomSecondaryButton(
                        label: 'Register New Member',
                        onPressed: _proceedToRegistration,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Member Found Card (for future use)
            if (_memberFound == true && _memberName != null) ...[
              KenwellFormCard(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 48,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Member Found',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _memberName!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: CustomSecondaryButton(
                        label: 'Continue with Member',
                        onPressed: _proceedWithFoundMember,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
