import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/member.dart';
import '../../../../domain/models/wellness_event.dart';
import '../widgets/member_search_screen.dart';
import '../widgets/current_event_home_screen.dart';
import '../widgets/health_screenings_screen.dart';
import '../view_model/wellness_flow_view_model.dart';
import '../../consent_form/widgets/consent_screen.dart';
import '../../consent_form/view_model/consent_screen_view_model.dart';
import '../../member/widgets/member_registration_screen.dart';
import '../../member/view_model/member_registration_view_model.dart';
import '../../health_risk_assessment/widgets/health_risk_assessment_screen.dart';
import '../../health_risk_assessment/view_model/health_risk_assessment_view_model.dart';
import '../../nurse_interventions/view_model/nurse_intervention_view_model.dart';
import '../../hiv_test/widgets/hiv_test_screen.dart';
import '../../hiv_test/view_model/hiv_test_view_model.dart';
import '../../hiv_test_results/widgets/hiv_test_result_screen.dart';
import '../../hiv_test_results/view_model/hiv_test_result_view_model.dart';
import '../../tb_test/widgets/tb_testing_screen.dart';
import '../../tb_test/view_model/tb_testing_view_model.dart';
import '../../survey/widgets/survey_screen.dart';
import '../../survey/view_model/survey_view_model.dart';

/// Central navigation coordinator for the wellness flow
/// Manages screen-to-screen navigation with proper data passing
class WellnessNavigator {
  final BuildContext context;
  final WellnessEvent event;

  WellnessNavigator({
    required this.context,
    required this.event,
  });

  /// Start the wellness flow from member registration
  Future<void> startFlow() async {
    final wellnessVM = WellnessFlowViewModel(activeEvent: event);
    final member = await _navigateToMemberRegistration();
    if (member != null && context.mounted) {
      await navigateToEventDetails(member, wellnessVM);
    }
  }

  /// Navigate to member registration (first step)
  Future<Member?> _navigateToMemberRegistration() async {
    return await Navigator.push<Member>(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: KenwellAppBar(
            title: event.title,
            subtitle: 'Member Search Form',
            titleColor: Colors.white,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
            backgroundColor: const Color(0xFF201C58),
            actions: [
              TextButton.icon(
                onPressed: () {
                  if (context.mounted) {
                    context.pushNamed('help');
                  }
                },
                icon: const Icon(Icons.help_outline, color: Colors.white),
                label: const Text(
                  'Help',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          body: MemberSearchScreen(
            onGoToMemberDetails: (searchQuery) async {
              final member = await _navigateToMemberDetails(null, searchQuery);
              if (member != null && context.mounted) {
                context.pop(member);
              }
            },
            onMemberFound: (member) {
              // Member found, go to event details
              context.pop(member);
            },
            onPrevious: () {
              context.pop();
            },
          ),
        ),
      ),
    );
  }

  /// Navigate to member details for new registration
  Future<Member?> _navigateToMemberDetails(Member? existingMember,
      [String? searchQuery]) async {
    final memberVM = MemberDetailsViewModel();
    memberVM.setEventId(event.id);

    // Pre-populate ID/Passport field if search query exists
    if (searchQuery != null && searchQuery.isNotEmpty) {
      if (searchQuery.length == 13 && int.tryParse(searchQuery) != null) {
        // SA ID Number
        memberVM.setIdDocumentChoice('ID');
        memberVM.idNumberController.text = searchQuery;
      } else {
        // Passport
        memberVM.setIdDocumentChoice('Passport');
        memberVM.passportNumberController.text = searchQuery;
      }
    }

    return await Navigator.push<Member>(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: memberVM,
          child: MemberDetailsScreen(
            onNext: () async {
              // Save member and return
              if (memberVM.formKey.currentState?.validate() ?? false) {
                try {
                  await memberVM.saveLocally();
                  if (context.mounted && memberVM.savedMember != null) {
                    context.pop(memberVM.savedMember);
                  }
                } catch (e) {
                  debugPrint('Failed to save member: $e');
                }
              }
            },
            viewModel: memberVM,
            appBar: KenwellAppBar(
              title: event.title,
              subtitle: 'Member Registration Form',
              titleColor: Colors.white,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              backgroundColor: const Color(0xFF201C58),
            ),
          ),
        ),
      ),
    );
  }

