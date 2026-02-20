import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/custom_yes_no_question.dart';
import '../../../shared/ui/form/kenwell_date_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_page.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
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

    return KenwellFormPage(
      title: 'Cancer Screening Form',
      sectionTitle: 'Cancer Screening',
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
              Text(
                'Chronic Illness?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              ...viewModel.chronicConditions.keys.map((condition) {
                return CheckboxListTile(
                  title: Text(condition),
                  value: viewModel.chronicConditions[condition],
                  onChanged: (val) =>
                      viewModel.toggleCondition(condition, val),
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

        // 2. Symptoms
        KenwellFormCard(
          title: 'Symptoms',
          child: KenwellYesNoList<String>(
            items: [
              KenwellYesNoItem(
                question: 'Breast lump?',
                value: viewModel.breastLump,
                onChanged: viewModel.setBreastLump,
                yesValue: 'Yes',
                noValue: 'No',
              ),
              KenwellYesNoItem(
                question: 'Abnormal bleeding?',
                value: viewModel.abnormalBleeding,
                onChanged: viewModel.setAbnormalBleeding,
                yesValue: 'Yes',
                noValue: 'No',
              ),
              KenwellYesNoItem(
                question: 'Urinary difficulty?',
                value: viewModel.urinaryDifficulty,
                onChanged: viewModel.setUrinaryDifficulty,
                yesValue: 'Yes',
                noValue: 'No',
              ),
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

        // 3. Breast Light Exam
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

        // 4. Liquid Cytology / Pap Smear
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

        // 5. PSA
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

        // 6. Outcome & Referral
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
}
