import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:kenwell_health_app/ui/shared/ui/logo/app_logo.dart';
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
import '../../../shared/ui/dialogs/confirmation_dialog.dart';
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

  /// Check if the form has any data entered
  bool _hasUnsavedChanges() {
    return widget.viewModel.titleController.text.isNotEmpty ||
        widget.viewModel.venueController.text.isNotEmpty ||
        widget.viewModel.addressController.text.isNotEmpty ||
        widget.viewModel.onsiteContactFirstNameController.text.isNotEmpty ||
        widget.viewModel.aeContactFirstNameController.text.isNotEmpty;
  }

  /// Handle cancel with unsaved changes confirmation
  Future<void> _handleCancel() async {
    if (!_hasUnsavedChanges()) {
      Navigator.pop(context);
      return;
    }

    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Discard Changes?',
      message:
          'You have unsaved changes. Are you sure you want to discard them?',
      confirmText: 'Discard',
      cancelText: 'Keep Editing',
      confirmColor: Colors.orange,
      icon: Icons.warning,
    );

    if (confirmed && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _validateAndSave() async {
    final invalidFields = <String>[];

    // Basic Info
    if (_requiredField('Event Title', widget.viewModel.titleController.text) !=
        null) {
      invalidFields.add('Event Title');
    }
    if (_requiredField('Venue', widget.viewModel.venueController.text) !=
        null) {
      invalidFields.add('Venue');
    }
    if (_requiredField('Address', widget.viewModel.addressController.text) !=
        null) {
      invalidFields.add('Address');
    }

    // Onsite Contact
    if (_requiredField('Contact Person First Name',
            widget.viewModel.onsiteContactFirstNameController.text) !=
        null) {
      invalidFields.add('Onsite Contact First Name');
    }
    if (_requiredField('Contact Person Last Name',
            widget.viewModel.onsiteContactLastNameController.text) !=
        null) {
      invalidFields.add('Onsite Contact Last Name');
    }
    if (Validators.validateSouthAfricanPhoneNumber(
            widget.viewModel.onsiteNumberController.text) !=
        null) {
      invalidFields.add('Onsite Contact Number');
    }
    if (Validators.validateEmail(widget.viewModel.onsiteEmailController.text) !=
        null) {
      invalidFields.add('Onsite Contact Email');
    }

    // AE Contact
    if (_requiredField('AE Contact Person First Name',
            widget.viewModel.aeContactFirstNameController.text) !=
        null) {
      invalidFields.add('AE Contact First Name');
    }
    if (_requiredField('AE Contact Person Last Name',
            widget.viewModel.aeContactLastNameController.text) !=
        null) {
      invalidFields.add('AE Contact Last Name');
    }
    if (Validators.validateSouthAfricanPhoneNumber(
            widget.viewModel.aeNumberController.text) !=
        null) {
      invalidFields.add('AE Contact Number');
    }
    if (Validators.validateEmail(widget.viewModel.aeEmailController.text) !=
        null) {
      invalidFields.add('AE Contact Email');
    }

    // Options
    if (_requiredSelection('Medical Aid', widget.viewModel.medicalAid) !=
        null) {
      invalidFields.add('Medical Aid');
    }
    if (_requiredSelection('Coordinators', widget.viewModel.coordinators) !=
        null) {
      invalidFields.add('Coordinators');
    }
    if (_requiredSelection('Mobile Booths', widget.viewModel.mobileBooths) !=
        null) {
      invalidFields.add('Mobile Booths');
    }

    if (widget.viewModel.selectedServices.isEmpty) {
      invalidFields.add('Services Requested');
    }

    // Time Details
    if (_requiredField(
            'Setup Time', widget.viewModel.setUpTimeController.text) !=
        null) {
      invalidFields.add('Setup Time');
    }
    if (_requiredField(
            'Start Time', widget.viewModel.startTimeController.text) !=
        null) {
      invalidFields.add('Start Time');
    }
    if (_requiredField('End Time', widget.viewModel.endTimeController.text) !=
        null) {
      invalidFields.add('End Time');
    }
    if (_requiredField('Strike Down Time',
            widget.viewModel.strikeDownTimeController.text) !=
        null) {
      invalidFields.add('Strike Down Time');
    }

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
              const SizedBox(height: 16),
              const AppLogo(size: 200),
              const SizedBox(height: 16),
              KenwellSectionHeader(
                title: isEditMode ? 'Edit Event' : 'Add New Event',
                subtitle:
                    'Complete the event details or update the event information',
              ),
              _buildSectionCard('Event Date', [
                KenwellDateField(
                  label: 'Event Date',
                  controller: widget.viewModel.dateController,
                  dateFormat: 'yyyy-MM-dd',
                  initialDate: widget.date,
                  enabled: false,
                ),
              ]),

              _buildSectionCard('Event Title', [
                KenwellTextField(
                  label: 'Event Title',
                  controller: widget.viewModel.titleController,
                  padding: EdgeInsets.zero,
                  validator: (value) => _requiredField('Event Title', value),
                ),
              ]),

              _buildSectionCard('Event Location', [
                KenwellTextField(
                  label: 'Address',
                  controller: widget.viewModel.addressController,
                  padding: EdgeInsets.zero,
                  validator: (value) => _requiredField('Address', value),
                ),
                KenwellTextField(
                  label: 'Town/City',
                  controller: widget.viewModel.townCityController,
                  padding: EdgeInsets.zero,
                  validator: (value) => _requiredField('Town/City', value),
                ),
                KenwellDropdownField<String>(
                  label: 'Province',
                  value: widget.viewModel.province,
                  items: const [
                    'Gauteng',
                    'Western Cape',
                    'KwaZulu-Natal',
                    'Eastern Cape',
                    'Limpopo',
                    'Mpumalanga',
                    'North West',
                    'Free State',
                    'Northern Cape'
                  ],
                  onChanged: (val) {
                    if (val != null) widget.viewModel.updateProvince(val);
                  },
                  decoration: KenwellFormStyles.decoration(
                    label: 'Province',
                    hint: 'Select Province',
                  ),
                ),
                KenwellTextField(
                  label: 'Venue',
                  controller: widget.viewModel.venueController,
                  padding: EdgeInsets.zero,
                  validator: (value) => _requiredField('Venue', value),
                ),
              ]),

              _buildSectionCard('Onsite Contact Person', [
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
              _buildSectionCard('AE Contact Person', [
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
              _buildSectionCard('Medical Aid Option', [
                // MEDICAL AID
                KenwellDropdownField<String>(
                  label: 'Do the Clients Have Medical Aid?',
                  value: _nullableValue(widget.viewModel.medicalAid),
                  items: const ['Yes', 'No'],
                  onChanged: (val) {
                    setState(() {
                      widget.viewModel.medicalAid = val ?? '';
                    });
                  },
                  padding: EdgeInsets.zero,
                  validator: (val) => _requiredSelection('Medical Aid', val),
                ),

                // _buildServicesRequestedField(context),
              ]),
              _buildSectionCard('Participation Numbers', [
                _buildSpinBoxField(
                  'Expected Participation',
                  widget.viewModel.expectedParticipationController,
                ),
                /* _buildSpinBoxField(
                  'Nurses',
                  widget.viewModel.nursesController,
                ), */
              ]),

              _buildSectionCard('Coordinators Option', [
                // COORDINATORS — DROPDOWN + SPINBOX WHEN YES
                KenwellDropdownField<String>(
                  label: 'Do You Need Coordinators?',
                  value: _nullableValue(widget.viewModel.coordinatorsOption),
                  items: const ['Yes', 'No'],
                  onChanged: (val) {
                    setState(() {
                      widget.viewModel.coordinatorsOption = val ?? 'No';
                      if (val == 'No') widget.viewModel.coordinatorsCount = 0;
                    });
                  },
                  padding: EdgeInsets.zero,
                  validator: (val) => _requiredSelection('Coordinators', val),
                ),

                if (widget.viewModel.coordinatorsOption == 'Yes')
                  SpinBox(
                    min: 0,
                    max: 10,
                    value: widget.viewModel.coordinatorsCount.toDouble(),
                    decoration: KenwellFormStyles.decoration(
                      label: 'Number of Coordinators Needed',
                      hint: 'Please Enter Number',
                    ),
                    onChanged: (value) {
                      setState(() =>
                          widget.viewModel.coordinatorsCount = value.toInt());
                    },
                  ),
              ]),

              _buildSectionCard('Mobile Booths Option', [
                // MOBILE BOOTHS — DROPDOWN + SPINBOX WHEN YES
                KenwellDropdownField<String>(
                  label: 'Do You Need Mobile Booths?',
                  value: _nullableValue(widget.viewModel.mobileBoothsOption),
                  items: const ['Yes', 'No'],
                  onChanged: (val) {
                    setState(() {
                      widget.viewModel.mobileBoothsOption = val ?? 'No';
                      if (val == 'No') widget.viewModel.mobileBoothsCount = 0;
                    });
                  },
                  padding: EdgeInsets.zero,
                  validator: (val) => _requiredSelection('Mobile Booths', val),
                ),

                if (widget.viewModel.mobileBoothsOption == 'Yes')
                  SpinBox(
                    min: 0,
                    max: 20,
                    value: widget.viewModel.mobileBoothsCount.toDouble(),
                    decoration: KenwellFormStyles.decoration(
                      label: 'Number of Mobile Booths Needed',
                      hint: 'Please Enter Number',
                    ),
                    onChanged: (value) {
                      setState(() =>
                          widget.viewModel.mobileBoothsCount = value.toInt());
                    },
                  ),
              ]),

              _buildSectionCard('Requested Services',
                  [_buildServicesRequestedField(context)]),

              _buildSectionCard('Additional Services Requested',
                  [_buildAdditionalServicesRequestedField(context)]),

              _buildSectionCard('Healthcare Professionals Needed', [
                //Dental Hygenists — DROPDOWN + SPINBOX WHEN YES
                KenwellDropdownField<String>(
                  label: 'Do You Need Dental Hygenists?',
                  value: _nullableValue(widget.viewModel.dentalHygenistsOption),
                  items: const ['Yes', 'No'],
                  onChanged: (val) {
                    setState(() {
                      widget.viewModel.dentalHygenistsOption = val ?? 'No';
                      if (val == 'No') {
                        widget.viewModel.dentalHygenistsCount = 0;
                      }
                    });
                  },
                  padding: EdgeInsets.zero,
                  validator: (val) =>
                      _requiredSelection('Dental Hygenists', val),
                ),

                if (widget.viewModel.dentalHygenistsOption == 'Yes')
                  SpinBox(
                    min: 0,
                    max: 20,
                    value: widget.viewModel.dentalHygenistsCount.toDouble(),
                    decoration: KenwellFormStyles.decoration(
                      label: 'Number of Dental Hygenists Needed',
                      hint: 'Please Enter Number',
                    ),
                    onChanged: (value) {
                      setState(() => widget.viewModel.dentalHygenistsCount =
                          value.toInt());
                    },
                  ),

                //Dietician — DROPDOWN + SPINBOX WHEN YES
                KenwellDropdownField<String>(
                  label: 'Do You Need Dieticians?',
                  value: _nullableValue(widget.viewModel.dieticiansOption),
                  items: const ['Yes', 'No'],
                  onChanged: (val) {
                    setState(() {
                      widget.viewModel.dieticiansOption = val ?? 'No';
                      if (val == 'No') widget.viewModel.dieticiansCount = 0;
                    });
                  },
                  padding: EdgeInsets.zero,
                  validator: (val) => _requiredSelection('Dieticians', val),
                ),

                if (widget.viewModel.dieticiansOption == 'Yes')
                  SpinBox(
                    min: 0,
                    max: 20,
                    value: widget.viewModel.dieticiansCount.toDouble(),
                    decoration: KenwellFormStyles.decoration(
                      label: 'Number of Dieticians Needed',
                      hint: 'Please Enter Number',
                    ),
                    onChanged: (value) {
                      setState(() =>
                          widget.viewModel.dieticiansCount = value.toInt());
                    },
                  ),

                //Nurses — DROPDOWN + SPINBOX WHEN YES
                KenwellDropdownField<String>(
                  label: 'Do You Need Nurses?',
                  value: _nullableValue(widget.viewModel.nursesOption),
                  items: const ['Yes', 'No'],
                  onChanged: (val) {
                    setState(() {
                      widget.viewModel.nursesOption = val ?? 'No';
                      if (val == 'No') widget.viewModel.nursesCount = 0;
                    });
                  },
                  padding: EdgeInsets.zero,
                  validator: (val) => _requiredSelection('Nurses', val),
                ),

                if (widget.viewModel.nursesOption == 'Yes')
                  SpinBox(
                    min: 0,
                    max: 20,
                    value: widget.viewModel.nursesCount.toDouble(),
                    decoration: KenwellFormStyles.decoration(
                      label: 'Number of Nurses Needed',
                      hint: 'Please Enter Number',
                    ),
                    onChanged: (value) {
                      setState(
                          () => widget.viewModel.nursesCount = value.toInt());
                    },
                  ),

                //Optometrists — DROPDOWN + SPINBOX WHEN YES
                KenwellDropdownField<String>(
                  label: 'Do You Need Optometrists?',
                  value: _nullableValue(widget.viewModel.optometristsOption),
                  items: const ['Yes', 'No'],
                  onChanged: (val) {
                    setState(() {
                      widget.viewModel.optometristsOption = val ?? 'No';
                      if (val == 'No') {
                        widget.viewModel.optometristsCount = 0;
                      }
                    });
                  },
                  padding: EdgeInsets.zero,
                  validator: (val) => _requiredSelection('Optometrists', val),
                ),

                if (widget.viewModel.optometristsOption == 'Yes')
                  SpinBox(
                    min: 0,
                    max: 20,
                    value: widget.viewModel.optometristsCount.toDouble(),
                    decoration: KenwellFormStyles.decoration(
                      label: 'Number of Optometrists Needed',
                      hint: 'Please Enter Number',
                    ),
                    onChanged: (value) {
                      setState(() =>
                          widget.viewModel.optometristsCount = value.toInt());
                    },
                  ),

                //Occupational Therapists — DROPDOWN + SPINBOX WHEN YES
                KenwellDropdownField<String>(
                  label: 'Do You Need Occupational Therapists?',
                  value: _nullableValue(
                      widget.viewModel.occupationalTherapistsOption),
                  items: const ['Yes', 'No'],
                  onChanged: (val) {
                    setState(() {
                      widget.viewModel.occupationalTherapistsOption =
                          val ?? 'No';
                      if (val == 'No') {
                        widget.viewModel.occupationalTherapistsCount = 0;
                      }
                    });
                  },
                  padding: EdgeInsets.zero,
                  validator: (val) =>
                      _requiredSelection('Occupational Therapists', val),
                ),

                if (widget.viewModel.occupationalTherapistsOption == 'Yes')
                  SpinBox(
                    min: 0,
                    max: 20,
                    value:
                        widget.viewModel.occupationalTherapistsCount.toDouble(),
                    decoration: KenwellFormStyles.decoration(
                      label: 'Number of Occupational Therapists Needed',
                      hint: 'Please Enter Number',
                    ),
                    onChanged: (value) {
                      setState(() => widget.viewModel
                          .occupationalTherapistsCount = value.toInt());
                    },
                  ),
                //Psychologists — DROPDOWN + SPINBOX WHEN YES
                KenwellDropdownField<String>(
                  label: 'Do You Need Psychologists?',
                  value: _nullableValue(widget.viewModel.psychologistsOption),
                  items: const ['Yes', 'No'],
                  onChanged: (val) {
                    setState(() {
                      widget.viewModel.psychologistsOption = val ?? 'No';
                      if (val == 'No') widget.viewModel.psychologistsCount = 0;
                    });
                  },
                  padding: EdgeInsets.zero,
                  validator: (val) => _requiredSelection('Psychologists', val),
                ),

                if (widget.viewModel.psychologistsOption == 'Yes')
                  SpinBox(
                    min: 0,
                    max: 20,
                    value: widget.viewModel.psychologistsCount.toDouble(),
                    decoration: KenwellFormStyles.decoration(
                      label: 'Number of Psychologists Needed',
                      hint: 'Please Enter Number',
                    ),
                    onChanged: (value) {
                      setState(() =>
                          widget.viewModel.psychologistsCount = value.toInt());
                    },
                  ),
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
                      onPressed: _handleCancel,
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

  Widget _buildAdditionalServicesRequestedField(BuildContext context) {
    return FormField<Set<String>>(
      initialValue: widget.viewModel.selectedAdditionalServices,
      validator: (_) {
        if (widget.viewModel.selectedAdditionalServices.isEmpty) {
          return 'Please select at least one additional service';
        }
        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KenwellCheckboxGroup(
              options: widget.viewModel.availableAdditionalServiceOptions
                  .map(
                    (service) => KenwellCheckboxOption(
                      label: service,
                      value:
                          widget.viewModel.isAdditionalServiceSelected(service),
                      onChanged: (checked) {
                        setState(() {
                          widget.viewModel.toggleAdditionalServiceSelection(
                            service,
                            checked ?? false,
                          );
                          field.didChange(
                              widget.viewModel.selectedAdditionalServices);
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

  Widget _buildSpinBoxField(String label, TextEditingController controller) {
    final initialValue =
        double.tryParse(controller.text.isEmpty ? '0' : controller.text) ?? 0;

    return SpinBox(
      min: 0,
      max: 300,
      value: initialValue,
      step: 1,
      decimals: 0,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: false, signed: false),
      decoration: KenwellFormStyles.decoration(
          label: label, hint: 'Please Enter $label'),
      validator: (value) => value == null ? 'Please Enter $label' : null,
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
          return 'Please select at least one service';
        }
        return null;
      },
      builder: (field) {
        //final labelStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
        //    fontWeight: FontWeight.w600,
        //);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  Text(
            // 'Services Requested',
            // style: labelStyle,
            //),
            //const SizedBox(height: 8),
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
    (value == null || value.isEmpty) ? 'Please Enter $label' : null;

String? _requiredSelection(String label, String? value) =>
    (value == null || value.isEmpty) ? 'Please Select $label' : null;
