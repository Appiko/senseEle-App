import 'dart:async' show Future;
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;

class Secret {
  final String hasuraKey;
  final String ip;

  Secret({this.ip, this.hasuraKey});

  factory Secret.fromJson(Map<String, dynamic> jsonMap) {
    return new Secret(hasuraKey: jsonMap["hasuraKey"], ip: jsonMap["ip"]);
  }
}

class SecretService {
  final String secretPath = 'assets/secrets.json';
  Future<Secret> getSecret() {
    return rootBundle.loadStructuredData<Secret>(this.secretPath,
        (jsonStr) async {
      final secret = Secret.fromJson(json.decode(jsonStr));
      return secret;
    });
  }
}
