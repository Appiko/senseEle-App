import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:ele_deploy/locators.dart';
import 'package:ele_deploy/services/hasura_service.dart';
import 'package:ele_deploy/services/offline_storage_service.dart';

class ConnectivityService {
  final Connectivity connectivity = Connectivity();

  changed(ConnectivityResult connectivityResult) async {
    if (connectivityResult != ConnectivityResult.none) {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          print("Connected to internet, Performing pending queries...");
          List<String> queries =
              await locator<OfflineStorageService>().getStoredQueries();
          print("$queries, ${queries.length}");
          // empty string
          queries.removeLast();
          if (queries.length > 1) {
            //TODO: Consider the minute chance of failing here.
            queries.forEach((q) => locator<HasuraService>().mutate(q));
          }
          locator<OfflineStorageService>().cleanFile();
          print("done updating offline storage");
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void listen() {
    connectivity.onConnectivityChanged.listen((c) => changed(c));
  }
}
