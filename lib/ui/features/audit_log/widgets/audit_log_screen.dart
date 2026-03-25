import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kenwell_health_app/domain/models/audit_log_entry.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/data/services/firestore_service.dart';
import 'package:intl/intl.dart';

/// A read-only screen that displays the full audit / transaction log.
///
/// Restricted to ADMIN and TOP MANAGEMENT roles (enforced via
/// [RolePermissions.routeAccess] and [RolePermissions.featureAccess]).
///
/// The log is fetched live from the `audit_logs` Firestore collection,
/// ordered by `performedAt` descending.  A filter chip row lets the user
/// narrow down by action type (all / create / update / delete).
class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  // 'all' | 'create' | 'update' | 'delete'
  String _filter = 'all';

  // ── Colours per action ──────────────────────────────────────────────────────

  Color _actionColor(String action) {
    switch (action.toLowerCase()) {
      case 'create':
        return const Color(0xFF16A34A); // green
      case 'update':
        return const Color(0xFF2563EB); // blue
      case 'delete':
        return const Color(0xFFDC2626); // red
      default:
        return KenwellColors.neutralGrey;
    }
  }

  IconData _actionIcon(String action) {
    switch (action.toLowerCase()) {
      case 'create':
        return Icons.add_circle_outline_rounded;
      case 'update':
        return Icons.edit_outlined;
      case 'delete':
        return Icons.delete_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KenwellColors.neutralBackground,
      appBar: const KenwellAppBar(
        title: 'Audit Log',
        titleStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FilterChipRow(
            selected: _filter,
            onSelected: (f) => setState(() => _filter = f),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(FirestoreService.auditLogsCollection)
                  .orderBy('performedAt', descending: true)
                  .limit(200)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Error loading audit log:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                final entries = docs
                    .map((d) => AuditLogEntry.fromFirestore(
                        d.data() as Map<String, dynamic>))
                    .where((e) =>
                        _filter == 'all' || e.action.toLowerCase() == _filter)
                    .toList();

                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_rounded,
                            size: 56,
                            color: KenwellColors.neutralGrey
                                .withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        Text(
                          _filter == 'all'
                              ? 'No audit log entries yet.'
                              : 'No "$_filter" entries found.',
                          style: TextStyle(
                            color: KenwellColors.neutralGrey
                                .withValues(alpha: 0.7),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _AuditEntryCard(entry: entries[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter chip row ──────────────────────────────────────────────────────────

class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const filters = ['all', 'create', 'update', 'delete'];
    const labels = ['All', 'Create', 'Update', 'Delete'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: List.generate(filters.length, (i) {
          final isSelected = selected == filters[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(labels[i]),
              selected: isSelected,
              onSelected: (_) => onSelected(filters[i]),
              selectedColor: KenwellColors.secondaryNavy,
              labelStyle: TextStyle(
                color:
                    isSelected ? Colors.white : KenwellColors.neutralDarkGrey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              checkmarkColor: Colors.white,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? KenwellColors.secondaryNavy
                    : KenwellColors.neutralDivider,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Individual audit entry card ──────────────────────────────────────────────

class _AuditEntryCard extends StatelessWidget {
  const _AuditEntryCard({required this.entry});
  final AuditLogEntry entry;

  Color get _color {
    switch (entry.action.toLowerCase()) {
      case 'create':
        return const Color(0xFF16A34A);
      case 'update':
        return const Color(0xFF2563EB);
      case 'delete':
        return const Color(0xFFDC2626);
      default:
        return KenwellColors.neutralGrey;
    }
  }

  IconData get _icon {
    switch (entry.action.toLowerCase()) {
      case 'create':
        return Icons.add_circle_outline_rounded;
      case 'update':
        return Icons.edit_outlined;
      case 'delete':
        return Icons.delete_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('dd MMM yyyy HH:mm').format(entry.performedAt.toLocal());

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: _color.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Action icon badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon, color: _color, size: 22),
              ),
              const SizedBox(width: 14),
              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Action chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            entry.action.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Collection
                        Expanded(
                          child: Text(
                            entry.collection,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: KenwellColors.neutralDarkGrey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (entry.summary != null && entry.summary!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        entry.summary!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: KenwellColors.neutralDarkGrey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 13,
                            color: KenwellColors.neutralGrey
                                .withValues(alpha: 0.7)),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 12,
                            color: KenwellColors.neutralGrey
                                .withValues(alpha: 0.8),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.person_outline_rounded,
                            size: 13,
                            color: KenwellColors.neutralGrey
                                .withValues(alpha: 0.7)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            entry.performedBy,
                            style: TextStyle(
                              fontSize: 12,
                              color: KenwellColors.neutralGrey
                                  .withValues(alpha: 0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Chevron
              Icon(Icons.chevron_right_rounded,
                  color: KenwellColors.neutralGrey.withValues(alpha: 0.4),
                  size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AuditDetailSheet(entry: entry),
    );
  }
}

// ── Audit detail bottom sheet ────────────────────────────────────────────────

class _AuditDetailSheet extends StatelessWidget {
  const _AuditDetailSheet({required this.entry});
  final AuditLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('dd MMM yyyy HH:mm:ss').format(entry.performedAt.toLocal());

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: KenwellColors.neutralDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  const Text(
                    'Audit Entry Detail',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: KenwellColors.neutralDarkGrey,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    color: KenwellColors.neutralGrey,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  _DetailRow(
                      label: 'Action', value: entry.action.toUpperCase()),
                  _DetailRow(label: 'Collection', value: entry.collection),
                  _DetailRow(label: 'Document ID', value: entry.documentId),
                  _DetailRow(label: 'Performed By', value: entry.performedBy),
                  _DetailRow(label: 'Performed At', value: dateStr),
                  if (entry.summary != null && entry.summary!.isNotEmpty)
                    _DetailRow(label: 'Summary', value: entry.summary!),
                  if (entry.newData != null) ...[
                    const SizedBox(height: 12),
                    const _SectionHeader(label: 'New Data'),
                    _JsonPreview(data: entry.newData!),
                  ],
                  if (entry.previousData != null) ...[
                    const SizedBox(height: 12),
                    const _SectionHeader(label: 'Previous Data'),
                    _JsonPreview(data: entry.previousData!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: KenwellColors.neutralGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: KenwellColors.neutralDarkGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: KenwellColors.secondaryNavy,
        ),
      ),
    );
  }
}

class _JsonPreview extends StatelessWidget {
  const _JsonPreview({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KenwellColors.neutralBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: KenwellColors.neutralDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries
            .where((e) =>
                e.key != 'patientSignatureData' &&
                e.key != 'hpSignatureData' &&
                e.key != 'signatureData')
            .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${e.key}: ',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: KenwellColors.secondaryNavy,
                            fontFamily: 'monospace',
                          ),
                        ),
                        TextSpan(
                          text: _formatValue(e.value),
                          style: const TextStyle(
                            fontSize: 12,
                            color: KenwellColors.neutralDarkGrey,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String && value.length > 80) {
      return '${value.substring(0, 80)}…';
    }
    return value.toString();
  }
}
