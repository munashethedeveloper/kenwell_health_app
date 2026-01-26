import 'package:flutter/material.dart';
import '../../view_model/event_view_model.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import 'yes_no_count_widget.dart';

class EventOptionsSection extends StatefulWidget {
  final EventViewModel viewModel;
  final String? Function(String?, String?) requiredSelection;

  const EventOptionsSection({
    super.key,
    required this.viewModel,
    required this.requiredSelection,
  });

  @override
  State<EventOptionsSection> createState() => _EventOptionsSectionState();
}

class _EventOptionsSectionState extends State<EventOptionsSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Coordinators
        KenwellFormCard(
          title: 'Coordinators Option',
          margin: const EdgeInsets.only(bottom: 16),
          child: YesNoCountWidget(
            label: 'Do You Need Coordinators?',
            itemType: 'Coordinators',
            selectedOption: _nullableValue(widget.viewModel.coordinatorsOption),
            count: widget.viewModel.coordinatorsCount,
            onOptionChanged: (val) {
              setState(() {
                widget.viewModel.coordinatorsOption = val ?? 'No';
                if (val == 'No') widget.viewModel.coordinatorsCount = 0;
              });
            },
            onCountChanged: (count) {
              setState(() => widget.viewModel.coordinatorsCount = count);
            },
            validator: (val) => widget.requiredSelection('Coordinators', val),
            maxCount: 10,
          ),
        ),

        // Mobile Booths
        KenwellFormCard(
          title: 'Mobile Booths Option',
          margin: const EdgeInsets.only(bottom: 16),
          child: YesNoCountWidget(
            label: 'Do You Need Mobile Booths?',
            itemType: 'Mobile Booths',
            selectedOption: _nullableValue(widget.viewModel.mobileBoothsOption),
            count: widget.viewModel.mobileBoothsCount,
            onOptionChanged: (val) {
              setState(() {
                widget.viewModel.mobileBoothsOption = val ?? 'No';
                if (val == 'No') widget.viewModel.mobileBoothsCount = 0;
              });
            },
            onCountChanged: (count) {
              setState(() => widget.viewModel.mobileBoothsCount = count);
            },
            validator: (val) => widget.requiredSelection('Mobile Booths', val),
            maxCount: 20,
          ),
        ),
      ],
    );
  }

  String? _nullableValue(String value) => value.isEmpty ? null : value;
}
