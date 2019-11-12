import 'package:bottom_nav/bottom_nav.dart';
import 'package:ele_deploy/chart_page.dart';
import 'package:ele_deploy/deploy_page.dart';
import 'package:ele_deploy/locators.dart';
import 'package:ele_deploy/map_page.dart';
import 'package:ele_deploy/services/bluetooth/bluetooth_scan.dart';
import 'package:ele_deploy/services/connectivity_service.dart';
import 'package:ele_deploy/services/fcm_service.dart';
import 'package:ele_deploy/services/hasura_service.dart';
import 'package:ele_deploy/services/location/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

Future main() async {
  setupLocator(); // For inital class instances

  // Preferred Orientation - Potrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    MultiProvider(
      providers: <SingleChildCloneableWidget>[
        ChangeNotifierProvider.value(value: locator<LocationService>()),
        ChangeNotifierProvider.value(value: locator<BluetoothScanService>()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print("Rebuilding app");
    return MaterialApp(
      theme: ThemeData(),
      routes: {
        '/': (_) => HomePage(),
        '/deploy': (_) => DeployPage(),
        '/chart': (_) => ChartPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
  static Function(Map message) show;

  HomePage() {
    locator<ConnectivityService>().listen();
    locator<HasuraService>();
    locator<FCMService>();
  }
}

class _HomePageState extends State<HomePage> {
  int currentTab = 0;
  List<Widget> _views = [MapPage(), ChartPage()];
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    HomePage.show = (message) {
      print("showing dialog");
      showDialog(
              context: context,
              builder: (context) => AlertDialog(
                  title: Text("Alert"),
                  content: Text(message['notification']['body'].toString())))
          .catchError(print);
    };
    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        children: <Widget>[
          _views[currentTab],
          Positioned(
            top: 40,
            left: 24,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: IconButton(
                onPressed: () => scaffoldKey.currentState.openDrawer(),
                icon: Icon(Icons.menu),
              ),
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            SizedBox(height: 200),
            FlatButton(
              child: Text("Deploy"),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/deploy');
              },
            ),
            FlatButton(
                child: Text("About"),
                onPressed: () {
                  Navigator.pop(context);
                  showAboutDialog(context: context);
                })
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        index: currentTab,
        // backgroundColor: Colors.black,
        navBarHeight: 75.0,
        radius: 30.0,
        onTap: (i) {
          setState(() {
            currentTab = i;
          });
        },
        items: [
          BottomNavItem(
            icon: Icons.map,
            label: "Map",
            selectedColor: Colors.blue,
          ),
          BottomNavItem(
            icon: Icons.insert_chart,
            label: "Charts",
            selectedColor: Colors.orange,
          ),
        ],
      ),
    );
  }
}
