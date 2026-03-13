import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/models/nursing_referral_option.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/health_metric_status_badge.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/nursing_referral_status_card.dart';
import 'package:kenwell_health_app/ui/features/nurse_interventions/view_model/nurse_intervention_view_model.dart';
import 'package:kenwell_health_app/ui/shared/ui/headers/kenwell_gradient_header.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../view_model/health_risk_assessment_view_model.dart';
import 'sections/hra_lifestyle_section.dart';
import 'sections/hra_gender_questions_section.dart';
import 'sections/hra_health_metrics_section.dart';

/// Health Risk Assessment (HRA) form screen — Section C of the wellness flow.
///
/// This screen is a StatelessWidget that hosts a [Consumer] on
/// [PersonalRiskAssessmentViewModel].  Complex build-level callbacks
/// (auto-referral logic, see below) are deferred with
/// [WidgetsBinding.addPostFrameCallback] so they never mutate ViewModel
/// state synchronously during a build pass.
///
/// ## Auto-referral logic (important — do not simplify without reading this)
///
/// When the nurse enters health metrics the ViewModel computes colour-coded
/// zones (Red / Caution / Healthy).  Based on the zone, the nursing-referral
/// selection is automatically pre-populated:
///
/// | Zone    | Auto-set                         | Conditions                                   |
/// |---------|----------------------------------|----------------------------------------------|
/// | Red     | referredToStateClinic            | Only if no prior selection OR "not referred" |
/// | Caution | *(no change to selection)*       | Clears a red-auto-set; nurse decides         |
/// | Healthy | patientNotReferred               | Only if no selection OR not already that     |
///
/// This prevents nurses from accidentally triggering (or missing) referrals
/// as they update one metric at a time.
class PersonalRiskAssessmentScreen extends StatelessWidget {
  const PersonalRiskAssessmentScreen({
    super.key,
    required this.viewModel,
    required this.nurseViewModel,
    required this.isFemale,
    required this.age,
    this.onNext,
    this.onPrevious,
    this.appBar,
  });

  final PersonalRiskAssessmentViewModel viewModel;
  final NurseInterventionViewModel nurseViewModel;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  /// True when the patient is female; controls which gender-specific sections
  /// are shown (pap smear, breast exam, mammogram vs. prostate questions).
  final bool isFemale;

  /// Patient age — used to show the mammogram / prostate-check questions only
  /// for patients older than 40.
  final int age;

  /// Optional custom app bar injected by the caller (e.g. from the wellness
  /// flow).  Falls back to a plain KenwellAppBar.
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    // Initialise gender + age once after the first frame so ViewModel state is
    // correct before the form renders conditional sections.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.setPersonalDetails(
        gender: isFemale ? 'Female' : 'Male',
        age: age,
      );
    });

    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<PersonalRiskAssessmentViewModel>(
        builder: (context, vm, _) {
          // ── Auto-referral logic ───────────────────────────────────────
          // All three branches use addPostFrameCallback to avoid calling
          // notifyListeners() inside build(), which would schedule a second
          // frame and could cause an assertion error.
          if (vm.hasRedMetrics) {
            // RED ZONE: auto-refer unless the nurse already made a manual
            // selection other than "not referred".
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (nurseViewModel.nursingReferralSelection == null ||
                  nurseViewModel.nursingReferralSelection ==
                      NursingReferralOption.patientNotReferred) {
                nurseViewModel.setNursingReferralSelection(
                  NursingReferralOption.referredToStateClinic,
                );
              }
            });
          } else if (vm.isCaution) {
            // CAUTION ZONE: clear a previous red-zone auto-set only.
            // Do NOT force a value here — the nurse must use their discretion.
            // Intentionally leave "not referred" selections so we don't erase
            // a deliberate nurse choice made while in the caution zone.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (nurseViewModel.nursingReferralSelection ==
                  NursingReferralOption.referredToStateClinic) {
                nurseViewModel.setNursingReferralSelection(null);
              }
            });
          } else if (vm.isHealthy) {
            // HEALTHY ZONE: auto-clear to "not referred".
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (nurseViewModel.nursingReferralSelection == null ||
                  nurseViewModel.nursingReferralSelection !=
                      NursingReferralOption.patientNotReferred) {
                nurseViewModel.setNursingReferralSelection(
                  NursingReferralOption.patientNotReferred,
                );
              }
            });
          }

          return Scaffold(
            appBar: appBar ??
                const KenwellAppBar(
                  title: 'KenWell365',
                  automaticallyImplyLeading: false,
                ),
            body: Column(
              children: [
                // Gradient header
                const KenwellGradientHeader(
                  label: 'ASSESSMENT',
                  title: 'Health Risk\nAssessment',
                  subtitle: 'Section C: Complete the health screening form',
                ),
                // Scrollable form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: vm.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // Section 1: Chronic Conditions (inline — small enough)
                          KenwellFormCard(
                            title:
                                '1. Do you suffer or take medication for any of the following conditions?',
                            child: Column(
                              children: [
                                ...vm.chronicConditions.keys.map((condition) {
                                  return CheckboxListTile(
                                    title: Text(condition),
                                    value: vm.chronicConditions[condition],
                                    onChanged: (val) =>
                                        vm.toggleCondition(condition, val),
                                  );
                                }),
                                if (vm.chronicConditions['Other'] == true)
                                  _buildOtherConditionField(vm),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Sections 2–4: Lifestyle (Exercise, Smoking, Alcohol)
                          HraLifestyleSection(vm: vm),

                          const SizedBox(height: 24),

                          // Sections 5–7: Female-only questions
                          HraFemaleQuestionsSection(vm: vm),

                          // Sections 8–9: Male-only questions
                          HraMaleQuestionsSection(vm: vm),

                          const SizedBox(height: 32),

                          // Section D: Health Metrics
                          HraHealthMetricsSection(vm: vm),

                          // Red-zone alert banner
                          if (vm.hasRedMetrics) ...[
                            const SizedBox(height: 12),
                            const HealthMetricRedAlert(),
                          ],

                          const SizedBox(height: 24),

                          // Nursing referral section
                          NursingReferralStatusCard(
                            title: 'Nursing Referrals',
                            selectedValue:
                                nurseViewModel.nursingReferralSelection,
                            onChanged:
                                nurseViewModel.setNursingReferralSelection,
                            notReferredReasonController:
                                nurseViewModel.notReferredReasonController,
                            isCaution: vm.isCaution,
                            reasonValidator: (val) =>
                                (val == null || val.isEmpty)
                                    ? 'Please enter a reason'
                                    : null,
                          ),

                          const SizedBox(height: 24),

                          // Navigation (Previous + Submit)
                          KenwellFormNavigation(
                            nextLabel: 'Submit',
                            onPrevious: vm.isSubmitting ? null : onPrevious,
                            onNext: () =>
                                vm.submitResults(context, onNext: onNext ?? () {}),
                            isNextBusy: vm.isSubmitting,
                            isNextEnabled: !vm.isSubmitting,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Free-text field shown when the patient selects "Other" as a chronic
  /// condition.
  Widget _buildOtherConditionField(PersonalRiskAssessmentViewModel vm) {
    return KenwellFormCard(
      useGradient: false,
      child: TextFormField(
        controller: vm.otherConditionController,
        decoration: const InputDecoration(
          labelText: 'If Other, please specify condition and treatment',
          hintText: 'Specify other condition...',
        ),
        validator: (val) => val == null || val.isEmpty
            ? 'Please specify other condition'
            : null,
      ),
    );
  }
}
