import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:salama/models/calculateDistance.dart';
import 'package:salama/models/getUser.dart';
import 'package:workmanager/workmanager.dart';

class Backgroundwork {
  static const backgroundTracking = "backgroundTracking";
  static final List<Backgroundwork> _cache = [];
  final _firestore = FirebaseFirestore.instance;
  bool tracking;
  double userLatitude;
  double userLongitude;
  double groupLatitude;
  double groupLongitude;
  getDetails Details;
  double Distance;
  bool sent;
  String groupID;
  List<String> memberTokens;
  String username;
  String activeID;
  String place;

  factory Backgroundwork() {
    if (_cache.isEmpty) _cache.add(Backgroundwork._());

    return _cache.first;
  }

  Backgroundwork._() {
    Details = getDetails();
    sent = false;
    tracking = false;
  }

  static void callbackDispatcher() {
    Backgroundwork work = Backgroundwork();
    Workmanager().executeTask((task, inputData) async {
      switch (task) {
        case backgroundTracking:
          work.getUserLocation();
          if (work.tracking == false) {
            Timer.periodic(Duration(seconds: 60), (timer) async {
              calculateDistance calcDist = calculateDistance();
              var value = calcDist.trackingUser(
                  work.userLatitude,
                  work.userLongitude,
                  work.groupLatitude,
                  work.groupLongitude,
                  1000);
              //if the activity is now true, updating the tracking field in database and switching of timer
              if (value == true) {
                await work._firestore
                    .collection("active_members")
                    .doc(work.activeID)
                    .update({
                  'tracking': true,
                });
                work.tracking = true;
                timer.cancel();
                var value = calcDist.trackingUser(
                    work.userLatitude,
                    work.userLongitude,
                    work.groupLatitude,
                    work.groupLongitude,
                    work.Distance);
                //if the user is not safe ( tracking User function returned a false)
                //the isSafe value is updated in the database as false ( this also changes the icon colour)
                if (value == false) {
                  await work._firestore
                      .collection("active_members")
                      .doc(work.activeID)
                      .update({
                    'isSafe': false,
                  });
                  //this checks if the notification had been previously sent
                  //false means a  notification has not been sent and true means this particular instance of the notification has been sent
                  if (work.sent == false) {
                    work.triggerNotification();
                  }
                } else {
                  await work._firestore
                      .collection("active_members")
                      .doc(work.activeID)
                      .update({
                    'isSafe': true,
                  });
                }
              }
            });
          } else {
            calculateDistance calcDist = calculateDistance();
            var value = calcDist.trackingUser(
                work.userLatitude,
                work.userLongitude,
                work.groupLatitude,
                work.groupLongitude,
                work.Distance);
            //if the user is not safe ( tracking User function returned a false)
            //the isSafe value is updated in the database as false ( this also changes the icon colour)
            if (value == false) {
              await work._firestore
                  .collection("active_members")
                  .doc(work.activeID)
                  .update({
                'isSafe': false,
              });
              //this checks if the notification had been previously sent
              //false means a  notification has not been sent and true means this particular instance of the notification has been sent
              if (work.sent == false) {
                work.triggerNotification();
              }
            } else {
              await work._firestore
                  .collection("active_members")
                  .doc(work.activeID)
                  .update({
                'isSafe': true,
              });
            }
          }
          break;
      }
      return Future.value(true);
    });
  }

  Future<LatLng> getUserLocation() async {
    //this returns a list of document snapshots with user record from user table
    List<DocumentSnapshot> result = await Details.getUserDetail();
    if (result.length > 0) {
      //changing the returned data to a map so that we can read it
      var x = result[0].data() as Map;
      //getting the user location from the database and putting it in a local variable
      userLocation = LatLng(x['location'].latitude, x['location'].longitude);
    }
    return userLocation;
  }

  void triggerNotification() {
    sendSafetyNotifications();
    sent = true;
  }

  void sendSafetyNotifications() async {
    final QuerySnapshot user = await _firestore
        .collection('active_members')
        .where('gid', isEqualTo: groupID)
        .get();
    final List<DocumentSnapshot> selected = user.docs;
    //looping through the returned list
    var i = 0;
    while (i < selected.length) {
      var result = selected[i].data() as Map;
      //accessing the username in each of the document snapshots and using the usernames to get the record from the user table
      var uname = result['username'];
      final QuerySnapshot userTable = await _firestore
          .collection('users')
          .where('username', isEqualTo: uname)
          .get();
      final List<DocumentSnapshot> value = userTable.docs;
      var output = value[0].data() as Map;
      //accessing the tokenID which identifies user devices
      var token = output['tokenID'];
      //adding the token to an empty list ( oneSignel uses lists of tokenId)
      memberTokens.add(token);
      //sending notifications to the specific user
      _handleSendNotification(memberTokens, '$username is unsafe. ',
          '$username has moved away from $place beyond specified distance. Please check in');
      //incrementing the index and repeating process
      i++;
    }
  }

  //sending notifications using OneSignal
  void _handleSendNotification(
      List<String> playerID, String heading, String content) async {
    var deviceState = await OneSignal.shared.getDeviceState();

    if (deviceState == null || deviceState.userId == null) return;

    var imgUrlString =
        "http://cdn1-www.dogtime.com/assets/uploads/gallery/30-impossibly-cute-puppies/impossibly-cute-puppy-2.jpg";

    var notification = OSCreateNotification(
        playerIds: playerID,
        content: content,
        heading: heading,
        iosAttachments: {"id1": imgUrlString},
        bigPicture: imgUrlString);
    // buttons: [
    //   OSActionButton(text: "test1", id: "id1"),
    //   OSActionButton(text: "test2", id: "id2")
    // ]);
    var response = await OneSignal.shared.postNotification(notification);
  }
}
