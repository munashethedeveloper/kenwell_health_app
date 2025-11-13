import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A reusable, theme-aware date picker form field.
///
/// Displays a read-only [TextFormField] that opens a date picker dialog.
/// Supports optional clearing, initial date, and custom display format.
class KenwellDatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateFormat displayFormat;
  final ValueChanged<DateTime?>? onDateChanged;
  final bool clearable;
  final IconData icon;
  final String? hintText;

  KenwellDatePickerField({
    Key? key,
    required this.controller,
    required this.label,
    this.initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    DateFormat? displayFormat,
    this.onDateChanged,
    this.clearable = false,
    this.icon = Icons.calendar_today,
    this.hintText,
  })  : firstDate = firstDate ?? DateTime(2000),
        lastDate = lastDate ?? DateTime(2100),
        displayFormat = displayFormat ?? DateFormat('yyyy-MM-dd'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    //final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          suffixIcon: _buildSuffixIcons(context),
          border: const OutlineInputBorder(),
        ),
        onTap: () => _handleDateTap(context),
      ),
    );
  }

  Widget _buildSuffixIcons(BuildContext context) {
    final theme = Theme.of(context);
    final showClear = clearable && controller.text.isNotEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showClear)
          IconButton(
            icon: Icon(Icons.clear, color: theme.iconTheme.color?.withValues()),
            tooltip: 'Clear date',
            onPressed: () {
              controller.clear();
              onDateChanged?.call(null);
            },
          ),
        IconButton(
          icon: Icon(icon, color: theme.iconTheme.color),
          tooltip: 'Pick date',
          onPressed: () => _handleDateTap(context),
        ),
      ],
    );
  }

  Future<void> _handleDateTap(BuildContext context) async {
    FocusScope.of(context).unfocus();

    DateTime initial =
        initialDate ?? _tryParse(controller.text) ?? DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      controller.text = displayFormat.format(pickedDate);
      onDateChanged?.call(pickedDate);
    }
  }

  DateTime? _tryParse(String text) {
    if (text.isEmpty) return null;
    try {
      return displayFormat.parseStrict(text);
    } catch (_) {
      try {
        return DateTime.parse(text);
      } catch (_) {
        return null;
      }
    }
  }
}
