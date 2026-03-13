import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/features/consent_form/view_model/consent_view_model.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/member.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../data/repositories_dcl/firestore_member_event_repository.dart';
import '../widgets/member_search_screen.dart';
import '../widgets/current_event_home_screen.dart';
import '../widgets/health_screenings_screen.dart';
import '../view_model/wellness_flow_view_model.dart';
import '../../consent_form/widgets/consent_screen.dart';
import '../../member/widgets/member_registration_screen.dart';
import '../../member/view_model/member_registration_view_model.dart';
import 'screening_navigators/screening_navigator.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';

/// Central navigation coordinator for the wellness flow
/// Manages screen-to-screen navigation with proper data passing
class WellnessNavigator {
  final BuildContext context;
  final WellnessEvent event;
  final _memberEventRepository = FirestoreMemberEventRepository();

  /// Delegates individual screening screen pushes to [ScreeningNavigator].
  late final ScreeningNavigator _screeningNavigator =
      ScreeningNavigator(context: context, event: event);

  WellnessNavigator({
    required this.context,
    required this.event,
  });

  /// Start the wellness flow from member registration
  Future<void> startFlow() async {
    final wellnessVM = WellnessFlowViewModel(activeEvent: event);
    await _navigateToMemberRegistration(wellnessVM);
  }

