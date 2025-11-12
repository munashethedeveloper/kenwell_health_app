import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateFormat displayFormat;
  final ValueChanged<DateTime?>? onDateChanged;
  final bool clearable;

  const DatePickerField({
    Key? key,
    required this.controller,
    required this.label,
    this.initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    DateFormat? displayFormat,
    this.onDateChanged,
    this.clearable = false,
  })  : firstDate = firstDate ?? const DateTime(2000),
        lastDate = lastDate ?? const DateTime(2100),
        displayFormat = displayFormat ?? const DateFormat('yyyy-MM-dd'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (clearable && controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    if (onDateChanged != null) onDateChanged!(null);
                  },
                ),
              const Icon(Icons.calendar_today),
            ],
          ),
          border: const OutlineInputBorder(),
        ),
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode());
          final initial = controller.text.isNotEmpty
              ? _tryParse(controller.text)
              : (initialDate ?? DateTime.now());
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: initial ?? DateTime.now(),
            firstDate: firstDate,
            lastDate: lastDate,
          );
          if (pickedDate != null) {
            controller.text = displayFormat.format(pickedDate);
            if (onDateChanged != null) onDateChanged!(pickedDate);
          }
        },
      ),
    );
  }

  DateTime? _tryParse(String text) {
    try {
      return displayFormat.parse(text);
    } catch (_) {
      // fallback to ISO parse
      try {
        return DateTime.parse(text);
      } catch (_) {
        return null;
      }
    }
  }
}