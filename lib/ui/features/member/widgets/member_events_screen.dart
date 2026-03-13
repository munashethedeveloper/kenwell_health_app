import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../domain/models/member.dart';
import '../../../../data/repositories_dcl/firestore_member_repository.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/headers/kenwell_gradient_header.dart';
import '../../../shared/ui/cards/kenwell_detail_row.dart';
import '../../../shared/ui/cards/kenwell_section_card.dart';

/// Screen to display all events a member has attended
class MemberEventsScreen extends StatefulWidget {
  final Member member;

  const MemberEventsScreen({
    super.key,
    required this.member,
  });

  @override
  State<MemberEventsScreen> createState() => _MemberEventsScreenState();
}

class _MemberEventsScreenState extends State<MemberEventsScreen> {
  final FirestoreMemberRepository _repository = FirestoreMemberRepository();
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMemberEvents();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadMemberEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final events = await _repository.fetchMemberEvents(widget.member);
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load events: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Date not available';

    try {
      DateTime dateTime;
      if (date is Timestamp) {
        dateTime = date.toDate();
      } else if (date is String) {
        dateTime = DateTime.parse(date);
      } else if (date is DateTime) {
        dateTime = date;
      } else {
        return 'Invalid date';
      }

      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return 'Date format error';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const KenwellAppBar(
        title: 'KenWell365',
        automaticallyImplyLeading: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadMemberEvents,
        child: CustomScrollView(
          slivers: [
            // ── Gradient section header ─────────────────────────
            const SliverToBoxAdapter(
              child: KenwellGradientHeader(
                label: 'MEMBER',
                title: 'Member\nDetails',
                subtitle:
                    'Detailed information about the member and their event history',
              ),
            ),
            // ── Content ─────────────────────────────────────────
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KenwellSectionCard(
                      title: 'Personal Information',
                      Icons.person,
                        [
                          _buildDetailRow(
                              'Name and Surname',
                              '${widget.member.name} ${widget.member.surname}',
                              theme),
                          const Divider(height: 1),
                          _buildDetailRow(
                              'Gender', widget.member.gender ?? '', theme),
                          const Divider(height: 1),
                          _buildDetailRow(
                              'Email', widget.member.email ?? '', theme),
                          const Divider(height: 1),
                          KenwellDetailRow(label: 'Phone Number', value: widget.member.cellNumber ?? ''),
                          const Divider(height: 1),
                          KenwellDetailRow(label: 'Citizenship Status', value: widget.member.citizenshipStatus ?? ''),
                          const Divider(height: 1),
                          KenwellDetailRow(label: 'Nationality', value: widget.member.nationality ?? ''),
                          const Divider(height: 1),
                          _buildDetailRow(
                              'ID Number', widget.member.idNumber ?? '', theme),
                          const Divider(height: 1),
                          KenwellDetailRow(label: 'Passport Number', value: widget.member.passportNumber ?? ''),
                          const Divider(height: 1),
                          KenwellDetailRow(label: 'Medical Aid', value: widget.member.medicalAidName ?? ''),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Events section
                      Text(
                        'Events History  (${_events.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF201C58),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Loading, error, or events list
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_errorMessage != null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadMemberEvents,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (_events.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 64,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No Events Found',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'This member has not attended any events yet.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        // Events list
                        ..._events
                            .map((event) => _buildEventCard(event))
                            .toList(),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final theme = Theme.of(context);
    final location = (event['eventLocation'] != null &&
            event['eventLocation'].toString().isNotEmpty)
        ? event['eventLocation'] as String
        : (event['eventVenue'] != null &&
                event['eventVenue'].toString().isNotEmpty)
            ? event['eventVenue'] as String
            : null;

    final isScreened = event['isScreened'] as bool? ?? false;
    final hraCompleted = event['hraCompleted'] as bool? ?? false;
    final hctCompleted = event['hctCompleted'] as bool? ?? false;
    final tbCompleted = event['tbCompleted'] as bool? ?? false;
    final cancerCompleted = event['cancerCompleted'] as bool? ?? false;

    final completedScreenings = <String>[
      if (hraCompleted) 'HRA',
      if (hctCompleted) 'HCT',
      if (tbCompleted) 'TB',
      if (cancerCompleted) 'Cancer',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.event,
              color: theme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        event['eventTitle'] ?? 'Unknown Event',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildScreeningBadge(isScreened, theme),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(event['eventDate']),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (location != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
                if (completedScreenings.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: completedScreenings
                        .map((s) => _buildScreeningChip(s, theme))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreeningBadge(bool isScreened, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isScreened
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isScreened
              ? Colors.green.withValues(alpha: 0.4)
              : Colors.orange.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isScreened ? Icons.check_circle_outline : Icons.app_registration,
            size: 12,
            color: isScreened ? Colors.green[700] : Colors.orange[700],
          ),
          const SizedBox(width: 3),
          Text(
            isScreened ? 'Screened' : 'Registered',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isScreened ? Colors.green[700] : Colors.orange[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreeningChip(String label, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }


}
