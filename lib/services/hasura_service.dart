import 'package:ele_deploy/locators.dart';
import 'package:ele_deploy/services/secret_service.dart';
import 'package:hasura_connect/hasura_connect.dart';

class HasuraService {
  Secret _secret;
  String _url;
  HasuraConnect _hasuraConnect;

  HasuraService() {
    init();
  }

  init() async {
    _secret = await locator<SecretService>().getSecret();
    _url = "http://${_secret.ip}:8080/v1/graphql";
    _hasuraConnect = HasuraConnect(_url, headers: {
      "x-hasura-admin-secret": _secret.hasuraKey,
    });
  }

  mutate(String query) async {
    try {
      return await _hasuraConnect.mutation(query);
    } catch (e) {
      print(e);
    }
  }

  Future query(String query) async {
    if (_secret == null) {
      await init();
    }
    try {
      return await _hasuraConnect.query(query);
    } catch (e) {
      print(e);
    }
  }
}
