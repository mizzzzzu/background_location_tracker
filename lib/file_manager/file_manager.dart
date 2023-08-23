import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileManager {
  static Future<void> writeToLogFile(String log) async {
    final generalDownloadDir = Directory('/storage/emulated/0/Download');
    File txt =
        await File('${generalDownloadDir.path}/background_logs.txt').create();

    await txt.writeAsString(log, mode: FileMode.append);
  }

  static Future<String> readLogFile() async {
    final file = await _getTempLogFile();
    return file.readAsString();
  }

  static Future<File> _getTempLogFile() async {
    final directory = await getTemporaryDirectory();
    print(directory.path);
    final file = File('${directory.path}/log.txt');
    if (!await file.exists()) {
      await file.writeAsString('');
    }
    return file;
  }

  static Future<void> clearLogFile() async {
    final file = await _getTempLogFile();
    await file.writeAsString('');
  }
}
