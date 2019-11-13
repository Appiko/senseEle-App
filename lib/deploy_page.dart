import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ele_deploy/locators.dart';
import 'package:ele_deploy/models/device_info.dart';
import 'package:ele_deploy/services/bluetooth/bluetooth_connection.dart';
import 'package:ele_deploy/services/bluetooth/bluetooth_scan.dart';
import 'package:ele_deploy/services/bluetooth/blutetooth_io.dart';
import 'package:ele_deploy/services/hasura_service.dart';
import 'package:ele_deploy/services/location/location_service.dart';
import 'package:ele_deploy/services/offline_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:hasura_connect/hasura_connect.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class DeployPage extends StatefulWidget {
  @override
  _DeployPageState createState() => _DeployPageState();
}

class _DeployPageState extends State<DeployPage> {
  static final String url = 'http://10.10.20.114:8080/v1/graphql';
  HasuraConnect hasuraConnect = HasuraConnect(url);

  JsonEncoder encoder = new JsonEncoder.withIndent('  ');

  var rand = new Random();

  bool isDeploying = false;
  String _randomString() {
    var codeUnits = new List.generate(1, (index) {
      return rand.nextInt(6) + 65;
    });

    return String.fromCharCodes(codeUnits).toUpperCase();
  }

  updateNode(DeviceInfo deviceInfo) async {
    setState(() {
      isDeploying = true;
    });
    LocationData locationData = await locator<LocationService>().getLocation();
    if (locationData == null) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Deployment Failed"),
                content: Text(
                    "Could not get location accuracy of less than 10m, try again."),
              ));
      setState(() {
        isDeploying = false;
      });
      return;
    }

    // TODO: Should deployed on be updated?
    String query = """
        mutation {
         insert_node(objects: {
           deployment: "3cb9fa15-17b1-4141-82d2-1cfd40e48ff8",
           id: "${deviceInfo.macAddress}",
           location: "(${locationData.latitude},${locationData.longitude})",
           number: ${deviceInfo.number},
           accuracy: "${locationData.accuracy}",
           }
          on_conflict: {
            constraint: node_pkey,
            
            update_columns: [number, location, accuracy, deployment,deployed_on]
          }) {
           returning {
              id
             location
           }
          }
        }
      """;

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print(await locator<HasuraService>().mutate(query));
      }
    } on SocketException {
      print('Not connected; Writing to file');
      locator<OfflineStorageService>().storeInFile(query);
    } on Exception {
      print("WRONG!");
    }
    closeConnection();
    Navigator.pop(context);
  }

  String getFakeMacAddress() {
    return _randomString() +
        rand.nextInt(9).toString() +
        ":" +
        _randomString() +
        rand.nextInt(9).toString() +
        ":" +
        _randomString() +
        rand.nextInt(9).toString() +
        ":" +
        _randomString() +
        rand.nextInt(9).toString() +
        ":" +
        _randomString() +
        rand.nextInt(9).toString() +
        ":" +
        _randomString() +
        rand.nextInt(9).toString();
  }

  Future<DeviceInfo> getMacAddress() async {
    return locator<BluetoothIOService>().readDeviceInfo();
  }

  DeviceInfo deviceInfo;

  closeConnection() async {
    await locator<BluetoothConnectionService>().disconnect();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    print("rebuilding");

    if (Provider.of<BluetoothConnectionService>(context).deviceState ==
            BluetoothDeviceState.disconnected ||
        !Provider.of<BluetoothScanService>(context).isBluetoothOn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.popUntil(context, ModalRoute.withName('/scan'));
      });
      return Scaffold();
    }

    return WillPopScope(
      onWillPop: () => closeConnection(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                FutureBuilder(
                  future: getMacAddress(),
                  builder: (_, AsyncSnapshot<DeviceInfo> snapshot) {
                    if (snapshot.hasData) {
                      deviceInfo = snapshot.data;
                      return Column(
                        children: <Widget>[
                          Text("MAC address: ${snapshot.data.macAddress}\n"),
                          Text("Number: ${snapshot.data.number}\n"),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text("Error!");
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),

                isDeploying
                    ? CircularProgressIndicator(strokeWidth: 5)
                    : RaisedButton(
                        color: Colors.lightBlueAccent,
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        onPressed: () => updateNode(deviceInfo),
                        child: Text(
                          "DEPLOY",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ),

                // SliderButton(
                //     action: () {
                //       updateNode(macAddress);
                //     },
                //     // shimmer: false,
                //     backgroundColor: Colors.redAccent,

                //     label: Text("DEPLOY NOW"),
                //     icon: Icon(
                //       Icons.device_hub,
                //       size: 44,
                //     ),
                //   ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
