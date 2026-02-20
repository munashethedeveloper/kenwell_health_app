import 'package:flutter/material.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:kenwell_health_app/ui/features/wellness/view_model/wellness_flow_view_model.dart';
import 'package:provider/provider.dart';

import '../../../shared/ui/form/kenwell_modern_section_header.dart';

class CurrentEventHomeScreen extends StatelessWidget {
  final WellnessEvent event;
  final Function(String section) onSectionTap;
  final VoidCallback onBackToSearch;

  const CurrentEventHomeScreen({
    super.key,
    required this.event,
    required this.onSectionTap,
    required this.onBackToSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<WellnessFlowViewModel>();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.primaryColor.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with icon and title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.event,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${event.date.day}/${event.date.month}/${event.date.year}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (event.venue.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.business,
                            size: 16, color: Colors.grey[700]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            event.venue,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (viewModel.currentMember != null) ...[
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 20,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Current Member',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildMemberInfoRow(
                      'Name',
                      '${viewModel.currentMember!.name} ${viewModel.currentMember!.surname}',
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _buildMemberInfoRow(
                      viewModel.currentMember!.idDocumentType == 'ID'
                          ? 'ID Number'
                          : 'Passport Number',
                      viewModel.currentMember!.idDocumentType == 'ID'
                          ? (viewModel.currentMember!.idNumber ?? 'N/A')
                          : (viewModel.currentMember!.passportNumber ?? 'N/A'),
                      theme,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            const KenwellModernSectionHeader(
              title: 'Event Process',
              subtitle:
                  'Complete the steps below to finish the wellness event process.',
              icon: Icons.checklist,
            ),
            const SizedBox(height: 24),
            _ProcessStepCard(
              icon: Icons.person_add,
              title: 'Section A: Member Registration',
              status: viewModel.memberRegistrationCompleted
                  ? 'Completed'
                  : 'Not Completed',
              isCompleted: viewModel.memberRegistrationCompleted,
              onTap: () =>
                  onSectionTap(WellnessFlowViewModel.sectionMemberRegistration),
            ),
            _ProcessStepCard(
              icon: Icons.assignment,
              title: 'Section B: Informed Consent',
              status:
                  viewModel.consentCompleted ? 'Completed' : 'Not Completed',
              isCompleted: viewModel.consentCompleted,
              onTap: () => onSectionTap(WellnessFlowViewModel.sectionConsent),
            ),
            _ProcessStepCard(
              icon: Icons.health_and_safety,
              title: 'Section C: Health Screenings',
              status: viewModel.screeningsCompleted
                  ? 'Completed'
                  : viewModel.screeningsInProgress
                      ? 'In Progress'
                      : 'Not Completed',
              isCompleted: viewModel.screeningsCompleted,
              isInProgress: viewModel.screeningsInProgress,
              onTap: () =>
                  onSectionTap(WellnessFlowViewModel.sectionHealthScreenings),
            ),
            _ProcessStepCard(
              icon: Icons.poll,
              title: 'Section D: Survey',
              status: viewModel.surveyCompleted ? 'Completed' : 'Not Completed',
              isCompleted: viewModel.surveyCompleted,
              onTap: () => onSectionTap(WellnessFlowViewModel.sectionSurvey),
            ),
            const SizedBox(height: 24),
            CustomPrimaryButton(
              label: 'Back to Search',
              onPressed: onBackToSearch,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberInfoRow(String label, String value, ThemeData theme) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProcessStepCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String status;
  final bool isCompleted;
  final bool isInProgress;
  final VoidCallback? onTap;

  const _ProcessStepCard({
    required this.icon,
    required this.title,
    required this.status,
    required this.isCompleted,
    this.isInProgress = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color iconContainerColor;
    Color iconColor;
    Color statusTextColor;

    if (isCompleted) {
      iconContainerColor = const Color(0xFF90C048).withValues(alpha: 0.15);
      iconColor = const Color(0xFF201C58);
      statusTextColor = Colors.deepPurple[700]!;
    } else if (isInProgress) {
      iconContainerColor = Colors.orange.withValues(alpha: 0.15);
      iconColor = Colors.orange[700]!;
      statusTextColor = Colors.orange[700]!;
    } else {
      iconContainerColor = Colors.grey.shade200;
      iconColor = Colors.grey[600]!;
      statusTextColor = Colors.grey.shade600;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconContainerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF201C58),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 13,
                          color: statusTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
