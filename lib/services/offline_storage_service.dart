import 'dart:io';

import 'package:path_provider/path_provider.dart';

class OfflineStorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path + "/pendingQueries";
  }

  storeInFile(String query) async {
    File file = File(await _localPath);
    file.writeAsStringSync(query + ":|:", mode: FileMode.append);
    print("Stored to ${file.path}");
  }

  Future<List<String>> getStoredQueries() async {
    File file = File(await _localPath);
    print("Reading from ${file.path}");
    return file.readAsStringSync().split(":|:");
  }

  cleanFile() async {
    File file = File(await _localPath);
    file.writeAsStringSync("");
  }
}
