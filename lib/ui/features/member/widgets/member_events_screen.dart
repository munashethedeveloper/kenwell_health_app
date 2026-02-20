import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../domain/models/member.dart';
import '../../../../data/repositories_dcl/firestore_member_repository.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/logo/app_logo.dart';
import '../../../shared/ui/form/kenwell_modern_section_header.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/custom_text_field.dart';

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

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _genderController;
  late final TextEditingController _medicalAidController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: '${widget.member.name} ${widget.member.surname}',
    );
    _emailController = TextEditingController(
      text: widget.member.email ?? '',
    );
    _genderController = TextEditingController(
      text: widget.member.gender ?? '',
    );
    _medicalAidController = TextEditingController(
      text: widget.member.medicalAidName ?? '',
    );
    _loadMemberEvents();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _genderController.dispose();
    _medicalAidController.dispose();
    super.dispose();
  }

  Future<void> _loadMemberEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final events = await _repository.fetchMemberEvents(widget.member.id);
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
        title: 'Events Attended',
        titleColor: Colors.white,
        titleStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        automaticallyImplyLeading: true,
        backgroundColor: Color(0xFF201C58),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadMemberEvents,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            const AppLogo(size: 150),
            const SizedBox(height: 24),

            // Member information
            KenwellFormCard(
              title: 'Personal Information',
              child: Column(
                children: [
                  KenwellTextField(
                    label: 'Name and Surname',
                    controller: _nameController,
                    readOnly: true,
                  ),
                  KenwellTextField(
                    label: 'Email',
                    controller: _emailController,
                    readOnly: true,
                  ),
                  KenwellTextField(
                    label: 'Gender',
                    controller: _genderController,
                    readOnly: true,
                  ),
                  KenwellTextField(
                    label: 'Medical Aid',
                    controller: _medicalAidController,
                    readOnly: true,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Events section
            KenwellModernSectionHeader(
              title: 'Events History',
              subtitle: _isLoading
                  ? 'Loading events...'
                  : '${_events.length} event${_events.length == 1 ? '' : 's'} attended',
              icon: Icons.history,
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
              ..._events.map((event) => _buildEventCard(event)).toList(),
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
                Text(
                  event['eventTitle'] ?? 'Unknown Event',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                  const SizedBox(height: 6),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
