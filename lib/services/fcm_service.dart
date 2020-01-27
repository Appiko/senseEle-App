import 'package:ele_deploy/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FCMService() {
    x();
  }

  x() async {
    _firebaseMessaging.subscribeToTopic("all");

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
