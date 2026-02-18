import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/logo/app_logo.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/buttons/form_action_buttons.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/dialogs/confirmation_dialog.dart';
import '../utils/event_form_validator.dart';
import '../view_model/event_view_model.dart';
import 'sections/event_basic_info_section.dart';
import 'sections/contact_person_section.dart';
import 'sections/event_time_section.dart';
import 'sections/event_options_section.dart';
import 'sections/healthcare_professionals_section.dart';
import 'sections/services_selection_section.dart';
import 'sections/medical_aid_section.dart';
import 'sections/participation_section.dart';

// EventScreen allows adding or editing a wellness event
class EventScreen extends StatefulWidget {
  // ViewModel for managing event data
  final EventViewModel viewModel;
  final DateTime date;
  final WellnessEvent? existingEvent;
  final Future<void> Function(WellnessEvent) onSave;

  // Constructor
  const EventScreen({
    super.key,
    required this.viewModel,
    required this.date,
    this.existingEvent,
    required this.onSave,
  });

  // Create state
  @override
  State<EventScreen> createState() => _EventScreenState();
}

// State class for EventScreen
class _EventScreenState extends State<EventScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _didLoadExistingEvent = false;
  String _wantsAdditionalServices = 'No'; // 'Yes' or 'No'

  // Initialize state
  @override
  void initState() {
    super.initState();
    final WellnessEvent? eventToEdit = widget.existingEvent;

    // Load existing event data into the ViewModel if editing
    if (eventToEdit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (!_didLoadExistingEvent) {
          widget.viewModel.loadExistingEvent(eventToEdit);
          // Check if event has additional services
          final hasAdditionalServices =
              eventToEdit.additionalServicesRequested.isNotEmpty;
          setState(() {
            _didLoadExistingEvent = true;
            _wantsAdditionalServices = hasAdditionalServices ? 'Yes' : 'No';
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
      context.pop();
      return;
    }

    // Show confirmation dialog
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
      context.pop();
    }
  }

  // Validate form and save event
  Future<void> _validateAndSave() async {
    final invalidFields =
        EventFormValidator.validateEventForm(widget.viewModel);

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

    // Build event object to save
    if (isEditMode) {
      eventToSave = widget.viewModel
          .buildEvent(eventDate)
          .copyWith(id: widget.existingEvent!.id);
    } else {
      eventToSave = widget.viewModel.buildEvent(eventDate);
    }

    // Save event using the provided onSave callback
    try {
      debugPrint('EventScreen: Saving event "${eventToSave.title}"');
      await widget.onSave(eventToSave);
      debugPrint('EventScreen: Event saved successfully via onSave callback');
    } catch (e, stackTrace) {
      debugPrint('EventScreen: ERROR saving event: $e');
      debugPrintStack(stackTrace: stackTrace);

      // Show error SnackBar at the top
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving event: $e"),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // Clear controllers and show success message
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

    // Close the screen
    context.pop();
  }

  // Build method
  @override
  Widget build(BuildContext context) {
    final WellnessEvent? eventToEdit = widget.existingEvent;
    final bool isEditMode = eventToEdit != null;

    // Build the Scaffold
    return Scaffold(
      appBar: KenwellAppBar(
        title: isEditMode ? 'Edit Event' : 'Add Event',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        // Form for event details
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const AppLogo(size: 200),
              const SizedBox(height: 16),
              // Section header
              KenwellSectionHeader(
                title: isEditMode ? 'Edit Event' : 'Add New Event',
                subtitle:
                    'Complete the event details or update the event information',
                icon: isEditMode ? Icons.edit : Icons.add_circle_outline,
              ),
              // Event Basic Info Section
              EventBasicInfoSection(
                viewModel: widget.viewModel,
                date: widget.date,
                requiredField: _requiredField,
              ),
              // Contact Person Sections
              ContactPersonSection(
                viewModel: widget.viewModel,
                title: 'Onsite Contact Person',
                isOnsite: true,
                requiredField: _requiredField,
              ),
              // AE Contact Person Section
              ContactPersonSection(
                viewModel: widget.viewModel,
                title: 'AE Contact Person',
                isOnsite: false,
                requiredField: _requiredField,
              ),
              // Medical Aid Section
              MedicalAidSection(
                viewModel: widget.viewModel,
                requiredSelection: _requiredSelection,
              ),
              // Participation Section
              ParticipationSection(
                viewModel: widget.viewModel,
              ),
              // Event Options Section
              EventOptionsSection(
                viewModel: widget.viewModel,
                requiredSelection: _requiredSelection,
              ),
              // Services Selection Section
              ServicesSelectionSection(
                viewModel: widget.viewModel,
                isAdditionalServices: false,
              ),
              // Additional Services Dropdown
              KenwellFormCard(
                title: 'Additional Services',
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Would you like to request additional services?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Dropdown for additional services selection
                    DropdownButtonFormField<String>(
                      initialValue: _wantsAdditionalServices,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF201C58),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: ['No', 'Yes'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _wantsAdditionalServices = newValue ?? 'No';
                          // Clear additional services if user selects No
                          if (_wantsAdditionalServices == 'No') {
                            // Clear all additional service selections
                            final additionalServices = widget
                                .viewModel.selectedAdditionalServices
                                .toList();
                            for (var service in additionalServices) {
                              widget.viewModel.toggleAdditionalServiceSelection(
                                  service, false);
                            }
                          }
                        });
                      },
                    ),
                    // Show additional services checkboxes only if 'Yes' is selected
                    if (_wantsAdditionalServices == 'Yes') ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      ServicesSelectionSection(
                        viewModel: widget.viewModel,
                        isAdditionalServices: true,
                        isRequired: false, // Additional services are optional
                      ),
                    ],
                  ],
                ),
              ),
              // Healthcare Professionals Section
              HealthcareProfessionalsSection(
                viewModel: widget.viewModel,
                requiredSelection: _requiredSelection,
              ),
              // Event Time Section
              EventTimeSection(
                viewModel: widget.viewModel,
                requiredField: _requiredField,
              ),
              const SizedBox(height: 20),
              // Form action buttons
              FormActionButtons(
                onCancel: _handleCancel,
                onSave: _validateAndSave,
                saveLabel: 'Save Event',
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// Validation helper for required fields
String? _requiredField(String? label, String? value) =>
    (value == null || value.isEmpty)
        ? 'Please Enter ${label ?? "Field"}'
        : null;

// Validation helper for required selections
String? _requiredSelection(String? label, String? value) =>
    (value == null || value.isEmpty)
        ? 'Please Select ${label ?? "Field"}'
        : null;
