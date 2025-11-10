import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatelessWidget {
  DatePickerField({
    super.key,
    required this.label,
    required this.controller,
    this.initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    this.dateFormat,
    this.padding = const EdgeInsets.only(bottom: 12),
    this.enabled = true,
    this.onDateSelected,
  })  : firstDate = firstDate ?? DateTime(2000),
        lastDate = lastDate ?? DateTime(2100);

  final String label;
  final TextEditingController controller;
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateFormat? dateFormat;
  final EdgeInsetsGeometry padding;
  final bool enabled;
  final ValueChanged<DateTime>? onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        readOnly: true,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onTap: enabled ? () => _selectDate(context) : null,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final now = DateTime.now();
    final initial = initialDate ??
        DateTime(
          now.year,
          now.month,
          now.day,
        );

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(firstDate) ? firstDate : initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      controller.text =
          (dateFormat ?? DateFormat('dd/MM/yyyy')).format(pickedDate);
      onDateSelected?.call(pickedDate);
    }
  }
}
