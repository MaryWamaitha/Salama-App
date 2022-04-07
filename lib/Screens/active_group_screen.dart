import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_screen.dart';
import '../constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salama/constants.dart';
import '../Components/icons.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';

final _firestore = FirebaseFirestore.instance;
String username;
String groupID;
String leaveGroup = '                         ';
User loggedInUser;
int minApprovals;
int safeTaps;
bool tapped = false;

class ActiveGroup extends StatefulWidget {
  static String id = 'active_group_screen';

  @override
  _ActiveGroupState createState() => _ActiveGroupState();
}

class _ActiveGroupState extends State<ActiveGroup> {
  final _auth = FirebaseAuth.instance;
  String sender;
  bool showSpinner = false;
  String userID;
  String groupName;
  LatLng destination;
  LatLng userLocation;
  double userLatitude;
  double userLongitude;
  double groupLatitude;
  double groupLongitude;
  String status;
  bool tracking = false;
  double Distance;
  String activeID;
  bool isSafe;
  List<String> tokenIDList = ['eade7dcc-c9f4-4aa9-a4fd-7224e235a4ef'];

  //sending notifications
  void _handleSendNotification() async {
    var deviceState = await OneSignal.shared.getDeviceState();

    if (deviceState == null || deviceState.userId == null) return;

    var playerId = 'eade7dcc-c9f4-4aa9-a4fd-7224e235a4ef';

    var imgUrlString =
        "http://cdn1-www.dogtime.com/assets/uploads/gallery/30-impossibly-cute-puppies/impossibly-cute-puppy-2.jpg";

    var notification = OSCreateNotification(
        playerIds: [playerId],
        content: "this is a test from OneSignal's Flutter SDK",
        heading: "Test Notification",
        iosAttachments: {"id1": imgUrlString},
        bigPicture: imgUrlString,
        buttons: [
          OSActionButton(text: "test1", id: "id1"),
          OSActionButton(text: "test2", id: "id2")
        ]);

    var response = await OneSignal.shared.postNotification(notification);
  }

