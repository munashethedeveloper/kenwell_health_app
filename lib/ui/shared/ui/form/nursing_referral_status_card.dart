import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/models/nursing_referral_option.dart';
import 'custom_text_field.dart';
import 'kenwell_form_card.dart';

/// Interactive card-based selector for the nursing referral / clinical
/// outcomes section.
///
/// Two selectable option cards are always visible:
/// - 🟢 Healthy  → [NursingReferralOption.patientNotReferred]
/// - 🔴 At Risk  → [NursingReferralOption.referredToStateClinic]
///
/// When [isCaution] is `true` a non-interactive orange caution banner is shown
/// above the option cards, informing the nurse that they must use their
/// clinical discretion to classify the patient as either Healthy or At Risk.
class NursingReferralStatusCard extends StatelessWidget {
  final String title;
  final NursingReferralOption? selectedValue;
  final ValueChanged<NursingReferralOption> onChanged;
  final TextEditingController? notReferredReasonController;
  final FormFieldValidator<String>? reasonValidator;

  /// When `true`, a caution status banner is displayed and the nurse is
  /// prompted to use their discretion to select Healthy or At Risk.
  final bool isCaution;

  const NursingReferralStatusCard({
    super.key,
    required this.title,
    required this.selectedValue,
    required this.onChanged,
    this.notReferredReasonController,
    this.reasonValidator,
    this.isCaution = false,
  });

  @override
  Widget build(BuildContext context) {
    return KenwellFormCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCaution) ...[
            const _CautionBanner(),
            const SizedBox(height: 12),
          ],
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

/// Non-interactive banner displayed when the patient's status is caution.
class _CautionBanner extends StatelessWidget {
  const _CautionBanner();
  @override
  Widget build(BuildContext context) {
    const cautionColor = Color(0xFFF57C00);
    const cautionBackground = Color(0xFFFFF3E0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cautionBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cautionColor, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber, color: cautionColor, size: 24),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Caution',
                  style: TextStyle(
                    color: cautionColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Patient health metrics indicate caution status.',
                  style: TextStyle(
                    color: cautionColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Please use your clinical discretion to determine whether the patient is Healthy or At Risk.',
                  style: TextStyle(
                    color: cautionColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
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
