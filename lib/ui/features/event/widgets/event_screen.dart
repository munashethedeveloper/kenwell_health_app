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
      // Defer loading into the viewModel until after the first frame so we avoid
      // notifyListeners() / markNeedsBuild() during the build phase.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (!_didLoadExistingEvent) {
          widget.viewModel.loadExistingEvent(eventToEdit);
          _didLoadExistingEvent = true;
        }
      });
    } else {
      // Initialize the dateController with the calendar-selected date
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
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: options
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (val) {
          if (val != null) onChanged(val); // safely unwrap nullable
        },
      );
    }

    Widget buildTimeField(String label, TextEditingController controller) {
      return TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.access_time),
        ),
        onTap: () async {
          // Make the callback async
          await widget.viewModel.pickTime(context, controller);
        },
      );
    }

    return Scaffold(
      appBar: KenwellAppBar(title: isEditMode ? 'Edit Event' : 'Add Event'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Info
            const Text('Basic Info',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),

            // Date Field
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

            // Title, Venue, Address
            TextFormField(
              controller: widget.viewModel.titleController,
              decoration: const InputDecoration(labelText: 'Event Title'),
            ),
            TextFormField(
              controller: widget.viewModel.venueController,
              decoration: const InputDecoration(labelText: 'Venue'),
            ),
            TextFormField(
              controller: widget.viewModel.addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 16),

            // Onsite Contact
            const Text('Onsite Contact',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.viewModel.onsiteContactController,
              decoration: const InputDecoration(labelText: 'Contact Person'),
            ),
            TextFormField(
              controller: widget.viewModel.onsiteNumberController,
              decoration: const InputDecoration(labelText: 'Contact Number'),
              keyboardType: TextInputType.phone,
            ),
            TextFormField(
              controller: widget.viewModel.onsiteEmailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // AE Contact
            const Text('AE Contact',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.viewModel.aeContactController,
              decoration: const InputDecoration(labelText: 'Contact Person'),
            ),
            TextFormField(
              controller: widget.viewModel.aeNumberController,
              decoration: const InputDecoration(labelText: 'Contact Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Participation & Numbers
            const Text('Participation & Numbers',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.viewModel.expectedParticipationController,
              decoration:
                  const InputDecoration(labelText: 'Expected Participation'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: widget.viewModel.passportsController,
              decoration: const InputDecoration(labelText: 'Passports'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: widget.viewModel.nursesController,
              decoration: const InputDecoration(labelText: 'Nurses'),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            // Dropdown Options
            const Text('Options',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            buildDropdown('Medical Aid', widget.viewModel.medicalAid,
                ['Yes', 'No'], (val) => widget.viewModel.medicalAid = val),
            buildDropdown('Non-Members', widget.viewModel.nonMembers,
                ['Yes', 'No'], (val) => widget.viewModel.nonMembers = val),
            buildDropdown('Coordinators', widget.viewModel.coordinators,
                ['Yes', 'No'], (val) => widget.viewModel.coordinators = val),
            buildDropdown(
                'Multiply Promoters',
                widget.viewModel.multiplyPromoters,
                ['Yes', 'No'],
                (val) => widget.viewModel.multiplyPromoters = val),
            buildDropdown('Mobile Booths', widget.viewModel.mobileBooths,
                ['Yes', 'No'], (val) => widget.viewModel.mobileBooths = val),
            buildDropdown(
                'Services Requested',
                widget.viewModel.servicesRequested,
                ['HRA', 'Other'],
                (val) => widget.viewModel.servicesRequested = val),
            const SizedBox(height: 16),

            // Time Details
            const Text('Time Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            buildTimeField('Setup Time', widget.viewModel.setUpTimeController),
            buildTimeField('Start Time', widget.viewModel.startTimeController),
            buildTimeField('End Time', widget.viewModel.endTimeController),
            buildTimeField(
                'Strike Down Time', widget.viewModel.strikeDownTimeController),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Use date from the dateController if available
                  final eventDate =
                      DateTime.tryParse(widget.viewModel.dateController.text) ??
                          widget.date;

                  WellnessEvent eventToSave;
                  if (isEditMode) {
                    // Create updated event with existing ID
                    eventToSave =
                        widget.viewModel.buildEvent(eventDate).copyWith(
                              id: eventToEdit!.id,
                            );
                  } else {
                    // Create new event
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
                ),
                child: const Text('Save Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
