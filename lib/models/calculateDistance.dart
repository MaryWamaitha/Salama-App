import 'dart:math';
bool isSafe;

class calculateDistance {
  //main tracking function that keeps track of user location relative to group destination
  bool trackingUser(lat1, lon1, lat2, lon2, double Distance) {
    bool active;
    var p = 0.017453292519943295;
    //method for calculating distance between two points
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    double distance = 12742 * asin(sqrt(a));
    distance = distance * 1000;
    if (distance > Distance) {
        isSafe = false;
    } else {
        isSafe = true;
    }
    // print('user isSafe is $isSafe');
    // print('distance is $distance');
    return isSafe;
  }
}