import 'package:ele_deploy/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FCMService() {
    x();
  }

  x() async {
    FirebaseApp f = FirebaseApp.instance;
    print(f.name);
    _firebaseMessaging.getToken().then(print);

    _firebaseMessaging.setAutoInitEnabled(true);
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        HomePage.show(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }
}
