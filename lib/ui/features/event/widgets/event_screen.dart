import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';

import '../../../../domain/models/wellness_event.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
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
                _buildTextField(
                  controller: widget.viewModel.titleController,
                  label: 'Event Title',
                ),
                _buildTextField(
                  controller: widget.viewModel.venueController,
                  label: 'Venue',
                ),
                _buildTextField(
                  controller: widget.viewModel.addressController,
                  label: 'Address',
                ),
              ]),
              _buildSectionCard('Onsite Contact', [
                _buildTextField(
                  controller: widget.viewModel.onsiteContactController,
                  label: 'Contact Person',
                  inputFormatters:
                      AppTextInputFormatters.lettersOnly(allowHyphen: true),
                ),
                _buildTextField(
                  controller: widget.viewModel.onsiteNumberController,
                  label: 'Contact Number',
                  keyboardType: TextInputType.phone,
                  inputFormatters: AppTextInputFormatters.numbersOnly(),
                ),
                _buildTextField(
                  controller: widget.viewModel.onsiteEmailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
              ]),
              _buildSectionCard('AE Contact', [
                _buildTextField(
                  controller: widget.viewModel.aeContactController,
                  label: 'Contact Person',
                  inputFormatters:
                      AppTextInputFormatters.lettersOnly(allowHyphen: true),
                ),
                _buildTextField(
                  controller: widget.viewModel.aeNumberController,
                  label: 'Contact Number',
                  keyboardType: TextInputType.phone,
                  inputFormatters: AppTextInputFormatters.numbersOnly(),
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
                _buildDropdownField(
                  label: 'Medical Aid',
                  value: _nullableValue(widget.viewModel.medicalAid),
                  options: const ['Yes', 'No'],
                  onChanged: (val) => widget.viewModel.medicalAid = val ?? '',
                ),
                _buildDropdownField(
                  label: 'Non-Members',
                  value: _nullableValue(widget.viewModel.nonMembers),
                  options: const ['Yes', 'No'],
                  onChanged: (val) => widget.viewModel.nonMembers = val ?? '',
                ),
                _buildDropdownField(
                  label: 'Coordinators',
                  value: _nullableValue(widget.viewModel.coordinators),
                  options: const ['Yes', 'No'],
                  onChanged: (val) => widget.viewModel.coordinators = val ?? '',
                ),
                _buildDropdownField(
                  label: 'Multiply Promoters',
                  value: _nullableValue(widget.viewModel.multiplyPromoters),
                  options: const ['Yes', 'No'],
                  onChanged: (val) =>
                      widget.viewModel.multiplyPromoters = val ?? '',
                ),
                _buildDropdownField(
                  label: 'Mobile Booths',
                  value: _nullableValue(widget.viewModel.mobileBooths),
                  options: const ['Yes', 'No'],
                  onChanged: (val) => widget.viewModel.mobileBooths = val ?? '',
                ),
                _buildDropdownField(
                  label: 'Services Requested',
                  value: _nullableValue(widget.viewModel.servicesRequested),
                  options: const ['HRA', 'Other'],
                  onChanged: (val) =>
                      widget.viewModel.servicesRequested = val ?? '',
                ),
              ]),
              _buildSectionCard('Time Details', [
                _buildTimeField(
                  label: 'Setup Time',
                  controller: widget.viewModel.setUpTimeController,
                  onPickTime: () => widget.viewModel
                      .pickTime(context, widget.viewModel.setUpTimeController),
                ),
                _buildTimeField(
                  label: 'Start Time',
                  controller: widget.viewModel.startTimeController,
                  onPickTime: () => widget.viewModel
                      .pickTime(context, widget.viewModel.startTimeController),
                ),
                _buildTimeField(
                  label: 'End Time',
                  controller: widget.viewModel.endTimeController,
                  onPickTime: () => widget.viewModel
                      .pickTime(context, widget.viewModel.endTimeController),
                ),
                _buildTimeField(
                  label: 'Strike Down Time',
                  controller: widget.viewModel.strikeDownTimeController,
                  onPickTime: () => widget.viewModel.pickTime(
                      context, widget.viewModel.strikeDownTimeController),
                ),
              ]),
              const SizedBox(height: 20),
              ElevatedButton(
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF201C58),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Event',
                    style: TextStyle(fontWeight: FontWeight.bold)),
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

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  String? hint,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
}) {
  return KenwellTextField(
    label: label,
    controller: controller,
    hintText: hint ?? 'Enter $label',
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    padding: EdgeInsets.zero,
    decoration: KenwellFormStyles.decoration(
        label: label, hint: hint ?? 'Enter $label'),
    validator: (val) => (val == null || val.isEmpty) ? 'Enter $label' : null,
  );
}

Widget _buildTimeField({
  required String label,
  required TextEditingController controller,
  required Future<void> Function() onPickTime,
}) {
  return KenwellTextField(
    label: label,
    controller: controller,
    readOnly: true,
    padding: EdgeInsets.zero,
    decoration: KenwellFormStyles.decoration(
      label: label,
      hint: 'Select $label',
      suffixIcon: const Icon(Icons.access_time),
    ),
    onTap: onPickTime,
    validator: (val) => (val == null || val.isEmpty) ? 'Select $label' : null,
  );
}

Widget _buildDropdownField({
  required String label,
  required String? value,
  required List<String> options,
  required ValueChanged<String?> onChanged,
}) {
  return KenwellDropdownField<String>(
    label: label,
    value: value,
    items: options,
    onChanged: onChanged,
    padding: EdgeInsets.zero,
    decoration:
        KenwellFormStyles.decoration(label: label, hint: 'Select $label'),
    validator: (val) => (val == null || val.isEmpty) ? 'Select $label' : null,
  );
}

String? _nullableValue(String value) => value.isEmpty ? null : value;
