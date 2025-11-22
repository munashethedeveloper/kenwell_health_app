import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';

import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/buttons/custom_primary_button.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_date_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
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
            title: 'Stats & Report',
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: vm.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const KenwellSectionHeader(
                    title: 'Capture Event Stats',
                    subtitle: 'Log the core numbers before generating reports.',
                  ),
                  KenwellFormCard(
                    title: 'Event Details',
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: vm.eventTitleController,
                          label: 'Event Title',
                          validator: (val) => (val == null || val.isEmpty)
                              ? 'Enter event title'
                              : null,
                        ),
                        KenwellFormStyles.fieldSpacing,
                        KenwellDateField(
                          label: 'Event Date',
                          controller: vm.eventDateController,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          onDateSelected: vm.setEventDate,
                          validator: (val) => (val == null || val.isEmpty)
                              ? 'Select event date'
                              : null,
                        ),
                        KenwellFormStyles.fieldSpacing,
                        _buildTimeField(
                          context: context,
                          controller: vm.startTimeController,
                          label: 'Start Time',
                          vm: vm,
                        ),
                        KenwellFormStyles.fieldSpacing,
                        _buildTimeField(
                          context: context,
                          controller: vm.endTimeController,
                          label: 'End Time',
                          vm: vm,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  KenwellFormCard(
                    title: 'Attendance & Throughput',
                    child: Column(
                      children: [
                        _buildNumberField(
                          controller: vm.expectedParticipationController,
                          label: 'Expected Participation',
                        ),
                        KenwellFormStyles.fieldSpacing,
                        _buildNumberField(
                          controller: vm.registeredController,
                          label: 'Registered',
                        ),
                        KenwellFormStyles.fieldSpacing,
                        _buildNumberField(
                          controller: vm.screenedController,
                          label: 'Screened',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomPrimaryButton(
                    label: 'Generate Report',
                    isBusy: vm.isLoading,
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                            if (!(vm.formKey.currentState?.validate() ?? false)) {
                              return;
                            }
                            final success = await vm.generateReport();
                            if (!context.mounted) return;
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? 'Report generated successfully.'
                                    : 'Could not generate report, please try again.'),
                              ),
                            );
                          },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static KenwellTextField _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return KenwellTextField(
      label: label,
      controller: controller,
      hintText: hint ?? 'Enter $label',
      decoration: KenwellFormStyles.decoration(label: label, hint: hint),
      validator: validator,
    );
  }

  static KenwellTextField _buildNumberField({
    required TextEditingController controller,
    required String label,
  }) {
    return KenwellTextField(
      label: label,
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: AppTextInputFormatters.numbersOnly(),
      decoration: KenwellFormStyles.decoration(label: label),
      validator: (val) =>
          (val == null || val.isEmpty) ? 'Enter $label' : null,
    );
  }

  static KenwellTextField _buildTimeField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required StatsReportViewModel vm,
  }) {
    return KenwellTextField(
      label: label,
      controller: controller,
      readOnly: true,
      decoration: KenwellFormStyles.decoration(
        label: label,
        hint: 'Select $label',
        suffixIcon: const Icon(Icons.access_time),
      ),
      onTap: () => vm.pickTime(context, controller),
    );
  }
}
