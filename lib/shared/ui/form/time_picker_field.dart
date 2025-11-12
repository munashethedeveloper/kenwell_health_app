import 'package:flutter/material.dart';

class TimePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TimeOfDay? initialTime;
  final ValueChanged<TimeOfDay?>? onTimeChanged;
  final bool clearable;

  const TimePickerField({
    Key? key,
    required this.controller,
    required this.label,
    this.initialTime,
    this.onTimeChanged,
    this.clearable = false,
  }) : super(key: key);

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
                    if (onTimeChanged != null) onTimeChanged!(null);
                  },
                ),
              const Icon(Icons.access_time),
            ],
          ),
          border: const OutlineInputBorder(),
        ),
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode());
          final initial = initialTime ?? TimeOfDay.now();
          final picked = await showTimePicker(
            context: context,
            initialTime: initial,
          );
          if (picked != null) {
            controller.text = picked.format(context);
            if (onTimeChanged != null) onTimeChanged!(picked);
          }
        },
      ),
    );
  }
}