  /// Navigate to event details hub (shows sections to complete)
  Future<void> navigateToEventDetails(
      Member member, WellnessFlowViewModel wellnessVM) async {
    wellnessVM.currentMember = member;
    wellnessVM.memberRegistrationCompleted = true;
    await wellnessVM.checkConsentCompletion(member.id, event.id);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: wellnessVM,
          child: Scaffold(
            appBar: KenwellAppBar(
              title: event.title,
              subtitle: 'Event Home',
              titleColor: Colors.white,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              backgroundColor: const Color(0xFF201C58),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: () async {
                    final memberId = wellnessVM.currentMember?.id;
                    final eventId = event.id;
                    if (memberId != null) {
                      await wellnessVM.loadAllCompletionFlags(
                          memberId, eventId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Status refreshed.')),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  tooltip: 'Help',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Help'),
                        content: const Text(
                            'This screen shows the current event details and your progress through the wellness process.\n\n'
                            'Use the refresh button to reload your completion status. Tap any card to continue or review that section.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            backgroundColor: Colors.white,
            body: CurrentEventHomeScreen(
              event: event,
              onSectionTap: (section) async {
                switch (section) {
                  case 'consent':
                    {
                      final selectedScreenings =
                          await _navigateToConsent(member, wellnessVM);
                      wellnessVM.markConsentCompleted();
                      // Store selected screenings in wellnessVM for later use
                      wellnessVM.hraEnabled =
                          selectedScreenings?.contains('hra') ?? false;
                      wellnessVM.hivEnabled =
                          selectedScreenings?.contains('hiv') ?? false;
                      wellnessVM.tbEnabled =
                          selectedScreenings?.contains('tb') ?? false;
                      break;
                    }
                  case 'health_screenings':
                    {
                      // Use stored flags from wellnessVM
                      final result = await navigateToHealthScreenings(
                        member,
                        wellnessVM,
                        hraEnabled: wellnessVM.hraEnabled,
                        hivEnabled: wellnessVM.hivEnabled,
                        tbEnabled: wellnessVM.tbEnabled,
                      );
                      if (result == true) {
                        wellnessVM.screeningsCompleted = true;
                      }
                      break;
                    }
                  case 'survey':
                    {
                      final result = await _navigateToSurvey(member);
                      if (result == true) {
                        wellnessVM.surveyCompleted = true;
                      }
                      break;
                    }
                }
              },
              onBackToSearch: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Navigate to consent form
  Future<List<String>?> _navigateToConsent(
      Member member, WellnessFlowViewModel wellnessVM) async {
    final consentVM = ConsentScreenViewModel();

    return await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: consentVM,
          child: ConsentScreen(
            event: event,
            onNext: () {
              final selectedScreenings = consentVM.selectedScreenings;
              context.pop(selectedScreenings);
            },
            appBar: KenwellAppBar(
              title: event.title,
              subtitle: 'Consent Form',
              titleColor: Colors.white,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              backgroundColor: const Color(0xFF201C58),
            ),
          ),
        ),
      ),
    );
  }

  /// Navigate to health screenings menu
  Future<bool?> navigateToHealthScreenings(
      Member member, WellnessFlowViewModel wellnessVM,
      {required bool hraEnabled,
      required bool hivEnabled,
      required bool tbEnabled}) async {
    return await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => HealthScreeningsScreen(
          hraEnabled: hraEnabled,
          hivEnabled: hivEnabled,
          tbEnabled: tbEnabled,
          hraCompleted: wellnessVM.hraCompleted,
          hivCompleted: wellnessVM.hivCompleted,
          tbCompleted: wellnessVM.tbCompleted,
          onHraTap: () async {
            final result = await _navigateToHra(member);
            if (!context.mounted) return;
            if (result == true) {
              wellnessVM.hraCompleted = true;
              // Reopen health screenings to update UI
              await navigateToHealthScreenings(
                member,
                wellnessVM,
                hraEnabled: hraEnabled,
                hivEnabled: hivEnabled,
                tbEnabled: tbEnabled,
              );
            }
          },
          onHivTap: () async {
            final result = await _navigateToHivFlow(member);
            if (!context.mounted) return;
            if (result == true) {
              wellnessVM.hivCompleted = true;
              await navigateToHealthScreenings(
                member,
                wellnessVM,
                hraEnabled: hraEnabled,
                hivEnabled: hivEnabled,
                tbEnabled: tbEnabled,
              );
            }
          },
          onTbTap: () async {
            final result = await _navigateToTb(member);
            if (!context.mounted) return;
            if (result == true) {
              wellnessVM.tbCompleted = true;
              await navigateToHealthScreenings(
                member,
                wellnessVM,
                hraEnabled: hraEnabled,
                hivEnabled: hivEnabled,
                tbEnabled: tbEnabled,
              );
            }
          },
          onSubmitAll: () {
            context.pop(true);
          },
          appBar: KenwellAppBar(
            title: event.title,
            subtitle: 'Health Screenings',
            titleColor: Colors.white,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            backgroundColor: const Color(0xFF201C58),
          ),
        ),
      ),
    );
  }

  /// Navigate to HRA screening
  Future<bool?> _navigateToHra(Member member) async {
    final riskVM = PersonalRiskAssessmentViewModel();
    final nurseVM = NurseInterventionViewModel();
    riskVM.setMemberAndEventId(member.id, event.id);

    // Calculate age from member DOB
    int age = 0;
    if (member.dateOfBirth != null) {
      final dob = DateTime.tryParse(member.dateOfBirth!);
      if (dob != null) {
        final now = DateTime.now();
        age = now.year - dob.year;
        if (now.month < dob.month ||
            (now.month == dob.month && now.day < dob.day)) {
          age--;
        }
      }
    }

    return await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: riskVM),
            ChangeNotifierProvider.value(value: nurseVM),
          ],
          child: PersonalRiskAssessmentScreen(
            onNext: () {
              context.pop(true);
            },
            onPrevious: () {
              context.pop();
            },
            viewModel: riskVM,
            nurseViewModel: nurseVM,
            isFemale: member.gender?.toLowerCase() == 'female',
            age: age,
            appBar: KenwellAppBar(
              title: event.title,
              subtitle: 'Health Risk Assessment Form',
              titleColor: Colors.white,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              backgroundColor: const Color(0xFF201C58),
            ),
          ),
        ),
      ),
    );
  }

  /// Navigate to HIV test flow (test + results)
  Future<bool?> _navigateToHivFlow(Member member) async {
    final hivTestVM = HIVTestViewModel();
    hivTestVM.setMemberAndEventId(member.id, event.id);

    // First HIV test
    final testCompleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: hivTestVM,
          child: HIVTestScreen(
            onNext: () {
              context.pop(true);
            },
            onPrevious: () {
              context.pop();
            },
            appBar: KenwellAppBar(
              title: event.title,
              subtitle: 'HCT Form',
              titleColor: Colors.white,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              backgroundColor: const Color(0xFF201C58),
            ),
          ),
        ),
      ),
    );

    // Then HIV results if test completed
    if (testCompleted == true && context.mounted) {
      final hivResultsVM = HIVTestResultViewModel();
      hivResultsVM.initialiseWithEvent(event);
      hivResultsVM.setMemberAndEventId(member.id, event.id);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: hivResultsVM,
            child: HIVTestResultScreen(
              onNext: () {
                context.pop(true);
              },
              onPrevious: () {
                context.pop();
              },
              appBar: KenwellAppBar(
                title: event.title,
                subtitle: 'HCT Results Form',
                titleColor: Colors.white,
                titleStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                backgroundColor: const Color(0xFF201C58),
              ),
            ),
          ),
        ),
      );
      return true;
    }
    return testCompleted;
  }

  /// Navigate to TB screening
  Future<bool?> _navigateToTb(Member member) async {
    final tbTestVM = TBTestingViewModel();
    tbTestVM.initialiseWithEvent(event);
    tbTestVM.setMemberAndEventId(member.id, event.id);

    return await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: tbTestVM,
          child: TBTestingScreen(
            onNext: () {
              context.pop(true);
            },
            onPrevious: () {
              context.pop();
            },
            appBar: KenwellAppBar(
              title: event.title,
              subtitle: 'TB Form',
              titleColor: Colors.white,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              backgroundColor: const Color(0xFF201C58),
            ),
          ),
        ),
      ),
    );
  }

  /// Navigate to survey
  Future<bool?> _navigateToSurvey(Member member) async {
    final surveyVM = SurveyViewModel();

    return await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: surveyVM,
          child: SurveyScreen(
            onSubmit: () {
              context.pop(true);
            },
            onPrevious: () {
              context.pop();
            },
            appBar: KenwellAppBar(
              title: event.title,
              subtitle: 'Survey Form',
              titleColor: Colors.white,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              backgroundColor: const Color(0xFF201C58),
            ),
          ),
        ),
      ),
    );
  }
}
