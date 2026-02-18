import 'package:flutter/material.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:kenwell_health_app/ui/shared/ui/containers/gradient_container.dart';
import 'package:kenwell_health_app/ui/features/wellness/view_model/wellness_flow_view_model.dart';
import 'package:provider/provider.dart';

import '../../../shared/ui/form/kenwell_modern_section_header.dart';
// Removed unused import

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
            GradientContainer.purpleGreen(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.venue,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (viewModel.currentMember != null) ...[
                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Current Member',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
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
    final theme = Theme.of(context);

    // Determine color based on state
    Color backgroundColor;
    Color iconColor;
    Color statusBackgroundColor;
    Color statusTextColor;

    if (isCompleted) {
      backgroundColor = theme.primaryColor.withValues(alpha: 0.1);
      iconColor = theme.primaryColor;
      statusBackgroundColor = Colors.deepPurple.withValues(alpha: 0.1);
      statusTextColor = Colors.deepPurple[700]!;
    } else if (isInProgress) {
      backgroundColor = Colors.orange.withValues(alpha: 0.1);
      iconColor = Colors.orange[700]!;
      statusBackgroundColor = Colors.orange.withValues(alpha: 0.1);
      statusTextColor = Colors.orange[700]!;
    } else {
      backgroundColor = Colors.grey[200]!;
      iconColor = Colors.grey[600]!;
      statusBackgroundColor = Colors.grey.withValues(alpha: 0.1);
      statusTextColor = Colors.grey[700]!;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
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
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusBackgroundColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[600],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
