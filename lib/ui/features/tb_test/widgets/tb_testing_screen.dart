import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/kenwell_referral_card.dart';
import 'package:kenwell_health_app/ui/shared/models/nursing_referral_option.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_page.dart';
import '../../../shared/ui/form/kenwell_date_field.dart';
import '../../../shared/ui/form/kenwell_signature_actions.dart';
import '../../../shared/ui/form/kenwell_yes_no_list.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../view_model/tb_testing_view_model.dart';

class TBTestingScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const TBTestingScreen({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TBTestingViewModel>();

    return KenwellFormPage(
      title: 'TB Test Screening Form',
      sectionTitle: 'Section I: TB Screening',
      children: [
        KenwellFormCard(
          title: 'TB Symptom Screening',
          child: KenwellYesNoList<String>(
            items: [
              KenwellYesNoItem(
                question: 'Have you been coughing for two weeks or more?',
                value: viewModel.coughTwoWeeks,
                onChanged: viewModel.setCoughTwoWeeks,
                yesValue: 'Yes',
                noValue: 'No',
              ),
              //   KenwellYesNoItem(
              //       question: 'Is your sputum coloured when coughing?',
              //      value: viewModel.sputumColour,
              //      onChanged: viewModel.setSputumColour,
              //      yesValue: 'Yes',
              //     noValue: 'No',
              //    ),
              KenwellYesNoItem(
                question: 'Is there blood in your sputum when you cough?',
                value: viewModel.bloodInSputum,
                onChanged: viewModel.setBloodInSputum,
                yesValue: 'Yes',
                noValue: 'No',
              ),
              KenwellYesNoItem(
                question: 'Have you lost more than 3kg in the past 4 weeks?',
                value: viewModel.weightLoss,
                onChanged: viewModel.setWeightLoss,
                yesValue: 'Yes',
                noValue: 'No',
              ),
              KenwellYesNoItem(
                question: 'Are you sweating unusually at night?',
                value: viewModel.nightSweats,
                onChanged: viewModel.setNightSweats,
                yesValue: 'Yes',
                noValue: 'No',
              ),
              // KenwellYesNoItem(
              //    question:
              //        'Have you had recurrent fever/chills lasting more than three days?',
              //     value: viewModel.feverChills,
              //     onChanged: viewModel.setFeverChills,
              //     yesValue: 'Yes',
              //    noValue: 'No',
              //   ),
              //     KenwellYesNoItem(
              //      question:
              //            'Have you experienced chest pains or difficulty breathing?',
              //       value: viewModel.chestPain,
              //       onChanged: viewModel.setChestPain,
              //       yesValue: 'Yes',
              //       noValue: 'No',
              //     ),
              // KenwellYesNoItem(
              //   question: 'Do you have swellings in the neck or armpits?',
              //   value: viewModel.swellings,
              //   onChanged: viewModel.setSwellings,
              //   yesValue: 'Yes',
              //   noValue: 'No',
              //  ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        KenwellFormCard(
          title: 'History of TB Treatment',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KenwellYesNoList<String>(
                items: [
                  KenwellYesNoItem(
                    question: 'Were you ever treated for Tuberculosis?',
                    value: viewModel.treatedBefore,
                    onChanged: viewModel.setTreatedBefore,
                    yesValue: 'Yes',
                    noValue: 'No',
                  ),
                ],
              ),
              if (viewModel.treatedBefore == 'Yes') ...[
                const SizedBox(height: 12),
                KenwellYesNoList<String>(
                  items: [
                    KenwellYesNoItem(
                      question: 'Did you complete the treatment?',
                      value: viewModel.completedTreatment,
                      onChanged: viewModel.setCompletedTreatment,
                      yesValue: 'Yes',
                      noValue: 'No',
                    ),
                    //    KenwellYesNoItem(
                    //      question:
                    //          'Were you in contact with someone diagnosed with Tuberculosis in the past year?',
                    //      value: viewModel.contactWithTB,
                    //      onChanged: viewModel.setContactWithTB,
                    //      yesValue: 'Yes',
                    //      noValue: 'No',
                    //    ),
                  ],
                ),
              ],
              if (viewModel.treatedBefore == 'Yes')
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: KenwellDateField(
                    label: 'When were you treated?',
                    controller: viewModel.treatedDateController,
                    hint: 'Select treatment date',
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildReferrals(viewModel),
        // const SizedBox(height: 24),
        // _buildNurseDetails(viewModel),
        const SizedBox(height: 24),
        KenwellSignatureActions(
          title: 'Signature',
          controller: viewModel.signatureController,
          onClear: viewModel.clearSignature,
          navigation: KenwellFormNavigation(
            onPrevious: onPrevious,
            onNext: () => viewModel.submitTBTest(context, onNext: onNext),
            isNextEnabled: viewModel.isFormValid && !viewModel.isSubmitting,
            isNextBusy: viewModel.isSubmitting,
          ),
        ),
      ],
    );
  }

  Widget _buildReferrals(TBTestingViewModel viewModel) {
    return KenwellReferralCard<NursingReferralOption>(
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
          label: 'Patient referred to State HIV clinic',
        ),
      ],
    );
  }

  //Widget _buildNurseDetails(TBTestingViewModel viewModel) {
  //   return KenwellFormCard(
  //    title: 'Nurse Details',
  //   child: Column(
  //     children: [
  //      KenwellTextField(
  //   label: 'Nurse First Name',
  //    hintText: 'Enter nurse first name',
  //    controller: viewModel.nurseFirstNameController,
  //    inputFormatters:
  //        AppTextInputFormatters.lettersOnly(allowHyphen: true),
  //     validator: (val) => (val == null || val.isEmpty)
  //         ? 'Please enter Nurse First Name'
  //         : null,
  //   ),
  //    KenwellTextField(
  //      label: 'Nurse Last Name',
  //      hintText: 'Enter nurse last name',
  //      controller: viewModel.nurseLastNameController,
  //      inputFormatters:
  //          AppTextInputFormatters.lettersOnly(allowHyphen: true),
  //      validator: (val) => (val == null || val.isEmpty)
  //          ? 'Please enter Nurse Last Name'
  //          : null,
  //    ),
  //     KenwellTextField(
  //       label: 'Rank',
  //      hintText: 'Enter nurse rank',
  //       controller: viewModel.rankController,
  //       validator: (val) =>
  //           (val == null || val.isEmpty) ? 'Please enter Rank' : null,
  //     ),
  //    KenwellTextField(
  //      label: 'SANC No',
  //      hintText: 'Enter SANC number',
  //      controller: viewModel.sancNumberController,
  //      inputFormatters: AppTextInputFormatters.numbersOnly(),
  //      validator: (val) =>
  //          (val == null || val.isEmpty) ? 'Please enter SANC No' : null,
  //    ),
  //    KenwellDateField(
  //      label: 'Date',
  //      controller: viewModel.nurseDateController,
  //      readOnly: true, // <-- pre-filled from WellnessEvent
  //      validator: (val) =>
  //          (val == null || val.isEmpty) ? 'Please select Date' : null,
  //    ),
  //  ],
  // ),
  // );
  //}
}
