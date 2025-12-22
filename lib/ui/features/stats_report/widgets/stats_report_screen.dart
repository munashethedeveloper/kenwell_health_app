import 'package:flutter/material.dart';
import 'package:kenwell_health_app/routing/route_names.dart';
import 'package:kenwell_health_app/ui/shared/ui/logo/app_logo.dart';
import 'package:provider/provider.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';

import '../../auth/view_models/auth_view_model.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/buttons/custom_primary_button.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_date_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
import '../view_model/stats_report_view_model.dart';
import '../../auth/widgets/login_screen.dart';

class StatsReportScreen extends StatefulWidget {
  const StatsReportScreen({super.key});

  @override
  State<StatsReportScreen> createState() => _StatsReportScreenState();
}

class _StatsReportScreenState extends State<StatsReportScreen> {
  Future<void> _logout() async {
    final authVM = context.read<AuthViewModel>();
    await authVM.logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StatsReportViewModel(),
      child: Consumer<StatsReportViewModel>(
        builder: (context, vm, _) => Scaffold(
          appBar: KenwellAppBar(
            title: 'Stats & Report',
            automaticallyImplyLeading: false,
            actions: [
              PopupMenuButton<int>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) async {
                  switch (value) {
                    case 0: // Profile
                      if (mounted) {
                        Navigator.pushNamed(context, RouteNames.profile);
                      }
                      break;
                    case 1: // Help
                      if (mounted) {
                        Navigator.pushNamed(context, RouteNames.help);
                      }
                      break;
                    case 2: // Logout
                      await _logout();
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<int>(
                    value: 0,
                    child: ListTile(
                      leading: Icon(Icons.person, color: Colors.black),
                      title: Text('Profile'),
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: ListTile(
                      leading: Icon(Icons.help_outline, color: Colors.black),
                      title: Text('Help'),
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 2,
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.black),
                      title: Text('Logout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: vm.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const AppLogo(size: 200),
                  const SizedBox(height: 16),
                  const KenwellSectionHeader(
                    title: 'Capture Event Stats',
                    subtitle: 'Log the core numbers before generating reports.',
                  ),
                  KenwellFormCard(
                    title: 'Event Details',
                    child: Column(
                      children: [
                        KenwellTextField(
                          label: 'Event Title',
                          controller: vm.eventTitleController,
                          padding: EdgeInsets.zero,
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
                        KenwellTextField(
                          label: 'Start Time',
                          controller: vm.startTimeController,
                          readOnly: true,
                          padding: EdgeInsets.zero,
                          suffixIcon: const Icon(Icons.access_time),
                          validator: (val) => (val == null || val.isEmpty)
                              ? 'Select Start Time'
                              : null,
                          onTap: () =>
                              vm.pickTime(context, vm.startTimeController),
                        ),
                        KenwellFormStyles.fieldSpacing,
                        KenwellTextField(
                          label: 'End Time',
                          controller: vm.endTimeController,
                          readOnly: true,
                          padding: EdgeInsets.zero,
                          suffixIcon: const Icon(Icons.access_time),
                          validator: (val) => (val == null || val.isEmpty)
                              ? 'Select End Time'
                              : null,
                          onTap: () =>
                              vm.pickTime(context, vm.endTimeController),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  KenwellFormCard(
                    title: 'Attendance & Throughput',
                    child: Column(
                      children: [
                        KenwellTextField(
                          label: 'Expected Participation',
                          controller: vm.expectedParticipationController,
                          keyboardType: TextInputType.number,
                          inputFormatters: AppTextInputFormatters.numbersOnly(),
                          padding: EdgeInsets.zero,
                          validator: (val) => (val == null || val.isEmpty)
                              ? 'Enter Expected Participation'
                              : null,
                        ),
                        KenwellFormStyles.fieldSpacing,
                        KenwellTextField(
                          label: 'Registered',
                          controller: vm.registeredController,
                          keyboardType: TextInputType.number,
                          inputFormatters: AppTextInputFormatters.numbersOnly(),
                          padding: EdgeInsets.zero,
                          validator: (val) => (val == null || val.isEmpty)
                              ? 'Enter Registered'
                              : null,
                        ),
                        KenwellFormStyles.fieldSpacing,
                        KenwellTextField(
                          label: 'Screened',
                          controller: vm.screenedController,
                          keyboardType: TextInputType.number,
                          inputFormatters: AppTextInputFormatters.numbersOnly(),
                          padding: EdgeInsets.zero,
                          validator: (val) => (val == null || val.isEmpty)
                              ? 'Enter Screened'
                              : null,
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
                            if (!(vm.formKey.currentState?.validate() ??
                                false)) {
                              return;
                            }
                            final success = await vm.generateReport();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Report generated successfully.'
                                      : 'Could not generate report, please try again.',
                                ),
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
}
