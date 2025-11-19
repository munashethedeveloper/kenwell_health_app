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
  final _formKey = GlobalKey<FormState>();
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
          hintText: 'Select $label',
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          fillColor: const Color(0xFFF0F0F0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
        items: options
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (val) {
          if (val != null) onChanged(val);
        },
        validator: (val) =>
            (val == null || val.isEmpty) ? 'Select $label' : null,
      );
    }

    Widget buildTimeField(String label, TextEditingController controller) {
      return TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Select $label',
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          fillColor: const Color(0xFFF0F0F0),
          suffixIcon: const Icon(Icons.access_time),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (val) =>
            (val == null || val.isEmpty) ? 'Select $label' : null,
        onTap: () async {
          await widget.viewModel.pickTime(context, controller);
        },
      );
    }

    Widget sectionWrapper(String title, List<Widget> children) {
      return Card(
        elevation: 3,
        //color: const Color(0xFFEFF2FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 10),
        shadowColor: Colors.black12,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF201C58))),
              const SizedBox(height: 12),
              ...children
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: KenwellAppBar(title: isEditMode ? 'Edit Event' : 'Add Event'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Basic Info Section
              sectionWrapper('Basic Info', [
                TextFormField(
                  controller: widget.viewModel.dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Event Date',
                    hintText: 'Select Event Date',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: Icon(Icons.calendar_today),
                    filled: true,
                    fillColor: Color(0xFFF0F0F0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Select Event Date' : null,
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
                const SizedBox(height: 10),
                TextFormField(
                  controller: widget.viewModel.titleController,
                  decoration: const InputDecoration(
                      labelText: 'Event Title',
                      hintText: 'Enter Event Title',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: true,
                      fillColor: Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)))),
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Enter Event Title' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: widget.viewModel.venueController,
                  decoration: const InputDecoration(
                      labelText: 'Venue',
                      hintText: 'Enter Venue',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: true,
                      fillColor: Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)))),
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Enter Venue' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: widget.viewModel.addressController,
                  decoration: const InputDecoration(
                      labelText: 'Address',
                      hintText: 'Enter Address',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: true,
                      fillColor: Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)))),
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Enter Address' : null,
                ),
              ]),

              // Onsite Contact Section
              sectionWrapper('Onsite Contact', [
                TextFormField(
                  controller: widget.viewModel.onsiteContactController,
                  decoration: const InputDecoration(
                      labelText: 'Contact Person',
                      hintText: 'Enter Contact Person',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: true,
                      fillColor: Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)))),
                  validator: (val) => (val == null || val.isEmpty)
                      ? 'Enter Contact Person'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: widget.viewModel.onsiteNumberController,
                  decoration: const InputDecoration(
                      labelText: 'Contact Number',
                      hintText: 'Enter Contact Number',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: true,
                      fillColor: Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)))),
                  keyboardType: TextInputType.phone,
                  validator: (val) => (val == null || val.isEmpty)
                      ? 'Enter Contact Number'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: widget.viewModel.onsiteEmailController,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter Email',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: true,
                      fillColor: Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)))),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Enter Email' : null,
                ),
              ]),

              // AE Contact Section
              sectionWrapper('AE Contact', [
                TextFormField(
                  controller: widget.viewModel.aeContactController,
                  decoration: const InputDecoration(
                      labelText: 'Contact Person',
                      hintText: 'Enter Contact Person',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: true,
                      fillColor: Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)))),
                  validator: (val) => (val == null || val.isEmpty)
                      ? 'Enter Contact Person'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: widget.viewModel.aeNumberController,
                  decoration: const InputDecoration(
                      labelText: 'Contact Number',
                      hintText: 'Enter Contact Number',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: true,
                      fillColor: Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)))),
                  keyboardType: TextInputType.phone,
                  validator: (val) => (val == null || val.isEmpty)
                      ? 'Enter Contact Number'
                      : null,
                ),
              ]),

              // Participation & Numbers Section
              sectionWrapper('Participation & Numbers', [
                TextFormField(
                  controller: widget.viewModel.expectedParticipationController,
                  decoration: const InputDecoration(
                      labelText: 'Expected Participation',
                      hintText: 'Enter Expected Participation',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: true,
                      fillColor: Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)))),
                  keyboardType: TextInputType.number,
                  validator: (val) => (val == null || val.isEmpty)
                      ? 'Enter Expected Participation'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: widget.viewModel.passportsController,
                  decoration: const InputDecoration(
                      labelText: 'Passports',
                      hintText: 'Enter Number of Passports',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: true,
                      fillColor: Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)))),
                  keyboardType: TextInputType.number,
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Enter Passports' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: widget.viewModel.nursesController,
                  decoration: const InputDecoration(
                      labelText: 'Nurses',
                      hintText: 'Enter Number of Nurses',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: true,
                      fillColor: Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)))),
                  keyboardType: TextInputType.number,
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Enter Nurses' : null,
                ),
              ]),

              // Options Section
              sectionWrapper('Options', [
                buildDropdown('Medical Aid', widget.viewModel.medicalAid,
                    ['Yes', 'No'], (val) => widget.viewModel.medicalAid = val),
                const SizedBox(height: 10),
                buildDropdown('Non-Members', widget.viewModel.nonMembers,
                    ['Yes', 'No'], (val) => widget.viewModel.nonMembers = val),
                const SizedBox(height: 10),
                buildDropdown(
                    'Coordinators',
                    widget.viewModel.coordinators,
                    ['Yes', 'No'],
                    (val) => widget.viewModel.coordinators = val),
                const SizedBox(height: 10),
                buildDropdown(
                    'Multiply Promoters',
                    widget.viewModel.multiplyPromoters,
                    ['Yes', 'No'],
                    (val) => widget.viewModel.multiplyPromoters = val),
                const SizedBox(height: 10),
                buildDropdown(
                    'Mobile Booths',
                    widget.viewModel.mobileBooths,
                    ['Yes', 'No'],
                    (val) => widget.viewModel.mobileBooths = val),
                const SizedBox(height: 10),
                buildDropdown(
                    'Services Requested',
                    widget.viewModel.servicesRequested,
                    ['HRA', 'Other'],
                    (val) => widget.viewModel.servicesRequested = val),
              ]),

              // Time Details Section
              sectionWrapper('Time Details', [
                buildTimeField(
                    'Setup Time', widget.viewModel.setUpTimeController),
                const SizedBox(height: 10),
                buildTimeField(
                    'Start Time', widget.viewModel.startTimeController),
                const SizedBox(height: 10),
                buildTimeField('End Time', widget.viewModel.endTimeController),
                const SizedBox(height: 10),
                buildTimeField('Strike Down Time',
                    widget.viewModel.strikeDownTimeController),
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
                          .copyWith(id: eventToEdit!.id);
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
}
