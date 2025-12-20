import 'package:flutter/material.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/shared/ui/logo/app_logo.dart';

class CurrentEventDetailsScreen extends StatelessWidget {
  final WellnessEvent event;
  final Function(String section) onSectionTap;

  const CurrentEventDetailsScreen({
    super.key,
    required this.event,
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
                () => onSectionTap('consent'),
              ),
              _buildSectionCard(
                context,
                'Member Registration',
                Icons.person_add,
                () => onSectionTap('member_registration'),
              ),
              _buildSectionCard(
                context,
                'Health Screenings',
                Icons.medical_services,
                () => onSectionTap('health_screenings'),
              ),
              _buildSectionCard(
                context,
                'Survey',
                Icons.assignment_turned_in,
                () => onSectionTap('survey'),
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
        child: Padding(
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
      ),
    );
  }
}
