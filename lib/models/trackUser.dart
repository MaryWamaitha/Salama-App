import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class tracking {
  void activate (LatLng userLocation, LatLng destination){
    bool active ;
    double distanceInMeters;
    Timer.periodic(Duration(seconds: 60), (timer) {
      distanceInMeters = Geolocator.distanceBetween(userLocation.latitude, userLocation.longitude, destination.latitude, destination.latitude);
      if (distanceInMeters < 1){
        active = true;
        Timer.periodic(Duration(seconds: 30), (timer) {

        });
      }
      return active;
    });

  }

  void trackUser (){
    Timer.periodic(Duration(seconds: 30), (timer) {

    });
  }

}