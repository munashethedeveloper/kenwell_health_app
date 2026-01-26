import 'package:flutter/material.dart';
import '../../view_model/event_view_model.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import '../../../../shared/ui/form/kenwell_checkbox_group.dart';

class ServicesSelectionSection extends StatefulWidget {
  final EventViewModel viewModel;
  final bool
      isAdditionalServices; // true for additional, false for main services
  final bool isRequired; // Whether this section is required

  const ServicesSelectionSection({
    super.key,
    required this.viewModel,
    this.isAdditionalServices = false,
    this.isRequired = true,
  });

  @override
  State<ServicesSelectionSection> createState() =>
      _ServicesSelectionSectionState();
}

class _ServicesSelectionSectionState extends State<ServicesSelectionSection> {
  @override
  Widget build(BuildContext context) {
    final title = widget.isAdditionalServices
        ? 'Additional Services Requested'
        : 'Requested Services';

    final options = widget.isAdditionalServices
        ? widget.viewModel.availableAdditionalServiceOptions
        : widget.viewModel.availableServiceOptions;

    final selectedServices = widget.isAdditionalServices
        ? widget.viewModel.selectedAdditionalServices
        : widget.viewModel.selectedServices;

    return KenwellFormCard(
      title: title,
      margin: const EdgeInsets.only(bottom: 16),
      child: FormField<Set<String>>(
        initialValue: selectedServices,
        validator: (_) {
          // Only validate if required (main services are required, additional are optional)
          if (widget.isRequired && selectedServices.isEmpty) {
            return 'Please select at least one ${widget.isAdditionalServices ? 'additional service' : 'service'}';
          }
          return null;
        },
        builder: (field) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KenwellCheckboxGroup(
                options: options
                    .map(
                      (service) => KenwellCheckboxOption(
                        label: service,
                        value: widget.isAdditionalServices
                            ? widget.viewModel
                                .isAdditionalServiceSelected(service)
                            : widget.viewModel.isServiceSelected(service),
                        onChanged: (checked) {
                          setState(() {
                            if (widget.isAdditionalServices) {
                              widget.viewModel.toggleAdditionalServiceSelection(
                                service,
                                checked ?? false,
                              );
                            } else {
                              widget.viewModel.toggleServiceSelection(
                                service,
                                checked ?? false,
                              );
                            }
                            field.didChange(selectedServices);
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    field.errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
