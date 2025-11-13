import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_date_picker.dart';
import '../../../shared/ui/form/custom_time_picker.dart';
import '../view_model/event_view_model.dart';

class EventScreen extends StatelessWidget {
  final EventViewModel viewModel;

  const EventScreen({
    super.key,
    required this.viewModel,
  });

  Widget _buildDropdown(String label, String value, List<String> options,
      void Function(String) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: options
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KenwellAppBar(title: 'Add Event'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AnimatedBuilder(
          animation: viewModel,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Basic Info',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                KenwellDatePickerField(
                  controller: viewModel.dateController,
                  label: 'Event Date',
                  displayFormat: DateFormat('yyyy-MM-dd'),
                  initialDate: viewModel.selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                ),
                TextFormField(
                    controller: viewModel.titleController,
                    decoration:
                        const InputDecoration(labelText: 'Event Title')),
                TextFormField(
                    controller: viewModel.venueController,
                    decoration: const InputDecoration(labelText: 'Venue')),
                TextFormField(
                    controller: viewModel.addressController,
                    decoration: const InputDecoration(labelText: 'Address')),
                const SizedBox(height: 16),
                const Text('Onsite Contact',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                TextFormField(
                    controller: viewModel.onsiteContactController,
                    decoration:
                        const InputDecoration(labelText: 'Contact Person')),
                TextFormField(
                    controller: viewModel.onsiteNumberController,
                    decoration:
                        const InputDecoration(labelText: 'Contact Number'),
                    keyboardType: TextInputType.phone),
                TextFormField(
                    controller: viewModel.onsiteEmailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                const Text('Options',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _buildDropdown('Medical Aid', viewModel.medicalAid,
                    ['Yes', 'No'], (val) => viewModel.setMedicalAid(val)),
                _buildDropdown('Non-Members', viewModel.nonMembers,
                    ['Yes', 'No'], (val) => viewModel.setNonMembers(val)),
                _buildDropdown(
                    'Services Requested',
                    viewModel.servicesRequested,
                    ['HRA', 'Other'],
                    (val) => viewModel.setServicesRequested(val)),
                const SizedBox(height: 16),
                const Text('Time Details',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                KenwellTimePickerField(
                  controller: viewModel.startTimeController,
                  label: 'Start Time',
                  onTimeChanged: (t) {
                    if (t != null) viewModel.setStartTime(t, context);
                  },
                ),
                KenwellTimePickerField(
                  controller: viewModel.endTimeController,
                  label: 'End Time',
                  onTimeChanged: (t) {
                    if (t != null) viewModel.setEndTime(t, context);
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      viewModel.saveEvent();
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
            );
          },
        ),
      ),
    );
  }
}
