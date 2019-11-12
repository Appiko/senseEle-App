import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ele_deploy/locators.dart';
import 'package:ele_deploy/services/hasura_service.dart';
import 'package:ele_deploy/services/location/location_service.dart';
import 'package:ele_deploy/services/offline_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:hasura_connect/hasura_connect.dart';
import 'package:location/location.dart';

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

  updateNode(String macAddress) async {
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
    String query = """
        mutation {
         insert_node(objects: {deployment: "3cb9fa15-17b1-4141-82d2-1cfd40e48ff8", id: "$macAddress", location: "(${locationData.latitude},${locationData.longitude})", number: 10, accuracy: "${locationData.accuracy}", deployed_on: "${DateTime.now()}"}) {
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
        print(locator<HasuraService>().mutate(query));
      }
    } on SocketException {
      print('Not connected; Writing to file');
      locator<OfflineStorageService>().storeInFile(query);
    } on Exception {
      print("WRONG!");
    }

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

  @override
  Widget build(BuildContext context) {
    print("rebuilding");
    String macAddress = getFakeMacAddress();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                setState(() {});
              },
              child: Text("REFRESH"),
            ),
            Text("MAC ADDRESS: $macAddress"),
            isDeploying
                ? CircularProgressIndicator(
                    strokeWidth: 5,
                  )
                : RaisedButton(
                    onPressed: () => updateNode(macAddress),
                    child: Text("deploy"),
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
    );
  }
}