  //uses logged in user email to get their username
  void getUserDetails() async {
    //once a user is registered or logged in then this current user will have  a variable
    //the current user will be null if nobody is signed in
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        var member1 = loggedInUser.email;
        final QuerySnapshot activity = await _firestore
            .collection('users')
            .where('email', isEqualTo: member1)
            .get();
        final List<DocumentSnapshot> selected = activity.docs;
        //TODO: What happens if invite does not exist
        if (selected.length > 0) {
          var x = selected[0].data() as Map;
          setState(() {
            userID = selected[0].id;
            status = x['status'];
            username = x['username'];
            userLocation =
                LatLng(x['location'].latitude, x['location'].longitude);
            userLatitude = x['location'].latitude;
            userLongitude = x['location'].longitude;
          });
          var Notifystatus = await OneSignal.shared.getDeviceState();
          String tokenId = Notifystatus.userId;
          print(' the token ID is $tokenId');
          // print('username is $username');
          // print('userID is $userID');
          // print('status is $status');
          // print('initial location is $userLocation');
          getUserLocation();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  //every 20 seconds, get the user location from the database
  void startLocating() {
    Timer.periodic(Duration(seconds: 20), (timer) async {
      getUserLocation();
    });
  }

  void configOneSignel() {
    OneSignal.shared.setAppId("25effc79-b2cc-460d-a1d0-dfcc7cb65146");
  }

  //method for getting user location and updating it locally
  void getUserLocation() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        var member1 = loggedInUser.email;
        final QuerySnapshot activity = await _firestore
            .collection('users')
            .where('email', isEqualTo: member1)
            .get();
        final List<DocumentSnapshot> selected = activity.docs;
        if (selected.length > 0) {
          var x = selected[0].data() as Map;

          setState(() {
            userID = selected[0].id;
            userLocation =
                LatLng(x['location'].latitude, x['location'].longitude);
            userLatitude = x['location'].latitude;
            userLongitude = x['location'].longitude;
          });
          // print(' the location evben  when changed ois $userLocation');
        }
      }
    } catch (e) {
      print(e);
    }
  }

  //use username to get invite details like GID, sender etc
  void getGroupDetails() async {
    //getting the username which is used to get the users active group - user can only be in one active group for one group
    final QuerySnapshot user = await _firestore
        .collection('active_members')
        .where('username', isEqualTo: username)
        .get();
    final List<DocumentSnapshot> selected = user.docs;
    var result = selected[0].data() as Map;

    print('Group details are $result');
    setState(() {
      groupID = result['gid'];
      tracking = result['tracking'];
      sender = result['sender'];
      activeID = selected[0].id;
      // print('the active ID is $activeID');
    });
    //using the GID to get group details
    FirebaseFirestore.instance
        .collection('groups')
        .doc(groupID)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        final details = documentSnapshot.data() as Map;
        setState(() {
          groupName = details['Name'];
          Distance = details['Distance'] * 1000;
          safeTaps = details['safeTaps'];
          groupLatitude = details['Location'].latitude;
          groupLongitude = details['Location'].longitude;
          destination = LatLng(
              details['Location'].latitude, details['Location'].longitude);
        });
      }
    });
  }

  //TODO: CHange this to every 2 minutes
  //every minute, check if the user has arrived at location
  //once the activity is set to true, this timer stops working
  void activateTimer() {
    // print(' the use is beibg tracked $tracking');
    if (tracking == false) {
      Timer.periodic(Duration(seconds: 60), (timer) async {
        var value = initializeTracking(
            userLatitude, userLongitude, groupLatitude, groupLongitude);
        //if the activity is now true, updating the tracking field in database and switching of timer
        if (value == true) {
          await _firestore.collection("active_members").doc(activeID).update({
            'tracking': true,
          });
          timer.cancel();
          trackingTimer();
          print('value is updateed and timer cancelled');
        }
      });
    } else {
      trackingTimer();
    }
  }

  //checks user location when group is created compared to destination and either marks tracking as true
  //or false. true means you are now at location and tracking can begin. False means that you are not
  //yet at location and tracking cannot begin
  bool initializeTracking(lat1, lon1, lat2, lon2) {
    bool active;
    var p = 0.017453292519943295;
    //method for calculating distance between two points
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    double distance = 12742 * asin(sqrt(a));
    distance = distance * 1000;
    if (distance < 1000) {
      active = true;
    } else {
      active = false;
    }
    // print('activity is $active');
    // print('distance is $distance');
    return active;
  }

  //function that runs every 30 seconds and checks if you are still at location
  void trackingTimer() {
    Timer.periodic(Duration(seconds: 30), (timer) async {
      var value = trackingUser(
          userLatitude, userLongitude, groupLatitude, groupLongitude);
      //if the activity is now true, updating the tracking field in database and switching of timer
      if (value == false) {
        await _firestore.collection("active_members").doc(activeID).update({
          'isSafe': false,
        });
        //TODO: This will run until the user either enters pin or multiple group members say that user is safe
        print('value is updateed and timer cancelled');
      } else {
        await _firestore.collection("active_members").doc(activeID).update({
          'isSafe': true,
        });
      }
    });
  }

  //main tracking function that keeps track of user location relative to group destination
  bool trackingUser(lat1, lon1, lat2, lon2) {
    bool active;
    var p = 0.017453292519943295;
    //method for calculating distance between two points
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    double distance = 12742 * asin(sqrt(a));
    distance = distance * 1000;
    if (distance > Distance) {
      setState(() {
        isSafe = false;
      });
    } else {
      setState(() {
        isSafe = true;
      });
    }
    // print('user isSafe is $isSafe');
    // print('distance is $distance');
    return isSafe;
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
    getGroupDetails();
    activateTimer();
    startLocating();
    configOneSignel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kBackgroundColour,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(120.0),
            child: AppBar(
              automaticallyImplyLeading: false,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(120),
                  bottomRight: Radius.circular(120),
                ),
              ),
              title: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50.0, bottom: 10),
                  child: Text(
                    'ACTIVE GROUP',
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
              backgroundColor: kMainColour,
            )),
        body: status == 'active'
            ? SafeArea(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child:
                              Text('Group: $groupName', style: kMajorHeadings),
                        ),
                      ),
                      MembersStream(),
                      TextButton(
                        onPressed: () async {
                          _handleSendNotification();
                          // //TODo: Add pin interface before removing user
                          // await _firestore
                          //     .collection("active_members")
                          //     .doc(activeID)
                          //     .delete();
                          // await _firestore
                          //     .collection("users")
                          //     .doc(userID)
                          //     .update({
                          //   'status': 'inactive',
                          // });
                          // Navigator.pushNamed(context, MainScreen.id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(60.0, 30, 60, 60),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.amberAccent,
                                borderRadius: new BorderRadius.all(
                                  const Radius.circular(30.0),
                                )),
                            height: 50,
                            width: 150.00,
                            child: Center(
                              child: Text(
                                'Leave Group',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Menu(),
                    ]),
              )
            : Text('Not in any group'));
  }
}

class MembersStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('active_members')
          .where('gid', isEqualTo: groupID)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            //TODO: What happens when there is no active group
            child: Text(
              'No active groups',
            ),
          );
        }
        final members = snapshot.data.docs.reversed;
        var number = members.length;
        if (number > 2) {
          minApprovals = 2;
        } else {
          minApprovals = 2;
        }

        List<MemberStatus> MembersStatuses = [];
        for (var member in members) {
          final memberUname = member['username'];
          final memberSafety = member['isSafe'];
          final memberID = member.id;

          final memberStatus = MemberStatus(
            member: memberUname,
            isSafe: memberSafety,
            isMe: username == memberUname,
            memberID: memberID,
          );

          MembersStatuses.add(memberStatus);
        }
        return Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            children: MembersStatuses,
          ),
        );
      },
    );
  }
}

class MemberStatus extends StatelessWidget {
  MemberStatus({this.member, this.isSafe, this.isMe, this.memberID});

  final String memberID;
  final String member;
  final bool isSafe;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('images/profile.jpg'),
                  radius: 20,
                ),
                Text('$member'),
                isMe == true ? (Text('(Me)')) : Text('')
              ],
            ),
          ),
          isSafe == true
              ? Icon(
                  Icons.check_box,
                  color: Colors.green,
                  size: 40,
                )
              : Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 40,
                ),
          // isSafe== false  ? Text('Safe(Ignore)') : Text('$leaveGroup'),
          isMe == false && isSafe == false
              ? TextButton(
                  onPressed: () async {
                    if (tapped == false) {
                      safeTaps = safeTaps + 1;
                      tapped = true;
                      if (safeTaps >= minApprovals) {
                        print(' safe Taps is true');
                        await _firestore
                            .collection("active_members")
                            .doc(memberID)
                            .update({
                          'isSafe': true,
                        });
                        await _firestore
                            .collection("groups")
                            .doc(groupID)
                            .update({
                          'safeTaps': safeTaps,
                        });
                      } else {
                        await _firestore
                            .collection("groups")
                            .doc(groupID)
                            .update({
                          'safeTaps': safeTaps,
                        });
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(' Safety Alert'),
                            content: Text(
                                'Please note that another member is required to click \n this for the user to be marked as safe'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                                child: Text('Okay'),
                              )
                            ],
                          ),
                        );
                      }
                    } else {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(' Already clicked'),
                          content: Text(
                              'Please note that you have already clicked the button and cant click again'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                              },
                              child: Text('Okay'),
                            )
                          ],
                        ),
                      );
                    }
                  },
                  child: Text('Safe(Ignore)'),
                )
              : Text('$leaveGroup'),
        ],
      ),
    );
  }
}
