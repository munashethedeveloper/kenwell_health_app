import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';

import '../../../../domain/models/wellness_event.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/buttons/custom_primary_button.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_date_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
import '../view_model/event_view_model.dart';

class EventScreen extends StatefulWidget {
  final EventViewModel viewModel;
  final DateTime date;
  final WellnessEvent? existingEvent;
  final void Function(WellnessEvent) onSave;

  const EventScreen({
    super.key,
    required this.viewModel,
    required this.date,
    this.existingEvent,
    required this.onSave,
  });

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _didLoadExistingEvent = false;

  @override
  void initState() {
    super.initState();
    final WellnessEvent? eventToEdit = widget.existingEvent;

    if (eventToEdit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (!_didLoadExistingEvent) {
          widget.viewModel.loadExistingEvent(eventToEdit);
          setState(() {
            _didLoadExistingEvent = true;
          });
        }
      });
    } else {
      widget.viewModel.dateController.text =
          "${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final WellnessEvent? eventToEdit = widget.existingEvent;
    final bool isEditMode = eventToEdit != null;

    return Scaffold(
      appBar: KenwellAppBar(title: isEditMode ? 'Edit Event' : 'Add Event'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KenwellSectionHeader(
                title: isEditMode ? 'Edit Event' : 'Add New Event',
                subtitle:
                    'Complete the event details or update the event information',
              ),
                _buildSectionCard('Basic Info', [
                  KenwellDateField(
                    label: 'Event Date',
                    controller: widget.viewModel.dateController,
                    dateFormat: 'yyyy-MM-dd',
                    initialDate: widget.date,
                  ),
                  KenwellTextField(
                    label: 'Event Title',
                    controller: widget.viewModel.titleController,
                    padding: EdgeInsets.zero,
                    validator: (value) => _requiredField('Event Title', value),
                  ),
                  KenwellTextField(
                    label: 'Venue',
                    controller: widget.viewModel.venueController,
                    padding: EdgeInsets.zero,
                    validator: (value) => _requiredField('Venue', value),
                  ),
                  KenwellTextField(
                    label: 'Address',
                    controller: widget.viewModel.addressController,
                    padding: EdgeInsets.zero,
                    validator: (value) => _requiredField('Address', value),
                  ),
                ]),
                _buildSectionCard('Onsite Contact', [
                  KenwellTextField(
                    label: 'Contact Person',
                    controller: widget.viewModel.onsiteContactController,
                    padding: EdgeInsets.zero,
                    inputFormatters:
                        AppTextInputFormatters.lettersOnly(allowHyphen: true),
                    validator: (value) => _requiredField('Contact Person', value),
                  ),
                  KenwellTextField(
                    label: 'Contact Number',
                    controller: widget.viewModel.onsiteNumberController,
                    padding: EdgeInsets.zero,
                    keyboardType: TextInputType.phone,
                    inputFormatters: AppTextInputFormatters.numbersOnly(),
                    validator: (value) => _requiredField('Contact Number', value),
                  ),
                  KenwellTextField(
                    label: 'Email',
                    controller: widget.viewModel.onsiteEmailController,
                    padding: EdgeInsets.zero,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => _requiredField('Email', value),
                  ),
                ]),
                _buildSectionCard('AE Contact', [
                  KenwellTextField(
                    label: 'Contact Person',
                    controller: widget.viewModel.aeContactController,
                    padding: EdgeInsets.zero,
                    inputFormatters:
                        AppTextInputFormatters.lettersOnly(allowHyphen: true),
                    validator: (value) => _requiredField('Contact Person', value),
                  ),
                  KenwellTextField(
                    label: 'Contact Number',
                    controller: widget.viewModel.aeNumberController,
                    padding: EdgeInsets.zero,
                    keyboardType: TextInputType.phone,
                    inputFormatters: AppTextInputFormatters.numbersOnly(),
                    validator: (value) => _requiredField('Contact Number', value),
                  ),
                ]),
              _buildSectionCard('Participation & Numbers', [
                _buildSpinBoxField(
                  'Expected Participation',
                  widget.viewModel.expectedParticipationController,
                ),
                _buildSpinBoxField(
                  'Passports',
                  widget.viewModel.passportsController,
                ),
                _buildSpinBoxField(
                  'Nurses',
                  widget.viewModel.nursesController,
                ),
              ]),
                _buildSectionCard('Options', [
                  KenwellDropdownField<String>(
                    label: 'Medical Aid',
                    value: _nullableValue(widget.viewModel.medicalAid),
                    items: const ['Yes', 'No'],
                    onChanged: (val) => widget.viewModel.medicalAid = val ?? '',
                    padding: EdgeInsets.zero,
                    validator: (val) => _requiredSelection('Medical Aid', val),
                  ),
                  KenwellDropdownField<String>(
                    label: 'Non-Members',
                    value: _nullableValue(widget.viewModel.nonMembers),
                    items: const ['Yes', 'No'],
                    onChanged: (val) => widget.viewModel.nonMembers = val ?? '',
                    padding: EdgeInsets.zero,
                    validator: (val) => _requiredSelection('Non-Members', val),
                  ),
                  KenwellDropdownField<String>(
                    label: 'Coordinators',
                    value: _nullableValue(widget.viewModel.coordinators),
                    items: const ['Yes', 'No'],
                    onChanged: (val) => widget.viewModel.coordinators = val ?? '',
                    padding: EdgeInsets.zero,
                    validator: (val) => _requiredSelection('Coordinators', val),
                  ),
                  KenwellDropdownField<String>(
                    label: 'Multiply Promoters',
                    value: _nullableValue(widget.viewModel.multiplyPromoters),
                    items: const ['Yes', 'No'],
                    onChanged: (val) =>
                        widget.viewModel.multiplyPromoters = val ?? '',
                    padding: EdgeInsets.zero,
                    validator: (val) =>
                        _requiredSelection('Multiply Promoters', val),
                  ),
                  KenwellDropdownField<String>(
                    label: 'Mobile Booths',
                    value: _nullableValue(widget.viewModel.mobileBooths),
                    items: const ['Yes', 'No'],
                    onChanged: (val) => widget.viewModel.mobileBooths = val ?? '',
                    padding: EdgeInsets.zero,
                    validator: (val) => _requiredSelection('Mobile Booths', val),
                  ),
                  KenwellDropdownField<String>(
                    label: 'Services Requested',
                    value: _nullableValue(widget.viewModel.servicesRequested),
                    items: const ['HRA', 'Other'],
                    onChanged: (val) =>
                        widget.viewModel.servicesRequested = val ?? '',
                    padding: EdgeInsets.zero,
                    validator: (val) =>
                        _requiredSelection('Services Requested', val),
                  ),
                ]),
                _buildSectionCard('Time Details', [
                  KenwellTextField(
                    label: 'Setup Time',
                    controller: widget.viewModel.setUpTimeController,
                    padding: EdgeInsets.zero,
                    readOnly: true,
                    suffixIcon: const Icon(Icons.access_time),
                    validator: (value) => _requiredField('Setup Time', value),
                    onTap: () => widget.viewModel
                        .pickTime(context, widget.viewModel.setUpTimeController),
                  ),
                  KenwellTextField(
                    label: 'Start Time',
                    controller: widget.viewModel.startTimeController,
                    padding: EdgeInsets.zero,
                    readOnly: true,
                    suffixIcon: const Icon(Icons.access_time),
                    validator: (value) => _requiredField('Start Time', value),
                    onTap: () => widget.viewModel
                        .pickTime(context, widget.viewModel.startTimeController),
                  ),
                  KenwellTextField(
                    label: 'End Time',
                    controller: widget.viewModel.endTimeController,
                    padding: EdgeInsets.zero,
                    readOnly: true,
                    suffixIcon: const Icon(Icons.access_time),
                    validator: (value) => _requiredField('End Time', value),
                    onTap: () => widget.viewModel
                        .pickTime(context, widget.viewModel.endTimeController),
                  ),
                  KenwellTextField(
                    label: 'Strike Down Time',
                    controller: widget.viewModel.strikeDownTimeController,
                    padding: EdgeInsets.zero,
                    readOnly: true,
                    suffixIcon: const Icon(Icons.access_time),
                    validator: (value) =>
                        _requiredField('Strike Down Time', value),
                    onTap: () => widget.viewModel.pickTime(
                        context, widget.viewModel.strikeDownTimeController),
                  ),
                ]),
                const SizedBox(height: 20),
                CustomPrimaryButton(
                  label: 'Save Event',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final eventDate = DateTime.tryParse(
                              widget.viewModel.dateController.text) ??
                          widget.date;
                      WellnessEvent eventToSave;
                      if (isEditMode) {
                        eventToSave = widget.viewModel
                            .buildEvent(eventDate)
                            .copyWith(id: eventToEdit.id);
                      } else {
                        eventToSave = widget.viewModel.buildEvent(eventDate);
                      }
                      widget.onSave(eventToSave);
                      widget.viewModel.clearControllers();
                      Navigator.pop(context);
                    }
                  },
                ),
                const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpinBoxField(String label, TextEditingController controller) {
    final initialValue =
        double.tryParse(controller.text.isEmpty ? '0' : controller.text) ?? 0;

    return SpinBox(
      min: 0,
      max: 100000,
      value: initialValue,
      step: 1,
      decimals: 0,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: false, signed: false),
      decoration:
          KenwellFormStyles.decoration(label: label, hint: 'Enter $label'),
      validator: (value) => value == null ? 'Enter $label' : null,
      onChanged: (value) {
        controller.text = value.round().toString();
      },
    );
  }
}

Widget _buildSectionCard(String title, List<Widget> children) {
  return KenwellFormCard(
    title: title,
    margin: const EdgeInsets.only(bottom: 16),
    child: Column(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i != children.length - 1) KenwellFormStyles.fieldSpacing,
        ],
      ],
    ),
  );
}

String? _nullableValue(String value) => value.isEmpty ? null : value;

String? _requiredField(String label, String? value) =>
    (value == null || value.isEmpty) ? 'Enter $label' : null;

String? _requiredSelection(String label, String? value) =>
    (value == null || value.isEmpty) ? 'Select $label' : null;
