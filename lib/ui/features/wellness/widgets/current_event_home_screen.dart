import 'package:flutter/material.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:kenwell_health_app/ui/features/wellness/view_model/wellness_flow_view_model.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/containers/gradient_container.dart';
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
            GradientContainer.purple(
              padding: const EdgeInsets.all(20),
              borderRadius: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon centered at top
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.event,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title centered
                  Text(
                    'Client Organization: ${event.title}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Date row centered
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Date: ${event.date.day}/${event.date.month}/${event.date.year}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  if (event.venue.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.business,
                            size: 16, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          'Venue: ${event.venue}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (viewModel.currentMember != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: KenwellColors.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: KenwellColors.primaryGreen,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: KenwellColors.primaryGreen
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: KenwellColors.primaryGreen,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Current Member',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: KenwellColors.secondaryNavy,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(
                        color: KenwellColors.primaryGreen, height: 1),
                    const SizedBox(height: 12),
                    _buildMemberInfoRow(
                      'Name',
                      '${viewModel.currentMember!.name} ${viewModel.currentMember!.surname}',
                    ),
                    const SizedBox(height: 8),
                    _buildMemberInfoRow(
                      viewModel.currentMember!.idDocumentType == 'ID'
                          ? 'ID Number'
                          : 'Passport Number',
                      viewModel.currentMember!.idDocumentType == 'ID'
                          ? (viewModel.currentMember!.idNumber ?? 'N/A')
                          : (viewModel.currentMember!.passportNumber ?? 'N/A'),
                    ),
                  ],
                ),
              ),
            ],
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

  Widget _buildMemberInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              color: KenwellColors.neutralGrey,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: KenwellColors.secondaryNavy,
              fontSize: 14,
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
      iconColor = const Color(0xFF90C048);
      statusTextColor = const Color(0xFF90C048);
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
