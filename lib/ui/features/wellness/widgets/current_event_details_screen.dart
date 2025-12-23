import 'package:flutter/material.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/shared/ui/logo/app_logo.dart';
import 'package:kenwell_health_app/ui/features/wellness/view_model/wellness_flow_view_model.dart';

class CurrentEventDetailsScreen extends StatelessWidget {
  final WellnessEvent event;
  final WellnessFlowViewModel flowViewModel;
  final Function(String section) onSectionTap;

  const CurrentEventDetailsScreen({
    super.key,
    required this.event,
    required this.flowViewModel,
    required this.onSectionTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          const AppLogo(size: 200),
          const SizedBox(height: 32),
          // Display section cards in 2x2 grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildSectionCard(
                context,
                'Consent',
                Icons.assignment,
                flowViewModel.consentCompleted,
                () => onSectionTap(WellnessFlowViewModel.sectionConsent),
              ),
              _buildSectionCard(
                context,
                'Member Registration',
                Icons.person_add,
                flowViewModel.memberRegistrationCompleted,
                () => onSectionTap(
                    WellnessFlowViewModel.sectionMemberRegistration),
              ),
              _buildSectionCard(
                context,
                'Health Screenings',
                Icons.medical_services,
                flowViewModel.screeningsCompleted,
                () =>
                    onSectionTap(WellnessFlowViewModel.sectionHealthScreenings),
              ),
              _buildSectionCard(
                context,
                'Survey',
                Icons.assignment_turned_in,
                flowViewModel.surveyCompleted,
                () => onSectionTap(WellnessFlowViewModel.sectionSurvey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    bool isCompleted,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 3,
      shadowColor: Colors.grey.shade300,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: const Color(0xFF201C58),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF201C58),
                    ),
                  ),
                ],
              ),
            ),
            // Completion indicator
            if (isCompleted)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
