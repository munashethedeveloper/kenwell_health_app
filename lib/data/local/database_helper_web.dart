import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

Future<QueryExecutor> openDriftConnection() async {
  final result = await WasmDatabase.open(
    databaseName: 'kenwell_db',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.js'),
  );
  return result.resolvedExecutor;
}
