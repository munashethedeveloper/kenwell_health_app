import 'package:flutter/material.dart';
import '../../../../../domain/models/wellness_event.dart';

/// Displays the event-stats filter bottom-sheet modal.
///
/// The caller owns the filter state and passes callbacks so the sheet can
/// update it via [setState] from the parent.
class StatsFilterSheet extends StatefulWidget {
  const StatsFilterSheet({
    super.key,
    required this.allEvents,
    required this.selectedStatus,
    required this.selectedProvince,
    required this.startDate,
    required this.endDate,
    required this.onStatusChanged,
    required this.onProvinceChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onClearAll,
  });

  final List<WellnessEvent> allEvents;
  final String? selectedStatus;
  final String? selectedProvince;
  final DateTime? startDate;
  final DateTime? endDate;

  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onProvinceChanged;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;
  final VoidCallback onClearAll;

  // ── Convenience launcher ──────────────────────────────────────────────────
  static void show({
    required BuildContext context,
    required List<WellnessEvent> allEvents,
    required String? selectedStatus,
    required String? selectedProvince,
    required DateTime? startDate,
    required DateTime? endDate,
    required ValueChanged<String?> onStatusChanged,
    required ValueChanged<String?> onProvinceChanged,
    required ValueChanged<DateTime?> onStartDateChanged,
    required ValueChanged<DateTime?> onEndDateChanged,
    required VoidCallback onClearAll,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatsFilterSheet(
        allEvents: allEvents,
        selectedStatus: selectedStatus,
        selectedProvince: selectedProvince,
        startDate: startDate,
        endDate: endDate,
        onStatusChanged: onStatusChanged,
        onProvinceChanged: onProvinceChanged,
        onStartDateChanged: onStartDateChanged,
        onEndDateChanged: onEndDateChanged,
        onClearAll: onClearAll,
      ),
    );
  }

  @override
  State<StatsFilterSheet> createState() => _StatsFilterSheetState();
}

class _StatsFilterSheetState extends State<StatsFilterSheet> {
  late String? _status;
  late String? _province;
  late DateTime? _startDate;
  late DateTime? _endDate;

  bool get _hasFilters =>
      _status != null ||
      _province != null ||
      _startDate != null ||
      _endDate != null;

  @override
  void initState() {
    super.initState();
    _status = widget.selectedStatus;
    _province = widget.selectedProvince;
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  void _clearAll() {
    setState(() {
      _status = null;
      _province = null;
      _startDate = null;
      _endDate = null;
    });
    widget.onStatusChanged(null);
    widget.onProvinceChanged(null);
    widget.onStartDateChanged(null);
    widget.onEndDateChanged(null);
    widget.onClearAll();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Always list all 9 South African provinces; highlight those that appear
    // in the current event data with a count badge.
    const allProvinces = [
      'Eastern Cape',
      'Free State',
      'Gauteng',
      'KwaZulu-Natal',
      'Limpopo',
      'Mpumalanga',
      'Northern Cape',
      'North West',
      'Western Cape',
    ];
    final eventProvinces = widget.allEvents
        .map((e) => e.province)
        .where((p) => p.isNotEmpty)
        .toSet();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 32),
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Drag handle ───────────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Title row ─────────────────────────────────────────────────
          Row(
            children: [
              Text(
                'Filters',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_hasFilters)
                TextButton(
                  onPressed: _clearAll,
                  child: const Text('Clear all'),
                ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),

          // ── Status chips ──────────────────────────────────────────────
          Text(
            'Status',
            style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Scheduled', 'In Progress', 'Completed'].map((s) {
              final selected = _status == s;
              return FilterChip(
                label: Text(s),
                selected: selected,
                onSelected: (on) {
                  setState(() => _status = on ? s : null);
                  widget.onStatusChanged(on ? s : null);
                },
                backgroundColor: Colors.white,
                selectedColor: theme.primaryColor.withValues(alpha: 0.2),
                checkmarkColor: theme.primaryColor,
                labelStyle: TextStyle(
                  color: selected ? theme.primaryColor : Colors.grey[700],
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: selected ? theme.primaryColor : Colors.grey.shade300,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // ── Province chips ────────────────────────────────────────────
          Text(
            'Province',
            style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allProvinces.map((p) {
              final selected = _province == p;
              final hasData = eventProvinces.contains(p);
              return FilterChip(
                label: Text(p),
                selected: selected,
                onSelected: (on) {
                  setState(() => _province = on ? p : null);
                  widget.onProvinceChanged(on ? p : null);
                },
                backgroundColor:
                    hasData ? Colors.white : Colors.grey.shade50,
                selectedColor: theme.primaryColor.withValues(alpha: 0.2),
                checkmarkColor: theme.primaryColor,
                labelStyle: TextStyle(
                  color: selected
                      ? theme.primaryColor
                      : (hasData
                          ? Colors.grey[700]
                          : Colors.grey[400]),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: selected
                      ? theme.primaryColor
                      : (hasData
                          ? Colors.grey.shade300
                          : Colors.grey.shade200),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // ── Date range ────────────────────────────────────────────────
          Text(
            'Date Range',
            style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: _startDate == null
                      ? 'Start Date'
                      : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                  isSet: _startDate != null,
                  theme: theme,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => _startDate = picked);
                      widget.onStartDateChanged(picked);
                    }
                  },
                  onClear: _startDate != null
                      ? () {
                          setState(() => _startDate = null);
                          widget.onStartDateChanged(null);
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DateButton(
                  label: _endDate == null
                      ? 'End Date'
                      : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                  isSet: _endDate != null,
                  theme: theme,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => _endDate = picked);
                      widget.onEndDateChanged(picked);
                    }
                  },
                  onClear: _endDate != null
                      ? () {
                          setState(() => _endDate = null);
                          widget.onEndDateChanged(null);
                        }
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Apply button ──────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

// ── Private helper widget ─────────────────────────────────────────────────────

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.isSet,
    required this.theme,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final bool isSet;
  final ThemeData theme;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSet ? theme.primaryColor : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: isSet ? theme.primaryColor : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSet ? theme.primaryColor : Colors.grey[600],
                    fontWeight: isSet ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (onClear != null)
                GestureDetector(
                  onTap: onClear,
                  child: Icon(Icons.close, size: 16, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
