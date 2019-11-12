import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// {@category Service}
/// Shared Prefrences service, used to store small key value pairs like, dart theme.
class SharedPrefs with ChangeNotifier {
  SharedPreferences _prefs;

  SharedPrefs() {
    prefsInit();
  }

  prefsInit() async {
    _prefs = await SharedPreferences.getInstance();
    notifyListeners();
  }

  bool get shouldUpload => _prefs.getBool("shouldUpload") ?? false;

  Future setShouldUpload(bool value) async {
    await _prefs.setBool("shouldUpload", value);
    notifyListeners();
  }
}
