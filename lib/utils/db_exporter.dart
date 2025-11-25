import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const String _dbFileName = 'kenwell_app.sqlite';

Future<File?> exportLocalDatabase() async {
  final docsDir = await getApplicationDocumentsDirectory();
  final sourcePath = p.join(docsDir.path, _dbFileName);
  final sourceFile = File(sourcePath);
  if (!await sourceFile.exists()) {
    return null;
  }

  Directory? targetDir;
  try {
    targetDir = await getDownloadsDirectory();
  } catch (_) {
    targetDir = null;
  }
  targetDir ??= await getTemporaryDirectory();

  final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final targetPath =
      p.join(targetDir.path, 'kenwell_backup_$timestamp.sqlite');
  final targetFile = await sourceFile.copy(targetPath);
  return targetFile;
}