  /// Navigate to member registration (first step)
  /// Keeps member search in the stack for proper back navigation
  Future<void> _navigateToMemberRegistration(
      WellnessFlowViewModel wellnessVM) async {
    await Navigator.push(
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
                // Navigate forward to event home instead of popping
                await navigateToEventDetails(member, wellnessVM);
              }
            },
            onMemberFound: (member) async {
              // Member found, navigate forward to event details
              if (context.mounted) {
                await navigateToEventDetails(member, wellnessVM);
              }
            },
            onPrevious: () {
              Navigator.of(context).pop();
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
    memberVM.setEventDetails(
      event.id,
      eventTitle: event.title,
      eventDate: event.date,
      eventVenue: event.venue,
      eventLocation: event.address,
    );

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
                    Navigator.of(context).pop(memberVM.savedMember);
                  } else if (context.mounted) {
                    AppSnackbar.showError(
                        context, 'Registration failed. Please try again.');
                  }
                } catch (e) {
                  debugPrint('Failed to save member: $e');
                  if (context.mounted) {
                    AppSnackbar.showError(
                        context, 'Failed to register member. Please try again.');
                  }
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
    // Load all completion flags from Firestore so the event home screen
    // immediately shows the correct consent, screenings and survey status.
    await wellnessVM.loadAllCompletionFlags(member.id, event.id);

    // Ensure a member_events record exists for this member-event pair.
    // This covers the case where an existing member is found via search
    // (no new registration form was submitted). Fire-and-forget: navigation
    // should not be blocked by this background write.
    unawaited(
      _memberEventRepository
          .ensureMemberEventExists(
            memberId: member.id,
            eventId: event.id,
            eventTitle: event.title,
            eventDate: Timestamp.fromDate(event.date),
            eventVenue: event.venue,
            eventLocation: event.address,
          )
          .catchError(
              (e) => debugPrint('Failed to ensure member_events record: $e')),
    );

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
                      AppSnackbar.showInfo(context, 'Status refreshed.');
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
                      // Only mark consent and update enabled flags when the user
                      // actually submitted (selectedScreenings is non-null and
                      // non-empty). If the user backs out, selectedScreenings is
                      // null and no state should change.
                      if (selectedScreenings != null) {
                        // Set enabled flags before markConsentCompleted() so
                        // the single notifyListeners() call inside it sends the
                        // full updated state to the hub screen at once.
                        wellnessVM.hraEnabled =
                            selectedScreenings.contains('hra');
                        wellnessVM.hctEnabled =
                            selectedScreenings.contains('hct');
                        wellnessVM.tbEnabled =
                            selectedScreenings.contains('tb');
                        wellnessVM.cancerEnabled =
                            selectedScreenings.contains('cancer');
                        wellnessVM.markConsentCompleted();
                      }
                      break;
                    }
                  case 'health_screenings':
                    {
                      // Loop until user submits all (returns true)
                      bool? result;
                      do {
                        result = await navigateToHealthScreenings(
                          member,
                          wellnessVM,
                          hraEnabled: wellnessVM.hraEnabled,
                          hctEnabled: wellnessVM.hctEnabled,
                          tbEnabled: wellnessVM.tbEnabled,
                          cancerEnabled: wellnessVM.cancerEnabled,
                        );
                      } while (result ==
                          false); // false means completed a screening, need to reshow

                      if (result == true) {
                        wellnessVM.markScreeningsCompleted();
                      } else if (wellnessVM.hraCompleted ||
                          wellnessVM.hctCompleted ||
                          wellnessVM.tbCompleted ||
                          wellnessVM.cancerCompleted) {
                        // Some screenings done but not all — mark as in progress
                        wellnessVM.markScreeningsInProgress();
                      }
                      break;
                    }
                  case 'survey':
                    {
                      final result = await _screeningNavigator.navigateToSurvey(member);
                      if (result == true) {
                        wellnessVM.markSurveyCompleted();
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
        // Provide BOTH consentVM and wellnessVM so that ConsentScreen can
        // read wellnessVM.currentMember?.id for the memberId. Without this,
        // the new route's BuildContext does not inherit the hub route's scoped
        // providers and the memberId lookup silently returns null, causing
        // consent records to be saved with a null memberId.
        builder: (context) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: consentVM),
            ChangeNotifierProvider.value(value: wellnessVM),
          ],
          child: ConsentScreen(
            event: event,
            onNext: () {
              final selectedScreenings = consentVM.selectedScreenings;
              Navigator.of(context).pop(selectedScreenings);
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
      required bool hctEnabled,
      required bool tbEnabled,
      bool cancerEnabled = false}) async {
    // Helper: check if all enabled screenings are now complete.
    bool allDone() =>
        (!hraEnabled || wellnessVM.hraCompleted) &&
        (!hctEnabled || wellnessVM.hctCompleted) &&
        (!tbEnabled || wellnessVM.tbCompleted) &&
        (!cancerEnabled || wellnessVM.cancerCompleted);

    return await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => HealthScreeningsScreen(
          hraEnabled: hraEnabled,
          hctEnabled: hctEnabled,
          tbEnabled: tbEnabled,
          cancerEnabled: cancerEnabled,
          hraCompleted: wellnessVM.hraCompleted,
          hctCompleted: wellnessVM.hctCompleted,
          tbCompleted: wellnessVM.tbCompleted,
          cancerCompleted: wellnessVM.cancerCompleted,
          onHraTap: () async {
            final result = await _screeningNavigator.navigateToHra(member);
            if (!context.mounted) return;
            if (result == true) {
              wellnessVM.markHraCompleted();
              _memberEventRepository
                  .updateScreeningStatus(member.id, event.id,
                      hraCompleted: true)
                  .catchError((e) =>
                      debugPrint('Failed to update HRA screening status: $e'));
              Navigator.of(context).pop(allDone());
            }
          },
          onHctTap: () async {
            final result = await _screeningNavigator.navigateToHctFlow(member);
            if (!context.mounted) return;
            if (result == true) {
              wellnessVM.markHctCompleted();
              _memberEventRepository
                  .updateScreeningStatus(member.id, event.id,
                      hctCompleted: true)
                  .catchError((e) =>
                      debugPrint('Failed to update HCT screening status: $e'));
              Navigator.of(context).pop(allDone());
            }
          },
          onTbTap: () async {
            final result = await _screeningNavigator.navigateToTb(member);
            if (!context.mounted) return;
            if (result == true) {
              wellnessVM.markTbCompleted();
              _memberEventRepository
                  .updateScreeningStatus(member.id, event.id, tbCompleted: true)
                  .catchError((e) =>
                      debugPrint('Failed to update TB screening status: $e'));
              Navigator.of(context).pop(allDone());
            }
          },
          onCancerTap: () async {
            final result = await _screeningNavigator.navigateToCancer(member);
            if (!context.mounted) return;
            if (result == true) {
              wellnessVM.markCancerCompleted();
              _memberEventRepository
                  .updateScreeningStatus(member.id, event.id,
                      cancerCompleted: true)
                  .catchError((e) => debugPrint(
                      'Failed to update Cancer screening status: $e'));
              Navigator.of(context).pop(allDone());
            }
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
}
