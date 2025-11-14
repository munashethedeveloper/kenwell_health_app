import 'package:flutter/material.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../view_model/event_view_model.dart';
import '../../../../domain/models/wellness_event.dart';

class EventScreen extends StatefulWidget {
  final EventViewModel viewModel;
  final DateTime date;
  final List<WellnessEvent>? existingEvents;
  final WellnessEvent? existingEvent;
  final void Function(WellnessEvent) onSave;

  const EventScreen({
    super.key,
    required this.viewModel,
    required this.date,
    this.existingEvents,
    this.existingEvent,
    required this.onSave,
  });

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  bool _didLoadExistingEvent = false;

  @override
  void initState() {
    super.initState();

    final WellnessEvent? eventToEdit = widget.existingEvent ??
        (widget.existingEvents != null && widget.existingEvents!.isNotEmpty
            ? widget.existingEvents!.first
            : null);

    if (eventToEdit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (!_didLoadExistingEvent) {
          widget.viewModel.loadExistingEvent(eventToEdit);
          _didLoadExistingEvent = true;
        }
      });
    } else {
      widget.viewModel.dateController.text =
          "${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final WellnessEvent? eventToEdit = widget.existingEvent ??
        (widget.existingEvents != null && widget.existingEvents!.isNotEmpty
            ? widget.existingEvents!.first
            : null);
    final bool isEditMode = eventToEdit != null;

    Widget buildDropdown(String label, String value, List<String> options,
        void Function(String) onChanged) {
      return DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: options
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (val) {
          if (val != null) onChanged(val);
        },
      );
    }

    Widget buildTimeField(String label, TextEditingController controller) {
      return TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          suffixIcon: const Icon(Icons.access_time),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onTap: () async {
          await widget.viewModel.pickTime(context, controller);
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: KenwellAppBar(title: isEditMode ? 'Edit Event' : 'Add Event'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Basic Info =====
            _buildSectionCard(
              title: 'Basic Info',
              child: Column(
                children: [
                  TextFormField(
                    controller: widget.viewModel.dateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Event Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: widget.date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null && context.mounted) {
                        widget.viewModel.dateController.text =
                            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: widget.viewModel.titleController,
                    decoration: const InputDecoration(labelText: 'Event Title'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: widget.viewModel.venueController,
                    decoration: const InputDecoration(labelText: 'Venue'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: widget.viewModel.addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== Onsite Contact =====
            _buildSectionCard(
              title: 'Onsite Contact',
              child: Column(
                children: [
                  TextFormField(
                    controller: widget.viewModel.onsiteContactController,
                    decoration:
                        const InputDecoration(labelText: 'Contact Person'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: widget.viewModel.onsiteNumberController,
                    decoration:
                        const InputDecoration(labelText: 'Contact Number'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: widget.viewModel.onsiteEmailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== AE Contact =====
            _buildSectionCard(
              title: 'AE Contact',
              child: Column(
                children: [
                  TextFormField(
                    controller: widget.viewModel.aeContactController,
                    decoration:
                        const InputDecoration(labelText: 'Contact Person'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: widget.viewModel.aeNumberController,
                    decoration:
                        const InputDecoration(labelText: 'Contact Number'),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== Participation =====
            _buildSectionCard(
              title: 'Participation & Numbers',
              child: Column(
                children: [
                  TextFormField(
                    controller:
                        widget.viewModel.expectedParticipationController,
                    decoration: const InputDecoration(
                        labelText: 'Expected Participation'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: widget.viewModel.passportsController,
                    decoration: const InputDecoration(labelText: 'Passports'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: widget.viewModel.nursesController,
                    decoration: const InputDecoration(labelText: 'Nurses'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== Options =====
            _buildSectionCard(
              title: 'Options',
              child: Column(
                children: [
                  buildDropdown(
                      'Medical Aid',
                      widget.viewModel.medicalAid,
                      ['Yes', 'No'],
                      (val) => widget.viewModel.medicalAid = val),
                  const SizedBox(height: 12),
                  buildDropdown(
                      'Non-Members',
                      widget.viewModel.nonMembers,
                      ['Yes', 'No'],
                      (val) => widget.viewModel.nonMembers = val),
                  const SizedBox(height: 12),
                  buildDropdown(
                      'Coordinators',
                      widget.viewModel.coordinators,
                      ['Yes', 'No'],
                      (val) => widget.viewModel.coordinators = val),
                  const SizedBox(height: 12),
                  buildDropdown(
                      'Multiply Promoters',
                      widget.viewModel.multiplyPromoters,
                      ['Yes', 'No'],
                      (val) => widget.viewModel.multiplyPromoters = val),
                  const SizedBox(height: 12),
                  buildDropdown(
                      'Mobile Booths',
                      widget.viewModel.mobileBooths,
                      ['Yes', 'No'],
                      (val) => widget.viewModel.mobileBooths = val),
                  const SizedBox(height: 12),
                  buildDropdown(
                      'Services Requested',
                      widget.viewModel.servicesRequested,
                      ['HRA', 'Other'],
                      (val) => widget.viewModel.servicesRequested = val),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== Time Details =====
            _buildSectionCard(
              title: 'Time Details',
              child: Column(
                children: [
                  buildTimeField(
                      'Setup Time', widget.viewModel.setUpTimeController),
                  const SizedBox(height: 12),
                  buildTimeField(
                      'Start Time', widget.viewModel.startTimeController),
                  const SizedBox(height: 12),
                  buildTimeField(
                      'End Time', widget.viewModel.endTimeController),
                  const SizedBox(height: 12),
                  buildTimeField('Strike Down Time',
                      widget.viewModel.strikeDownTimeController),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  final eventDate =
                      DateTime.tryParse(widget.viewModel.dateController.text) ??
                          widget.date;

                  WellnessEvent eventToSave;
                  if (isEditMode) {
                    eventToSave =
                        widget.viewModel.buildEvent(eventDate).copyWith(
                              id: eventToEdit!.id,
                            );
                  } else {
                    eventToSave = widget.viewModel.buildEvent(eventDate);
                  }

                  widget.onSave(eventToSave);
                  widget.viewModel.clearControllers();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF201C58),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: Colors.grey.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF201C58),
                )),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
