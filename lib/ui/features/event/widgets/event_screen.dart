import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';
import 'package:kenwell_health_app/utils/validators.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/buttons/custom_primary_button.dart';
import '../../../shared/ui/colours/kenwell_colours.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_checkbox_group.dart';
import '../../../shared/ui/form/kenwell_date_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
import '../view_model/event_view_model.dart';

class EventScreen extends StatefulWidget {
  final EventViewModel viewModel;
  final DateTime date;
  final WellnessEvent? existingEvent;
  final Future<void> Function(WellnessEvent) onSave;

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

  Future<void> _validateAndSave() async {
    final invalidFields = <String>[];

    // Basic Info
    if (_requiredField('Event Title', widget.viewModel.titleController.text) !=
        null) invalidFields.add('Event Title');
    if (_requiredField('Venue', widget.viewModel.venueController.text) != null)
      invalidFields.add('Venue');
    if (_requiredField('Address', widget.viewModel.addressController.text) !=
        null) invalidFields.add('Address');

    // Onsite Contact
    if (_requiredField('Contact Person First Name',
            widget.viewModel.onsiteContactFirstNameController.text) !=
        null) invalidFields.add('Onsite Contact First Name');
    if (_requiredField('Contact Person Last Name',
            widget.viewModel.onsiteContactLastNameController.text) !=
        null) invalidFields.add('Onsite Contact Last Name');
    if (Validators.validateSouthAfricanPhoneNumber(
            widget.viewModel.onsiteNumberController.text) !=
        null) invalidFields.add('Onsite Contact Number');
    if (Validators.validateEmail(widget.viewModel.onsiteEmailController.text) !=
        null) invalidFields.add('Onsite Contact Email');

    // AE Contact
    if (_requiredField('AE Contact Person First Name',
            widget.viewModel.aeContactFirstNameController.text) !=
        null) invalidFields.add('AE Contact First Name');
    if (_requiredField('AE Contact Person Last Name',
            widget.viewModel.aeContactLastNameController.text) !=
        null) invalidFields.add('AE Contact Last Name');
    if (Validators.validateSouthAfricanPhoneNumber(
            widget.viewModel.aeNumberController.text) !=
        null) invalidFields.add('AE Contact Number');
    if (Validators.validateEmail(widget.viewModel.aeEmailController.text) !=
        null) invalidFields.add('AE Contact Email');

    // Options
    if (_requiredSelection('Medical Aid', widget.viewModel.medicalAid) != null)
      invalidFields.add('Medical Aid');
    if (_requiredSelection('Non-Members', widget.viewModel.nonMembers) != null)
      invalidFields.add('Non-Members');
    if (_requiredSelection('Coordinators', widget.viewModel.coordinators) !=
        null) invalidFields.add('Coordinators');
    if (_requiredSelection(
            'Multiply Promoters', widget.viewModel.multiplyPromoters) !=
        null) invalidFields.add('Multiply Promoters');
    if (_requiredSelection('Mobile Booths', widget.viewModel.mobileBooths) !=
        null) invalidFields.add('Mobile Booths');

    if (widget.viewModel.selectedServices.isEmpty)
      invalidFields.add('Services Requested');

    // Time Details
    if (_requiredField(
            'Setup Time', widget.viewModel.setUpTimeController.text) !=
        null) invalidFields.add('Setup Time');
    if (_requiredField(
            'Start Time', widget.viewModel.startTimeController.text) !=
        null) invalidFields.add('Start Time');
    if (_requiredField('End Time', widget.viewModel.endTimeController.text) !=
        null) invalidFields.add('End Time');
    if (_requiredField('Strike Down Time',
            widget.viewModel.strikeDownTimeController.text) !=
        null) invalidFields.add('Strike Down Time');

    if (invalidFields.isNotEmpty) {
      final message = invalidFields.join(', ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please complete the following fields: $message"),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // All fields valid, proceed to save
    final eventDate =
        DateTime.tryParse(widget.viewModel.dateController.text) ?? widget.date;
    WellnessEvent eventToSave;
    final isEditMode = widget.existingEvent != null;

    if (isEditMode) {
      eventToSave = widget.viewModel
          .buildEvent(eventDate)
          .copyWith(id: widget.existingEvent!.id);
    } else {
      eventToSave = widget.viewModel.buildEvent(eventDate);
    }

    await widget.onSave(eventToSave);

    if (!mounted) return;
    widget.viewModel.clearControllers();

    // Show success SnackBar at the top
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditMode
            ? "Event updated successfully"
            : "Event created successfully"),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      ),
    );

