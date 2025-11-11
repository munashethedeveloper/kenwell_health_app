import 'package:flutter/material.dart';
import '../view_model/event_view_model.dart';
import '../../../../domain/models/wellness_event.dart';

class EventScreen extends StatelessWidget {
  final EventViewModel viewModel;
  final DateTime date;
  final List<WellnessEvent>? existingEvents;
  final void Function(WellnessEvent) onSave;

  const EventScreen({
    super.key,
    required this.viewModel,
    required this.date,
    this.existingEvents,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    // Load existing event if editing
    if (existingEvents != null && existingEvents!.isNotEmpty) {
      viewModel.loadExistingEvent(existingEvents!.first);
    } else {
      // Initialize the dateController with the calendar-selected date
      viewModel.dateController.text =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }

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
          await viewModel.pickTime(context, controller);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add new event',
          style: TextStyle(
            color: Color(0xFF201C58),
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFF90C048),
        centerTitle: true,
      ),
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
              controller: viewModel.dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Event Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null && context.mounted) {
                  viewModel.dateController.text =
                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                }
              },
            ),

            // Title, Venue, Address
            TextFormField(
              controller: viewModel.titleController,
              decoration: const InputDecoration(labelText: 'Event Title'),
            ),
            TextFormField(
              controller: viewModel.venueController,
              decoration: const InputDecoration(labelText: 'Venue'),
            ),
            TextFormField(
              controller: viewModel.addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 16),

            // Onsite Contact
            const Text('Onsite Contact',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextFormField(
              controller: viewModel.onsiteContactController,
              decoration: const InputDecoration(labelText: 'Contact Person'),
            ),
            TextFormField(
              controller: viewModel.onsiteNumberController,
              decoration: const InputDecoration(labelText: 'Contact Number'),
              keyboardType: TextInputType.phone,
            ),
            TextFormField(
              controller: viewModel.onsiteEmailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // AE Contact
            const Text('AE Contact',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextFormField(
              controller: viewModel.aeContactController,
              decoration: const InputDecoration(labelText: 'Contact Person'),
            ),
            TextFormField(
              controller: viewModel.aeNumberController,
              decoration: const InputDecoration(labelText: 'Contact Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Participation & Numbers
            const Text('Participation & Numbers',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextFormField(
              controller: viewModel.expectedParticipationController,
              decoration:
                  const InputDecoration(labelText: 'Expected Participation'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: viewModel.passportsController,
              decoration: const InputDecoration(labelText: 'Passports'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: viewModel.nursesController,
              decoration: const InputDecoration(labelText: 'Nurses'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Dropdown Options
            const Text('Options',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            buildDropdown('Non-Members', viewModel.nonMembers, ['Yes', 'No'],
                (val) => viewModel.nonMembers = val),
            buildDropdown('Coordinators', viewModel.coordinators, ['Yes', 'No'],
                (val) => viewModel.coordinators = val),
            buildDropdown('Multiply Promoters', viewModel.multiplyPromoters,
                ['Yes', 'No'], (val) => viewModel.multiplyPromoters = val),
            buildDropdown('Mobile Booths', viewModel.mobileBooths,
                ['Yes', 'No'], (val) => viewModel.mobileBooths = val),
            buildDropdown('Services Requested', viewModel.servicesRequested,
                ['HRA', 'Other'], (val) => viewModel.servicesRequested = val),
            const SizedBox(height: 16),

            // Time Details
            const Text('Time Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            buildTimeField('Setup Time', viewModel.setUpTimeController),
            buildTimeField('Start Time', viewModel.startTimeController),
            buildTimeField('End Time', viewModel.endTimeController),
            buildTimeField(
                'Strike Down Time', viewModel.strikeDownTimeController),
            TextFormField(
              controller: viewModel.medicalAidController,
              decoration:
                  const InputDecoration(labelText: 'Medical Aid Option'),
            ),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Use date from the dateController if available
                  final eventDate =
                      DateTime.tryParse(viewModel.dateController.text) ?? date;
                  final newEvent = viewModel.buildEvent(eventDate);
                  onSave(newEvent);
                  viewModel.clearControllers();
                  Navigator.pop(context);
                },
                child: const Text('Save Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
