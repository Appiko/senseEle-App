import 'package:flutter/foundation.dart';
import 'package:location/location.dart';

class LocationService with ChangeNotifier {
  Location location = Location();

  bool lookForAccurateLocation = false;

  LocationData mostAccurateLocation;
  LocationData lessThanTen;

  LocationService() {
    _configureLocation();
  }

  _configureLocation() {
    location.changeSettings(
      accuracy: LocationAccuracy.NAVIGATION,
      distanceFilter: 0,
      interval: 1000,
    );
    location.onLocationChanged().listen(_locationChanged);
  }

  getLocation() async {
    int count = 0;

    try {
      lookForAccurateLocation = true;
      while (
          (mostAccurateLocation == null || mostAccurateLocation.accuracy > 6) &&
              count < 30) {
        count++;
        await Future.delayed(Duration(seconds: 1));
        mostAccurateLocation = await location.getLocation();
        if (mostAccurateLocation.accuracy < (lessThanTen?.accuracy ?? 10)) {
          lessThanTen = mostAccurateLocation;
        }

        print("${mostAccurateLocation?.accuracy?.toString() ?? 'da'}");
      }

      LocationData x = mostAccurateLocation.accuracy < 6
          ? mostAccurateLocation
          : lessThanTen;

      lookForAccurateLocation = false;
      mostAccurateLocation = null;
      lessThanTen = null;
      count = 0;

      return x;
    } catch (e) {
      print(e);
    }
  }

  _locationChanged(LocationData currentLocation) {}
}
