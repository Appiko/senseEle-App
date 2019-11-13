import 'package:flutter/widgets.dart';
import 'package:flutter_blue/flutter_blue.dart';

/// {@category Service}
class BluetoothConnectionService with ChangeNotifier {
  BluetoothDevice device;
  BluetoothDeviceState deviceState;

  connect({
    @required BluetoothDevice device,
    @required String uuid,
  }) async {
    deviceState = null;
    this.device = device;
    await this.device.connect(autoConnect: false);
    print("Connected to ${this.device.id}");
    this.device.state.listen((BluetoothDeviceState bluetoothDeviceState) {
      print("$bluetoothDeviceState");
      deviceState = bluetoothDeviceState;
      notifyListeners();
    });
  }

  disconnect() async {
    await device.disconnect();
    device = null;
    deviceState = null;
    notifyListeners();
  }
}