    Navigator.pop(context);
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
                  label: 'Contact Person First Name',
                  controller: widget.viewModel.onsiteContactFirstNameController,
                  padding: EdgeInsets.zero,
                  inputFormatters:
                      AppTextInputFormatters.lettersOnly(allowHyphen: true),
                  validator: (value) =>
                      _requiredField('Contact Person First Name', value),
                ),
                KenwellTextField(
                  label: 'Contact Person Last Name',
                  controller: widget.viewModel.onsiteContactLastNameController,
                  padding: EdgeInsets.zero,
                  inputFormatters:
                      AppTextInputFormatters.lettersOnly(allowHyphen: true),
                  validator: (value) =>
                      _requiredField('Contact Person Last Name', value),
                ),
                KenwellTextField(
                  label: 'Contact Number',
                  controller: widget.viewModel.onsiteNumberController,
                  padding: EdgeInsets.zero,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    AppTextInputFormatters.saPhoneNumberFormatter()
                  ],
                  validator: Validators.validateSouthAfricanPhoneNumber,
                ),
                KenwellTextField(
                  label: 'Email',
                  controller: widget.viewModel.onsiteEmailController,
                  padding: EdgeInsets.zero,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
              ]),
              _buildSectionCard('AE Contact', [
                KenwellTextField(
                  label: 'Contact Person First Name',
                  controller: widget.viewModel.aeContactFirstNameController,
                  padding: EdgeInsets.zero,
                  inputFormatters:
                      AppTextInputFormatters.lettersOnly(allowHyphen: true),
                  validator: (value) =>
                      _requiredField('AE Contact Person First Name', value),
                ),
                KenwellTextField(
                  label: 'Contact Person Last Name',
                  controller: widget.viewModel.aeContactLastNameController,
                  padding: EdgeInsets.zero,
                  inputFormatters:
                      AppTextInputFormatters.lettersOnly(allowHyphen: true),
                  validator: (value) =>
                      _requiredField('AE Contact Person Last Name', value),
                ),
                KenwellTextField(
                  label: 'Contact Number',
                  controller: widget.viewModel.aeNumberController,
                  padding: EdgeInsets.zero,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    AppTextInputFormatters.saPhoneNumberFormatter()
                  ],
                  validator: Validators.validateSouthAfricanPhoneNumber,
                ),
                KenwellTextField(
                  label: 'Email',
                  controller: widget.viewModel.aeEmailController,
                  padding: EdgeInsets.zero,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
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
                _buildServicesRequestedField(context),
              ]),
              _buildSectionCard('Time Details', [
                KenwellTextField(
                  label: 'Setup Time',
                  controller: widget.viewModel.setUpTimeController,
                  padding: EdgeInsets.zero,
                  readOnly: true,
                  suffixIcon: const Icon(
                    Icons.access_time,
                    color: KenwellColors.primaryGreen,
                  ),
                  validator: (value) => _requiredField('Setup Time', value),
                  onTap: () => widget.viewModel
                      .pickTime(context, widget.viewModel.setUpTimeController),
                ),
                KenwellTextField(
                  label: 'Start Time',
                  controller: widget.viewModel.startTimeController,
                  padding: EdgeInsets.zero,
                  readOnly: true,
                  suffixIcon: const Icon(
                    Icons.access_time,
                    color: KenwellColors.primaryGreen,
                  ),
                  validator: (value) => _requiredField('Start Time', value),
                  onTap: () => widget.viewModel
                      .pickTime(context, widget.viewModel.startTimeController),
                ),
                KenwellTextField(
                  label: 'End Time',
                  controller: widget.viewModel.endTimeController,
                  padding: EdgeInsets.zero,
                  readOnly: true,
                  suffixIcon: const Icon(
                    Icons.access_time,
                    color: KenwellColors.primaryGreen,
                  ),
                  validator: (value) => _requiredField('End Time', value),
                  onTap: () => widget.viewModel
                      .pickTime(context, widget.viewModel.endTimeController),
                ),
                KenwellTextField(
                  label: 'Strike Down Time',
                  controller: widget.viewModel.strikeDownTimeController,
                  padding: EdgeInsets.zero,
                  readOnly: true,
                  suffixIcon: const Icon(
                    Icons.access_time,
                    color: KenwellColors.primaryGreen,
                  ),
                  validator: (value) =>
                      _requiredField('Strike Down Time', value),
                  onTap: () => widget.viewModel.pickTime(
                      context, widget.viewModel.strikeDownTimeController),
                ),
              ]),
              const SizedBox(height: 20),
              // Row with Cancel and Save buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: KenwellColors.primaryGreen, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: KenwellColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomPrimaryButton(
                      label: 'Save Event',
                      onPressed: _validateAndSave,
                    ),
                  ),
                ],
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

  Widget _buildServicesRequestedField(BuildContext context) {
    return FormField<Set<String>>(
      initialValue: widget.viewModel.selectedServices,
      validator: (_) {
        if (widget.viewModel.selectedServices.isEmpty) {
          return 'Select at least one service';
        }
        return null;
      },
      builder: (field) {
        final labelStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Services Requested',
              style: labelStyle,
            ),
            const SizedBox(height: 8),
            KenwellCheckboxGroup(
              options: widget.viewModel.availableServiceOptions
                  .map(
                    (service) => KenwellCheckboxOption(
                      label: service,
                      value: widget.viewModel.isServiceSelected(service),
                      onChanged: (checked) {
                        setState(() {
                          widget.viewModel.toggleServiceSelection(
                            service,
                            checked ?? false,
                          );
                          field.didChange(widget.viewModel.selectedServices);
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
