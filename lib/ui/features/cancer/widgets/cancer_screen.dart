import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/nursing_referral_option.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/custom_yes_no_question.dart';
import '../../../shared/ui/form/kenwell_date_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_page.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/form/kenwell_referral_card.dart';
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

    // Auto-refer when any at-risk indicator is present
    if (viewModel.isAtRisk) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (viewModel.nursingReferralSelection == null ||
            viewModel.nursingReferralSelection ==
                NursingReferralOption.patientNotReferred) {
          viewModel.setNursingReferralSelection(
              NursingReferralOption.referredToStateClinic);
        }
      });
    }

    return KenwellFormPage(
      title: 'Cancer Screening Form',
      sectionTitle: 'Section C: Cancer Screening',
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

        // 7. Nursing Referrals Card — only shown when patient is at risk
        if (viewModel.isAtRisk) ...[
          KenwellReferralCard<NursingReferralOption>(
            title: 'Nursing Referrals',
            selectedValue: viewModel.nursingReferralSelection,
            onChanged: viewModel.setNursingReferralSelection,
            reasonValidator: (val) =>
                (val == null || val.isEmpty) ? 'Please enter a reason' : null,
            options: [
              KenwellReferralOption(
                value: NursingReferralOption.patientNotReferred,
                label: 'Patient not referred',
                requiresReason: true,
                reasonController: viewModel.notReferredReasonController,
                reasonLabel: 'Reason patient not referred',
              ),
              const KenwellReferralOption(
                value: NursingReferralOption.referredToGP,
                label: 'Patient referred to GP',
              ),
              const KenwellReferralOption(
                value: NursingReferralOption.referredToStateClinic,
                label: 'Patient referred to State Clinic',
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],

        // 8. Outcome & Referral
        KenwellFormCard(
          title: 'Outcome & Referral',
          child: Column(
            children: [
              KenwellTextField(
                label: 'Referred Facility',
                hintText: 'Enter referred facility',
                controller: viewModel.referredFacilityController,
              ),
              KenwellDateField(
                label: 'Follow-up Date',
                controller: viewModel.followUpDateController,
                hint: 'Select follow-up date',
                validator: (_) => null,
              ),
              KenwellTextField(
                label: 'Consent Obtained',
                hintText: 'Enter consent details',
                controller: viewModel.consentObtainedController,
              ),
              KenwellTextField(
                label: 'Clinician Name',
                hintText: 'Enter clinician name',
                controller: viewModel.clinicianNameController,
              ),
              KenwellTextField(
                label: 'Clinician Signature',
                hintText: 'Enter clinician signature',
                controller: viewModel.clinicianSignatureController,
              ),
              KenwellTextField(
                label: 'Clinician Notes',
                hintText: 'Enter clinician notes',
                controller: viewModel.clinicianNotesController,
                maxLines: 3,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 8. Nursing Referral — show only when at risk or undetermined;
        //    hide when all findings are healthy
        if (viewModel.isAtRisk || !viewModel.isHealthy) ...[
          KenwellReferralCard<NursingReferralOption>(
            title: 'Nursing Referrals',
            selectedValue: viewModel.nursingReferralSelection,
            onChanged: viewModel.setNursingReferralSelection,
            reasonValidator: (val) =>
                (val == null || val.isEmpty) ? 'Please enter a reason' : null,
            options: [
              KenwellReferralOption(
                value: NursingReferralOption.patientNotReferred,
                label: 'Patient not referred',
                requiresReason: true,
                reasonController: viewModel.notReferredReasonController,
                reasonLabel: 'Reason patient not referred',
              ),
              const KenwellReferralOption(
                value: NursingReferralOption.referredToGP,
                label: 'Patient referred to GP',
              ),
              const KenwellReferralOption(
                value: NursingReferralOption.referredToStateClinic,
                label: 'Patient referred to State Clinic',
              ),
            ],
          ),
          const SizedBox(height: 24),
        ] else ...[
          _buildCancerHealthyBanner(),
          const SizedBox(height: 24),
        ],

        // Navigation
        KenwellFormNavigation(
          onPrevious: onPrevious,
          onNext: () =>
              viewModel.submitCancerScreening(context, onNext: onNext),
          isNextEnabled: !viewModel.isSubmitting,
          isNextBusy: viewModel.isSubmitting,
        ),
      ],
    );
  }

  Widget _buildCancerHealthyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2E7D32), width: 1),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'All cancer screening findings are normal. '
              'No nursing referral is required.',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
