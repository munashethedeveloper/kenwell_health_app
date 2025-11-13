import 'package:uuid/uuid.dart';

class WellnessEvent {
  final String id;
  final String title;
  final DateTime date;
  final String venue;
  final String address;
  final String onsiteContactPerson;
  final String onsiteContactNumber;
  final String onsiteContactEmail;
  final String aeContactPerson;
  final String aeContactNumber;
  final String servicesRequested;
  final int expectedParticipation;
  final int nonMembers;
  final int passports;
  final int nurses;
  final int coordinators;
  final int multiplyPromoters;
  final String setUpTime;
  final String startTime;
  final String endTime;
  final String strikeDownTime;
  //final String medicalAidOption;
  final String medicalAid;
  final String mobileBooths;
  final String? description; // optional

  WellnessEvent({
    String? id,
    required this.title,
    required this.date,
    required this.venue,
    required this.address,
    required this.onsiteContactPerson,
    required this.onsiteContactNumber,
    required this.onsiteContactEmail,
    required this.aeContactPerson,
    required this.aeContactNumber,
    required this.servicesRequested,
    required this.expectedParticipation,
    required this.nonMembers,
    required this.passports,
    required this.nurses,
    required this.coordinators,
    required this.multiplyPromoters,
    required this.setUpTime,
    required this.startTime,
    required this.endTime,
    required this.strikeDownTime,
    //required this.medicalAidOption,
    required this.mobileBooths,
    this.description,
    required this.medicalAid,
  }) : id = id ?? const Uuid().v4(); // <-- auto-generate unique ID

  /// Creates a copy of this event with optionally updated fields
  WellnessEvent copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? venue,
    String? address,
    String? onsiteContactPerson,
    String? onsiteContactNumber,
    String? onsiteContactEmail,
    String? aeContactPerson,
    String? aeContactNumber,
    String? servicesRequested,
    int? expectedParticipation,
    int? nonMembers,
    int? passports,
    int? nurses,
    int? coordinators,
    int? multiplyPromoters,
    String? setUpTime,
    String? startTime,
    String? endTime,
    String? strikeDownTime,
    String? medicalAid,
    String? mobileBooths,
    String? description,
  }) {
    return WellnessEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      venue: venue ?? this.venue,
      address: address ?? this.address,
      onsiteContactPerson: onsiteContactPerson ?? this.onsiteContactPerson,
      onsiteContactNumber: onsiteContactNumber ?? this.onsiteContactNumber,
      onsiteContactEmail: onsiteContactEmail ?? this.onsiteContactEmail,
      aeContactPerson: aeContactPerson ?? this.aeContactPerson,
      aeContactNumber: aeContactNumber ?? this.aeContactNumber,
      servicesRequested: servicesRequested ?? this.servicesRequested,
      expectedParticipation: expectedParticipation ?? this.expectedParticipation,
      nonMembers: nonMembers ?? this.nonMembers,
      passports: passports ?? this.passports,
      nurses: nurses ?? this.nurses,
      coordinators: coordinators ?? this.coordinators,
      multiplyPromoters: multiplyPromoters ?? this.multiplyPromoters,
      setUpTime: setUpTime ?? this.setUpTime,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      strikeDownTime: strikeDownTime ?? this.strikeDownTime,
      medicalAid: medicalAid ?? this.medicalAid,
      mobileBooths: mobileBooths ?? this.mobileBooths,
      description: description ?? this.description,
    );
  }
}
