import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/models/nursing_referral_option.dart';
import 'custom_text_field.dart';
import 'kenwell_form_card.dart';

/// Interactive card-based selector that replaces radio buttons for the
/// nursing referral / clinical outcomes section.
///
/// All three option cards are always visible. Tapping one selects it:
/// - Selected card: fully coloured background and border
/// - Unselected cards: white background with a light grey border
///
/// Options:
/// - 🟢 Healthy       → [NursingReferralOption.patientNotReferred]
/// - 🟠 Caution       → [NursingReferralOption.referredToGP]
/// - 🔴 At Risk       → [NursingReferralOption.referredToStateClinic]
class NursingReferralStatusCard extends StatelessWidget {
  final String title;
  final NursingReferralOption? selectedValue;
  final ValueChanged<NursingReferralOption> onChanged;
  final TextEditingController? notReferredReasonController;
  final FormFieldValidator<String>? reasonValidator;

  const NursingReferralStatusCard({
    super.key,
    required this.title,
    required this.selectedValue,
    required this.onChanged,
    this.notReferredReasonController,
    this.reasonValidator,
  });

  @override
  Widget build(BuildContext context) {
    return KenwellFormCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OptionCard(
            option: NursingReferralOption.patientNotReferred,
            activeColor: const Color(0xFF2E7D32),
            activeBackground: const Color(0xFFE8F5E9),
            icon: Icons.check_circle,
            title: 'Healthy',
            message: 'Patient not referred',
            selectedValue: selectedValue,
            onChanged: onChanged,
          ),
          const SizedBox(height: 8),
          _OptionCard(
            option: NursingReferralOption.referredToGP,
            activeColor: const Color(0xFFF57C00),
            activeBackground: const Color(0xFFFFF3E0),
            icon: Icons.warning_amber,
            title: 'Caution',
            message: 'Patient referred to GP',
            selectedValue: selectedValue,
            onChanged: onChanged,
          ),
          const SizedBox(height: 8),
          _OptionCard(
            option: NursingReferralOption.referredToStateClinic,
            activeColor: const Color(0xFFB3261E),
            activeBackground: const Color(0xFFFCDAD6),
            icon: Icons.dangerous,
            title: 'At Risk',
            message: 'Patient referred to State clinic',
            selectedValue: selectedValue,
            onChanged: onChanged,
          ),
          if (selectedValue == NursingReferralOption.patientNotReferred &&
              notReferredReasonController != null) ...[
            const SizedBox(height: 12),
            KenwellTextField(
              label: 'Reason patient not referred',
              controller: notReferredReasonController!,
              maxLines: 2,
              validator: reasonValidator,
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final NursingReferralOption option;
  final Color activeColor;
  final Color activeBackground;
  final IconData icon;
  final String title;
  final String message;
  final NursingReferralOption? selectedValue;
  final ValueChanged<NursingReferralOption> onChanged;

  const _OptionCard({
    required this.option,
    required this.activeColor,
    required this.activeBackground,
    required this.icon,
    required this.title,
    required this.message,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedValue == option;

    return GestureDetector(
      onTap: () => onChanged(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? activeBackground : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected ? icon : Icons.radio_button_unchecked,
              color: isSelected ? activeColor : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? activeColor : Colors.grey.shade600,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: isSelected ? activeColor : Colors.grey.shade500,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
