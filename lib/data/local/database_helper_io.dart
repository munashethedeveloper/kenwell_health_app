import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<QueryExecutor> openDriftConnection() async {
  final directory = await getApplicationSupportDirectory();
  final file = File(p.join(directory.path, 'kenwell.db'));
  return NativeDatabase.createInBackground(file, logStatements: false);
}
