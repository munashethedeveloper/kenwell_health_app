import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../view_model/stats_report_view_model.dart';

class StatsReportScreen extends StatelessWidget {
  const StatsReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StatsReportViewModel(),
      child: Consumer<StatsReportViewModel>(
        builder: (context, vm, _) => Scaffold(
          appBar: const KenwellAppBar(
              title: 'Stats & Report', automaticallyImplyLeading: false),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Event Title
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Event Title'),
                  onChanged: (val) => vm.eventTitle = val,
                ),
                const SizedBox(height: 10),

                // Event Date Picker
                InkWell(
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: vm.eventDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (selectedDate != null) vm.setEventDate(selectedDate);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Event Date'),
                    child: Text(
                      vm.eventDate != null
                          ? DateFormat.yMMMd().format(vm.eventDate!)
                          : 'Select date',
                      style: TextStyle(
                        color: vm.eventDate != null
                            ? Colors.black
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Start Time
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Start Time'),
                  onChanged: (val) => vm.startTime = val,
                ),
                const SizedBox(height: 10),

                // End Time
                TextFormField(
                  decoration: const InputDecoration(labelText: 'End Time'),
                  onChanged: (val) => vm.endTime = val,
                ),
                const SizedBox(height: 10),

                // Expected Participation
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Expected Participation'),
                  keyboardType: TextInputType.number,
                  inputFormatters: AppTextInputFormatters.numbersOnly(),
                  onChanged: (val) =>
                      vm.expectedParticipation = int.tryParse(val) ?? 0,
                ),
                const SizedBox(height: 10),

                // Registered
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Registered'),
                  keyboardType: TextInputType.number,
                  inputFormatters: AppTextInputFormatters.numbersOnly(),
                  onChanged: (val) => vm.registered = int.tryParse(val) ?? 0,
                ),
                const SizedBox(height: 10),

                // Screened
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Screened'),
                  keyboardType: TextInputType.number,
                  inputFormatters: AppTextInputFormatters.numbersOnly(),
                  onChanged: (val) => vm.screened = int.tryParse(val) ?? 0,
                ),
                const SizedBox(height: 30),

                // Save / Generate Button
                vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: vm.generateReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF201C58),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text('Generate Report'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
