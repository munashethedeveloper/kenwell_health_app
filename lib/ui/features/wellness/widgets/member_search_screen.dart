import 'package:flutter/material.dart';
import 'package:kenwell_health_app/domain/models/member.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_secondary_button.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/headers/kenwell_gradient_header.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/kenwell_form_card.dart';
import '../view_model/member_search_view_model.dart';

/// Search screen used at the start of the wellness flow.
///
/// All search logic lives in [MemberSearchViewModel]; this widget is pure UI.
///
/// ## Search flow
/// 1. User enters an SA ID number (13 digits) or passport number.
/// 2. ViewModel queries [FirestoreMemberRepository] (Firestore with local
///    Drift fallback — works offline).
/// 3. On **found**: shows a confirmation card; caller receives [onMemberFound].
/// 4. On **not found**: shows a "Register New Member" card; caller receives
///    [onGoToMemberDetails] with the search query.
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
  late final MemberSearchViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MemberSearchViewModel();
  }

  @override
  void dispose() {
    _idController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _handleSearch() async {
    final query = _idController.text.trim();
    if (query.isEmpty) {
      AppSnackbar.showWarning(context, 'Please enter an ID or Passport number');
      return;
    }

    await _viewModel.searchMember(query);

    if (!mounted) return;
    if (_viewModel.errorMessage != null) {
      AppSnackbar.showError(context, _viewModel.errorMessage!);
    } else if (_viewModel.memberFound == true) {
      AppSnackbar.showSuccess(
          context, 'Member found: ${_viewModel.foundMemberName}');
    } else if (_viewModel.memberFound == false) {
      AppSnackbar.showInfo(context, 'No member found with ID: $query');
    }
  }

  void _proceedToRegistration() {
    widget.onGoToMemberDetails(_idController.text.trim());
  }

  void _proceedWithFoundMember() {
    final member = _viewModel.foundMember;
    if (member != null) widget.onMemberFound?.call(member);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // The outer Scaffold (in WellnessNavigator) already provides the app bar.
    // Return only body content to avoid a duplicate KenWell365 app bar.
    return Column(
      children: [
        const KenwellGradientHeader(
          label: 'MEMBER',
          title: 'Member\nSearch',
          subtitle: "Enter the member's ID or Passport number to search.",
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  _SearchInputCard(
                    controller: _idController,
                    isSearching: _viewModel.isSearching,
                    onSearch: _handleSearch,
                  ),
                  const SizedBox(height: 8),
                  const Divider(
                    color: KenwellColors.primaryGreen,
                    height: 24,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  const SizedBox(height: 16),

                  // Not found card
                  if (_viewModel.memberFound == false) ...[
                    _MemberNotFoundCard(onRegister: _proceedToRegistration),
                    const SizedBox(height: 16),
                  ],

                  // Found card
                  if (_viewModel.memberFound == true &&
                      _viewModel.foundMemberName != null) ...[
                    _MemberFoundCard(
                      memberName: _viewModel.foundMemberName!,
                      onContinue: _proceedWithFoundMember,
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private section widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SearchInputCard extends StatefulWidget {
  const _SearchInputCard({
    required this.controller,
    required this.isSearching,
    required this.onSearch,
  });

  final TextEditingController controller;
  final bool isSearching;
  final VoidCallback onSearch;

  @override
  State<_SearchInputCard> createState() => _SearchInputCardState();
}

class _SearchInputCardState extends State<_SearchInputCard> {
  int _searchType = 0; // 0 = SA ID, 1 = Passport

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type toggle
          Row(
            children: [
              Icon(Icons.touch_app, size: 16, color: Colors.grey.shade600),
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
                    if (!widget.isSearching) {
                      setState(() {
                        _searchType = index;
                        widget.controller.clear();
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: Colors.white,
                  color: theme.colorScheme.primary,
                  fillColor: theme.colorScheme.primary,
                  constraints:
                      const BoxConstraints(minHeight: 42, minWidth: 100),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.badge, size: 18),
                          SizedBox(width: 6),
                          Text('SA ID Number',
                              style: TextStyle(fontWeight: FontWeight.w600)),
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
                          Text('Passport Number',
                              style: TextStyle(fontWeight: FontWeight.w600)),
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
          const SizedBox(height: 16),
          // Search field
          TextField(
            controller: widget.controller,
            enabled: !widget.isSearching,
            textCapitalization: TextCapitalization.characters,
            onSubmitted: (_) => widget.onSearch(),
            decoration: InputDecoration(
              labelText: _searchType == 0 ? 'SA ID Number' : 'Passport Number',
              hintText: _searchType == 0
                  ? 'Enter 13-digit South African ID number'
                  : 'Enter passport number',
              prefixIcon: const Icon(Icons.badge),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CustomPrimaryButton(
              label: widget.isSearching ? 'Searching...' : 'Search Member',
              onPressed: widget.isSearching ? null : widget.onSearch,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Result cards ──────────────────────────────────────────────────────────────

class _MemberNotFoundCard extends StatelessWidget {
  const _MemberNotFoundCard({required this.onRegister});
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return KenwellFormCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_off, size: 48, color: Colors.orange),
          ),
          const SizedBox(height: 16),
          Text('Member Not Found',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'No member found with this ID. You can proceed to register a new member.',
            textAlign: TextAlign.center,
            style:
                theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: CustomSecondaryButton(
                label: 'Register New Member', onPressed: onRegister),
          ),
        ],
      ),
    );
  }
}

class _MemberFoundCard extends StatelessWidget {
  const _MemberFoundCard({required this.memberName, required this.onContinue});
  final String memberName;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return KenwellFormCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KenwellColors.secondaryNavy.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle,
                size: 48, color: KenwellColors.secondaryNavy),
          ),
          const SizedBox(height: 16),
          Text('Member Found',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            memberName,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: CustomSecondaryButton(
                label: 'Continue with Member', onPressed: onContinue),
          ),
        ],
      ),
    );
  }
}
