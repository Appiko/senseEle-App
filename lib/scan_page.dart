import 'package:ele_deploy/locators.dart';
import 'package:ele_deploy/services/bluetooth/bluetooth_connection.dart';
import 'package:ele_deploy/services/bluetooth/bluetooth_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  @override
  Widget build(BuildContext context) {
    bool _isScanning = Provider.of<BluetoothScanService>(context).isScanning;
    List<ScanResult> _scanResults =
        Provider.of<BluetoothScanService>(context).scanResults.values.toList();
    bool _isBluetoothOn =
        Provider.of<BluetoothScanService>(context).isBluetoothOn;
    return Scaffold(
      body: Column(
        children: <Widget>[
          _isBluetoothOn
              ? _isScanning ? LinearProgressIndicator() : Container(height: 2.0)
              : Container(height: 2.0),
          RaisedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/deploy');
            },
            child: Text("Go to deploy"),
          ),
          _isBluetoothOn
              ? Expanded(
                  flex: 1,
                  child: ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (_, __) => Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Container(
                        height: 1,
                        color: Colors.grey,
                      ),
                    ),
                    itemCount: _scanResults.length,
                    itemBuilder: (_, int index) {
                      return ListTile(
                          title: Text(
                              _scanResults[index].advertisementData.localName),
                          trailing: Text(_scanResults[index].rssi.toString()),
                          onTap: () async {
                            locator<BluetoothScanService>().stopScan();
                            await locator<BluetoothConnectionService>().connect(
                              device: _scanResults[index].device,
                              uuid: _scanResults[index]
                                  .advertisementData
                                  .serviceUuids[0],
                            );

                            Navigator.pushNamed(context, '/deploy');
                          });
                    },
                  ),
                )
              : Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Icon(
                      //   Icons.bluetooth_disabled,
                      //   size: 200,
                      //   color: Colors.grey,
                      // ),
                      FloatingActionButton.extended(
                        icon: Icon(Icons.bluetooth_searching),
                        label: Text("TURN ON BLUETOOTH"),
                        onPressed: () =>
                            Provider.of<BluetoothScanService>(context)
                                .turnOnBluetooth(),
                      ),
                    ],
                  ),
                ),
        ],
      ),
      floatingActionButton: !_isBluetoothOn
          ? null
          : !_isScanning
              ? FloatingActionButton.extended(
                  icon: Icon(Icons.adjust),
                  label: Text("SCAN"),
                  onPressed: () => Provider.of<BluetoothScanService>(context)
                      .startScan(context: context),
                )
              : FloatingActionButton.extended(
                  icon: Icon(Icons.stop),
                  label: Text("STOP SCAN"),
                  onPressed:
                      Provider.of<BluetoothScanService>(context).stopScan,
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
