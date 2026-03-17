import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';
import '../../../shared/models/nursing_referral_option.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/custom_yes_no_question.dart';
import '../../../shared/ui/form/kenwell_date_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_page.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/form/kenwell_signature_actions.dart';
import '../../../shared/ui/form/nursing_referral_status_card.dart';
import '../../../shared/ui/form/kenwell_yes_no_list.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../view_model/cancer_view_model.dart';

class CancerScreen extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final PreferredSizeWidget? appBar;

  const CancerScreen({super.key, this.onNext, this.onPrevious, this.appBar});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CancerScreeningViewModel>();

    // Auto-refer when any at-risk indicator is present — locked to At Risk.
    if (viewModel.isAtRisk) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (viewModel.nursingReferralSelection == null ||
            viewModel.nursingReferralSelection ==
                NursingReferralOption.patientNotReferred) {
          viewModel.setNursingReferralSelection(
              NursingReferralOption.referredToStateClinic);
        }
      });
    } else if (viewModel.isHealthy) {
      // All relevant exams entered and none abnormal — lock to Healthy.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (viewModel.nursingReferralSelection !=
            NursingReferralOption.patientNotReferred) {
          viewModel.setNursingReferralSelection(
              NursingReferralOption.patientNotReferred);
        }
      });
    }

    return KenwellFormPage(
      title: 'Cancer Screening Form',
      sectionTitle: 'Section C: Cancer Screening',
      sectionLabel: 'CANCER',
      subtitle:
          'Please complete the form below to provide your cancer screening information.',
      formKey: viewModel.formKey,
      appBar: appBar,
      children: [
        const SizedBox(height: 16),

        // 1. Medical History
        KenwellFormCard(
          title: 'Medical History',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KenwellYesNoQuestion<String>(
                question: 'Previous Cancer Diagnosis?',
                value: viewModel.previousCancerDiagnosis,
                onChanged: viewModel.setPreviousCancerDiagnosis,
                yesValue: 'Yes',
                noValue: 'No',
              ),
              KenwellYesNoQuestion<String>(
                question: 'Family History of Cancer?',
                value: viewModel.familyHistoryOfCancer,
                onChanged: viewModel.setFamilyHistoryOfCancer,
                yesValue: 'Yes',
                noValue: 'No',
              ),
              const SizedBox(height: 8),
              // Text(
              //'Chronic Illness?',
              // style: Theme.of(context).textTheme.bodyMedium,
              //),
              // ...viewModel.chronicConditions.keys.map((condition) {
              ////  return CheckboxListTile(
              //   title: Text(condition),
              //   value: viewModel.chronicConditions[condition],
              //   onChanged: (val) => viewModel.toggleCondition(condition, val),
              //   dense: true,
              //   contentPadding: EdgeInsets.zero,
              // );
              //}),
              // if (viewModel.chronicConditions['Other'] == true)
              //   KenwellTextField(
              //    label: 'If Other, please specify condition',
              //    controller: viewModel.otherConditionController,
              //    hintText: 'Specify other condition...',
              //    decoration: KenwellFormStyles.decoration(
              //      label: 'If Other, please specify condition',
              //      hint: 'Specify other condition...',
              //    ),
              //    validator: (val) => val == null || val.isEmpty
              //        ? 'Please specify other condition'
              //        : null,
              //  ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        //2. Chronic Illness Details
        KenwellFormCard(
          title: 'Chronic Illness Details',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'If you have any chronic illness, please provide details below:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              ...viewModel.chronicConditions.keys.map((condition) {
                return CheckboxListTile(
                  title: Text(condition),
                  value: viewModel.chronicConditions[condition],
                  onChanged: (val) => viewModel.toggleCondition(condition, val),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                );
              }),
              if (viewModel.chronicConditions['Other'] == true)
                KenwellTextField(
                  label: 'If Other, please specify condition',
                  controller: viewModel.otherConditionController,
                  hintText: 'Specify other condition...',
                  decoration: KenwellFormStyles.decoration(
                    label: 'If Other, please specify condition',
                    hint: 'Specify other condition...',
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please specify other condition'
                      : null,
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 3. Symptoms
        // Only build the items that are relevant to the consented sub-types.
        // persistent pain is common to all cancer types and is always shown.
        KenwellFormCard(
          title: 'Symptoms',
          child: KenwellYesNoList<String>(
            items: [
              if (viewModel.showBreastScreening)
                KenwellYesNoItem(
                  question: 'Breast lump?',
                  value: viewModel.breastLump,
                  onChanged: viewModel.setBreastLump,
                  yesValue: 'Yes',
                  noValue: 'No',
                ),
              if (viewModel.showPapSmear || viewModel.showPsa)
                KenwellYesNoItem(
                  question: 'Abnormal bleeding?',
                  value: viewModel.abnormalBleeding,
                  onChanged: viewModel.setAbnormalBleeding,
                  yesValue: 'Yes',
                  noValue: 'No',
                ),
              if (viewModel.showPapSmear || viewModel.showPsa)
                KenwellYesNoItem(
                  question: 'Urinary difficulty?',
                  value: viewModel.urinaryDifficulty,
                  onChanged: viewModel.setUrinaryDifficulty,
                  yesValue: 'Yes',
                  noValue: 'No',
                ),
              if (viewModel.showPapSmear || viewModel.showPsa)
                KenwellYesNoItem(
                  question: 'Weight loss?',
                  value: viewModel.weightLoss,
                  onChanged: viewModel.setWeightLoss,
                  yesValue: 'Yes',
                  noValue: 'No',
                ),
              KenwellYesNoItem(
                question: 'Persistent pain?',
                value: viewModel.persistentPain,
                onChanged: viewModel.setPersistentPain,
                yesValue: 'Yes',
                noValue: 'No',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 4. Breast Light Exam — only for Breast Screening
        if (viewModel.showBreastScreening) ...[
          KenwellFormCard(
            title: 'Breast Light Exam',
            child: KenwellDropdownField<String>(
              label: 'Findings',
              value: viewModel.breastLightExamFindings,
              items: const ['Normal', 'Abnormal'],
              onChanged: viewModel.setBreastLightExamFindings,
              decoration: KenwellFormStyles.decoration(
                label: 'Findings',
                hint: 'Select findings',
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // 5. Liquid Cytology / Pap Smear — only for Pap Smear
        if (viewModel.showPapSmear) ...[
          KenwellFormCard(
            title: 'Liquid Cytology / Pap Smear',
            child: Column(
              children: [
                KenwellYesNoQuestion<String>(
                  question: 'Specimen sample collected?',
                  value: viewModel.papSmearSpecimenCollected,
                  onChanged: viewModel.setPapSmearSpecimenCollected,
                  yesValue: 'Yes',
                  noValue: 'No',
                ),
                KenwellDropdownField<String>(
                  label: 'Results',
                  value: viewModel.papSmearResults,
                  items: const ['Normal', 'Abnormal', 'Pending'],
                  onChanged: viewModel.setPapSmearResults,
                  decoration: KenwellFormStyles.decoration(
                    label: 'Results',
                    hint: 'Select results',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // 6. PSA — only for PSA screening
        if (viewModel.showPsa) ...[
          KenwellFormCard(
            title: 'PSA',
            child: KenwellDropdownField<String>(
              label: 'Results',
              value: viewModel.psaResults,
              items: const ['Normal', 'Abnormal'],
              onChanged: viewModel.setPsaResults,
              decoration: KenwellFormStyles.decoration(
                label: 'Results',
                hint: 'Select results',
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // 7. Nursing Referral — always shown.
        // Locked to At Risk when any symptom/finding is abnormal,
        // locked to Healthy when all relevant exams are normal,
        // and interactive only when some exams are still pending.
        NursingReferralStatusCard(
          title: 'Nursing Referrals',
          selectedValue: viewModel.nursingReferralSelection,
          onChanged: viewModel.setNursingReferralSelection,
          notReferredReasonController: viewModel.notReferredReasonController,
          readOnly: viewModel.isAtRisk || viewModel.isHealthy,
          reasonValidator: (val) =>
              (val == null || val.isEmpty) ? 'Please enter a reason' : null,
        ),
        const SizedBox(height: 24),

        // 9. Nurse / healthcare-practitioner details
        KenwellFormCard(
          title: 'Nurse Details',
          child: Column(
            children: [
              KenwellTextField(
                label: 'Nurse First Name',
                hintText: 'Auto-filled from profile',
                enabled: false,
                readOnly: true,
                controller: viewModel.nurseFirstNameController,
                decoration: KenwellFormStyles.decoration(
                  label: 'Nurse First Name',
                  hint: 'Auto-filled from profile',
                ),
                inputFormatters:
                    AppTextInputFormatters.lettersOnly(allowHyphen: true),
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Please enter Nurse First Name'
                    : null,
              ),
              KenwellTextField(
                label: 'Nurse Last Name',
                hintText: 'Auto-filled from profile',
                enabled: false,
                readOnly: true,
                controller: viewModel.nurseLastNameController,
                decoration: KenwellFormStyles.decoration(
                  label: 'Nurse Last Name',
                  hint: 'Auto-filled from profile',
                ),
                inputFormatters:
                    AppTextInputFormatters.lettersOnly(allowHyphen: true),
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Please enter Nurse Last Name'
                    : null,
              ),
              KenwellTextField(
                label: 'Rank',
                hintText: 'Enter nurse rank',
                controller: viewModel.rankController,
                decoration: KenwellFormStyles.decoration(
                  label: 'Rank',
                  hint: 'Enter nurse rank',
                ),
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Please enter Rank'
                    : null,
              ),
              KenwellTextField(
                label: 'SANC No',
                hintText: 'Enter SANC number',
                controller: viewModel.sancNumberController,
                decoration: KenwellFormStyles.decoration(
                  label: 'SANC No',
                  hint: 'Enter SANC number',
                ),
                inputFormatters: AppTextInputFormatters.numbersOnly(),
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Please enter SANC No'
                    : null,
              ),
              KenwellDateField(
                label: 'Date',
                controller: viewModel.nurseDateController,
                readOnly: true,
                enabled: false,
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Please select Date' : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 10. Signature + navigation
        KenwellSignatureActions(
          title: 'Signature',
          controller: viewModel.signatureController,
          onClear: viewModel.clearSignature,
          navigation: KenwellFormNavigation(
            onPrevious: onPrevious,
            onNext: () => viewModel.submitCancerScreening(
              onNext: onNext,
              onValidationFailed: (msg) =>
                  AppSnackbar.showWarning(context, msg),
              onSuccess: (msg) => AppSnackbar.showSuccess(context, msg),
              onError: (msg) => AppSnackbar.showError(context, msg),
            ),
            isNextEnabled: !viewModel.isSubmitting,
            isNextBusy: viewModel.isSubmitting,
          ),
        ),
      ],
    );
  }
}
