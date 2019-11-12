import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:ele_deploy/services/permissions.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/widgets.dart';
import 'package:system_setting/system_setting.dart';

/// {@category Service}
class BluetoothScanService with ChangeNotifier {
  FlutterBlue _flutterBlue = FlutterBlue.instance;
  Duration _scanTimeoutDuration = Duration(seconds: 15);

  Map<DeviceIdentifier, ScanResult> scanResults = {};
  bool isScanning = false;
  bool isBluetoothOn = true;

  BluetoothScanService() {
    bluetoothStateListner();
  }

  startScan({@required BuildContext context}) async {
    bool hasLocationAccess = await PermissionsService().hasLocationAccess();
    if (Platform.isAndroid) {
      if (hasLocationAccess) {
        _scan();
      }
      if (!hasLocationAccess) {
        await PermissionsService().requestLoctionAccess(context: context);
        _scan();
      }
    }
    if (Platform.isIOS) {
      _scan();
    }
  }

  _scan() async {
    if (isBluetoothOn && await PermissionsService().hasLocationAccess()) {
      stopScan(); //Stop previously running scan
      isScanning = true;
      scanResults.clear();
      notifyListeners();
      _flutterBlue.scan(timeout: _scanTimeoutDuration)
        ..listen(
          (ScanResult s) {
            if (s.advertisementData.localName != ""
                // TODO:
                // &&
                // s.advertisementData.serviceUuids[0]
                // .contains(RegExp(r'^3c73dc70'))) {
                ) {
              scanResults[s.device.id] = s;
              notifyListeners();
            }
          },
          onDone: () {
            stopScan();
          },
        );
    }
  }

  stopScan() {
    _flutterBlue.stopScan();
    isScanning = false;
    notifyListeners();
  }

  void bluetoothStateListner() {
    _flutterBlue.state
      ..listen(
        (bluetoothState) {
          print(bluetoothState);
          isBluetoothOn = (bluetoothState == BluetoothState.on);
          notifyListeners();
        },
      );
  }

  Future turnOnBluetooth() async {
    scanResults.clear();
    stopScan();
    if (Platform.isAndroid) {
      const intent = AndroidIntent(
        action: 'android.bluetooth.adapter.action.REQUEST_ENABLE',
      );
      await intent.launch();
    }
    if (Platform.isIOS) {
      SystemSetting.goto(SettingTarget.BLUETOOTH);
    }
  }

  // Future turnOnLocation() async {
  //   scanResults.clear();
  //   stopScan();
  //   if (Platform.isAndroid) {
  //     const intent = AndroidIntent(
  //       action: 'REQUEST_CHECK_SETTINGS',
  //     );
  //     await intent.launch();
  //   }
  //   if (Platform.isIOS) {
  //     SystemSetting.goto(SettingTarget.BLUETOOTH);
  //   }
  // }
}
