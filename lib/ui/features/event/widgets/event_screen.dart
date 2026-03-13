import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/buttons/form_action_buttons.dart';
import '../../../shared/ui/dialogs/confirmation_dialog.dart';
import '../../../shared/ui/headers/kenwell_gradient_header.dart';
import '../utils/event_form_validator.dart';
import '../view_model/event_view_model.dart';
import 'sections/event_basic_info_section.dart';
import 'sections/contact_person_section.dart';
import 'sections/event_time_section.dart';
import 'sections/event_options_section.dart';
import 'sections/services_selection_section.dart';
import 'sections/medical_aid_section.dart';
import 'sections/participation_section.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';

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
      AppSnackbar.showWarning(context, "Please complete: $message",
          duration: const Duration(seconds: 4));
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

      if (!mounted) return;
      AppSnackbar.showError(context, "Error saving event: $e",
          duration: const Duration(seconds: 5));
      return;
    }

    // Clear controllers and show success message
    if (!mounted) return;
    widget.viewModel.clearControllers();

    // Show success SnackBar
    AppSnackbar.showSuccess(context,
        isEditMode ? "Event updated successfully" : "Event created successfully");

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
      appBar: const KenwellAppBar(
        title: 'KenWell365',
        automaticallyImplyLeading: true,
        titleColor: Colors.white,
        titleStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          // ── Gradient section header ───────────────────────────────
          KenwellGradientHeader(
            // label: isEditMode ? 'EDIT EVENT' : 'EVENT',
            title: isEditMode ? 'Edit Event' : 'Add New Event',
            subtitle: isEditMode
                ? 'Update the event details below'
                : 'Complete the form to add a new event',
          ),
          // ── Scrollable form ───────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              // Form for event details
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
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
          )
        ],
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
