import 'package:ele_deploy/services/bluetooth/bluetooth_connection.dart';
import 'package:ele_deploy/services/bluetooth/bluetooth_scan.dart';
import 'package:ele_deploy/services/bluetooth/blutetooth_io.dart';
import 'package:ele_deploy/services/connectivity_service.dart';
import 'package:ele_deploy/services/fcm_service.dart';
import 'package:ele_deploy/services/hasura_service.dart';
import 'package:ele_deploy/services/location/location_service.dart';
import 'package:ele_deploy/services/offline_storage_service.dart';
import 'package:ele_deploy/services/secret_service.dart';
import 'package:ele_deploy/services/shared_prefs.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt();

void setupLocator() {
  locator.registerLazySingleton<SharedPrefs>(() => SharedPrefs());
  locator.registerLazySingleton(() => BluetoothScanService());
  locator.registerLazySingleton(() => BluetoothConnectionService());
  locator.registerLazySingleton(() => BluetoothIOService());
  locator.registerLazySingleton(() => LocationService());
  locator.registerLazySingleton(() => OfflineStorageService());
  locator.registerLazySingleton(() => ConnectivityService());
  locator.registerLazySingleton(() => HasuraService());
  locator.registerLazySingleton(() => FCMService());
  locator.registerLazySingleton(() => SecretService());
}
