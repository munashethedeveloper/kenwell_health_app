import 'package:flutter/material.dart';

/// Filter chips widget for members
class MemberFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const MemberFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Male', 'Female'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filters.map((filter) {
        final isSelected = selectedFilter == filter;
        return FilterChip(
          label: Text(
            filter,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF201C58),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              onFilterChanged(filter);
            }
          },
          backgroundColor: Colors.white,
          selectedColor: const Color(0xFF201C58),
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color:
                  isSelected ? const Color(0xFF201C58) : Colors.grey.shade400,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      }).toList(),
    );
  }
}
