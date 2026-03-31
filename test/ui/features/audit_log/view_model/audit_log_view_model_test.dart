import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_audit_log_repository.dart';
import 'package:kenwell_health_app/domain/models/audit_log_entry.dart';
import 'package:kenwell_health_app/ui/features/audit_log/view_model/audit_log_view_model.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────────

class MockFirestoreAuditLogRepository extends Mock
    implements FirestoreAuditLogRepository {}

// ── Helpers ────────────────────────────────────────────────────────────────────

AuditLogEntry _buildEntry({
  String id = 'log-1',
  String action = 'create',
  String collection = 'events',
  String documentId = 'doc-1',
  String performedBy = 'uid-1',
}) =>
    AuditLogEntry(
      id: id,
      action: action,
      collection: collection,
      documentId: documentId,
      performedBy: performedBy,
      performedAt: DateTime(2025, 6, 1),
    );

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  late MockFirestoreAuditLogRepository mockRepo;
  late AuditLogViewModel viewModel;

  setUp(() {
    mockRepo = MockFirestoreAuditLogRepository();
    viewModel = AuditLogViewModel(repository: mockRepo);
  });

  tearDown(() => viewModel.dispose());

  // ── Initial state ────────────────────────────────────────────────────────────

  group('AuditLogViewModel – initial state', () {
    test('filter defaults to "all"', () {
      expect(viewModel.filter, equals('all'));
    });
  });

  // ── setFilter ────────────────────────────────────────────────────────────────

  group('AuditLogViewModel – setFilter', () {
    test('setFilter updates filter value', () {
      viewModel.setFilter('create');
      expect(viewModel.filter, equals('create'));
    });

    test('setFilter notifies listeners when value changes', () {
      var notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.setFilter('update');

      expect(notified, isTrue);
    });

    test('setFilter does not notify listeners when value is unchanged', () {
      var notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      viewModel.setFilter('all'); // same as default

      expect(notifyCount, equals(0));
    });

    test('setFilter accepts all valid filter values', () {
      for (final value in ['all', 'create', 'update', 'delete']) {
        viewModel.setFilter(value);
        expect(viewModel.filter, equals(value));
      }
    });
  });

  // ── auditLogStream ───────────────────────────────────────────────────────────

  group('AuditLogViewModel – auditLogStream', () {
    test('returns all entries when filter is "all"', () async {
      final entries = [
        _buildEntry(id: '1', action: 'create'),
        _buildEntry(id: '2', action: 'update'),
        _buildEntry(id: '3', action: 'delete'),
      ];
      when(() => mockRepo.watchAuditLogs())
          .thenAnswer((_) => Stream.value(entries));

      viewModel.setFilter('all');
      final result = await viewModel.auditLogStream.first;

      expect(result, hasLength(3));
    });

    test('returns only "create" entries when filter is "create"', () async {
      final entries = [
        _buildEntry(id: '1', action: 'create'),
        _buildEntry(id: '2', action: 'update'),
        _buildEntry(id: '3', action: 'create'),
      ];
      when(() => mockRepo.watchAuditLogs())
          .thenAnswer((_) => Stream.value(entries));

      viewModel.setFilter('create');
      final result = await viewModel.auditLogStream.first;

      expect(result, hasLength(2));
      expect(result.every((e) => e.action == 'create'), isTrue);
    });

    test('returns only "update" entries when filter is "update"', () async {
      final entries = [
        _buildEntry(id: '1', action: 'create'),
        _buildEntry(id: '2', action: 'update'),
      ];
      when(() => mockRepo.watchAuditLogs())
          .thenAnswer((_) => Stream.value(entries));

      viewModel.setFilter('update');
      final result = await viewModel.auditLogStream.first;

      expect(result, hasLength(1));
      expect(result.first.action, equals('update'));
    });

    test('returns only "delete" entries when filter is "delete"', () async {
      final entries = [
        _buildEntry(id: '1', action: 'create'),
        _buildEntry(id: '2', action: 'delete'),
        _buildEntry(id: '3', action: 'delete'),
      ];
      when(() => mockRepo.watchAuditLogs())
          .thenAnswer((_) => Stream.value(entries));

      viewModel.setFilter('delete');
      final result = await viewModel.auditLogStream.first;

      expect(result, hasLength(2));
      expect(result.every((e) => e.action == 'delete'), isTrue);
    });

    test('returns empty list when no entries match the active filter', () async {
      final entries = [
        _buildEntry(id: '1', action: 'create'),
      ];
      when(() => mockRepo.watchAuditLogs())
          .thenAnswer((_) => Stream.value(entries));

      viewModel.setFilter('delete');
      final result = await viewModel.auditLogStream.first;

      expect(result, isEmpty);
    });

    test('filter comparison is case-insensitive for action field', () async {
      final entries = [
        _buildEntry(id: '1', action: 'Create'), // upper-case C
        _buildEntry(id: '2', action: 'update'),
      ];
      when(() => mockRepo.watchAuditLogs())
          .thenAnswer((_) => Stream.value(entries));

      viewModel.setFilter('create');
      final result = await viewModel.auditLogStream.first;

      expect(result, hasLength(1));
      expect(result.first.id, equals('1'));
    });
  });
}
