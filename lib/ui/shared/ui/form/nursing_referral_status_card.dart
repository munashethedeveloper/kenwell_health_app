import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/models/nursing_referral_option.dart';
import 'custom_text_field.dart';
import 'kenwell_form_card.dart';

/// Interactive card-based selector for the nursing referral / clinical
/// outcomes section.
///
/// Two option cards are always visible:
/// - 🟢 Healthy  → [NursingReferralOption.patientNotReferred]
/// - 🔴 At Risk  → [NursingReferralOption.referredToStateClinic]
///
/// ## Interaction modes
///
/// | [readOnly] | [isCaution] | Behaviour                                              |
/// |-----------|------------|--------------------------------------------------------|
/// | `false`   | `false`    | Normal interactive mode — nurse selects manually       |
/// | `false`   | `true`     | Caution banner shown — nurse must use their discretion |
/// | `true`    | *any*      | Cards are locked; outcome was auto-determined by the   |
/// |           |            | screening data.  An info label is shown below the cards|
///
/// When [readOnly] is `true` the [onChanged] callback is never invoked and
/// the "reason not referred" text field is hidden (no manual override needed).
class NursingReferralStatusCard extends StatelessWidget {
  final String title;
  final NursingReferralOption? selectedValue;
  final ValueChanged<NursingReferralOption> onChanged;
  final TextEditingController? notReferredReasonController;
  final FormFieldValidator<String>? reasonValidator;

  /// When `true`, a caution status banner is displayed and the nurse is
  /// prompted to use their discretion to select Healthy or At Risk.
  final bool isCaution;

  /// When `true` the outcome has been automatically determined from the
  /// screening data.  Both option cards are non-interactive and a small
  /// "Automatically determined" label is shown below them.
  final bool readOnly;

  const NursingReferralStatusCard({
    super.key,
    required this.title,
    required this.selectedValue,
    required this.onChanged,
    this.notReferredReasonController,
    this.reasonValidator,
    this.isCaution = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return KenwellFormCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Caution banner — only shown when in manual caution mode.
          if (isCaution && !readOnly) ...[
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
            readOnly: readOnly,
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
            readOnly: readOnly,
          ),
          // Auto-determined label — only shown when the card is locked.
          if (readOnly) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.lock_outline,
                    size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  'Automatically determined based on screening data',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
          // Reason field — only shown in manual (non-readOnly) mode when
          // the nurse has selected "Healthy" and a controller is provided.
          if (!readOnly &&
              selectedValue == NursingReferralOption.patientNotReferred &&
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
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber, color: cautionColor, size: 24),
          SizedBox(width: 8),
          Expanded(
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
  final bool readOnly;

  const _OptionCard({
    required this.option,
    required this.activeColor,
    required this.activeBackground,
    required this.icon,
    required this.title,
    required this.message,
    required this.selectedValue,
    required this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedValue == option;
    // In readOnly mode, the unselected card is visually dimmed.
    final bool isDisabledUnselected = readOnly && !isSelected;

    return GestureDetector(
      onTap: readOnly ? null : () => onChanged(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? activeBackground
              : isDisabledUnselected
                  ? Colors.grey.shade100
                  : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? activeColor
                : isDisabledUnselected
                    ? Colors.grey.shade200
                    : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected ? icon : Icons.radio_button_unchecked,
              color: isSelected
                  ? activeColor
                  : isDisabledUnselected
                      ? Colors.grey.shade300
                      : Colors.grey.shade400,
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
                      color: isSelected
                          ? activeColor
                          : isDisabledUnselected
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: isSelected
                          ? activeColor
                          : isDisabledUnselected
                              ? Colors.grey.shade400
                              : Colors.grey.shade500,
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
