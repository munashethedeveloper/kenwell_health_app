import 'package:drift/drift.dart';
import 'package:kenwell_health_app/data/local/app_database.dart';
import '../../../domain/models/wellness_event.dart';

class EventRepository {
  EventRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<WellnessEvent>> fetchAllEvents() async {
    final entities = await _database.getAllEvents();
    return entities.map(_mapEntityToDomain).toList();
  }

  Future<WellnessEvent?> fetchEventById(String id) async {
    final entity = await _database.getEventById(id);
    return entity == null ? null : _mapEntityToDomain(entity);
  }

  Future<void> addEvent(WellnessEvent event) => upsertEvent(event);

  Future<void> deleteEvent(String id) => _database.deleteEventById(id);

  Future<void> updateEvent(WellnessEvent updatedEvent) =>
      upsertEvent(updatedEvent);

  Future<void> upsertEvent(WellnessEvent event) async {
    await _database.upsertEvent(_mapDomainToCompanion(event));
  }

  WellnessEvent _mapEntityToDomain(EventEntity entity) {
    return WellnessEvent(
      id: entity.id,
      title: entity.title,
      date: entity.date,
      venue: entity.venue,
      address: entity.address,
      onsiteContactFirstName: entity.onsiteContactFirstName,
      onsiteContactLastName: entity.onsiteContactLastName,
      onsiteContactNumber: entity.onsiteContactNumber,
      onsiteContactEmail: entity.onsiteContactEmail,
      aeContactFirstName: entity.aeContactFirstName,
      aeContactLastName: entity.aeContactLastName,
      aeContactNumber: entity.aeContactNumber,
      aeContactEmail: entity.aeContactEmail,
      servicesRequested: entity.servicesRequested,
      expectedParticipation: entity.expectedParticipation,
      nonMembers: entity.nonMembers,
      passports: entity.passports,
      nurses: entity.nurses,
      coordinators: entity.coordinators,
      multiplyPromoters: entity.multiplyPromoters,
      setUpTime: entity.setUpTime,
      startTime: entity.startTime,
      endTime: entity.endTime,
      strikeDownTime: entity.strikeDownTime,
      mobileBooths: entity.mobileBooths,
      description: entity.description,
      medicalAid: entity.medicalAid,
      status: entity.status,
      actualStartTime: entity.actualStartTime,
      actualEndTime: entity.actualEndTime,
    );
  }

  EventsCompanion _mapDomainToCompanion(WellnessEvent event) {
    return EventsCompanion(
      id: Value(event.id),
      title: Value(event.title),
      date: Value(event.date),
      venue: Value(event.venue),
      address: Value(event.address),
      onsiteContactFirstName: Value(event.onsiteContactFirstName),
      onsiteContactLastName: Value(event.onsiteContactLastName),
      onsiteContactNumber: Value(event.onsiteContactNumber),
      onsiteContactEmail: Value(event.onsiteContactEmail),
      aeContactFirstName: Value(event.aeContactFirstName),
      aeContactLastName: Value(event.aeContactLastName),
      aeContactNumber: Value(event.aeContactNumber),
      aeContactEmail: Value(event.aeContactEmail),
      servicesRequested: Value(event.servicesRequested),
      expectedParticipation: Value(event.expectedParticipation),
      nonMembers: Value(event.nonMembers),
      passports: Value(event.passports),
      nurses: Value(event.nurses),
      coordinators: Value(event.coordinators),
      multiplyPromoters: Value(event.multiplyPromoters),
      setUpTime: Value(event.setUpTime),
      startTime: Value(event.startTime),
      endTime: Value(event.endTime),
      strikeDownTime: Value(event.strikeDownTime),
      mobileBooths: Value(event.mobileBooths),
      medicalAid: Value(event.medicalAid),
      description: Value(event.description),
      status: Value(event.status),
      actualStartTime: Value(event.actualStartTime),
      actualEndTime: Value(event.actualEndTime),
    );
  }
}
