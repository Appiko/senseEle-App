import 'package:ele_deploy/locators.dart';
import 'package:ele_deploy/models/device_info.dart';
import 'package:ele_deploy/services/bluetooth/bluetooth_connection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';

/// {@category service}
class BluetoothIOService extends ChangeNotifier {
  Future<DeviceInfo> readDeviceInfo() async {
    BluetoothDevice device = locator<BluetoothConnectionService>().device;
    if (device != null) {
      List<BluetoothService> services = await device.discoverServices();

      return DeviceInfo(
        macAddress: device.id.id,
        number: await services[2]
            .characteristics[0]
            .read()
            .then((List<int> r) => r[0]),
      );
    }
    return null;
  }
}
