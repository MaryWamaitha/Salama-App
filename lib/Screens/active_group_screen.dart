import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_screen.dart';
import '../constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salama/constants.dart';
import '../Components/icons.dart';
import 'package:workmanager/workmanager.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../models/calculateDistance.dart';
import '../models/getUser.dart';
import 'package:salama/Screens/leave_group.dart';

final _firestore = FirebaseFirestore.instance;
String username;
String groupID;
String leaveGroup = '                         ';
User loggedInUser;
int minApprovals;
int safeTaps;
bool tapped = false;
List<String> tokenIDList = [];
List<String> memberTokens = [];

//sending notifications
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

void configOneSignel() {
  OneSignal.shared.setAppId("25effc79-b2cc-460d-a1d0-dfcc7cb65146");
}

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
  bool sent = false;
  String place;
  calculateDistance calcDist = calculateDistance();
  getDetails Details = getDetails();
  static const fetchBackground = "fetchBackground";

  void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      switch (task) {
        case fetchBackground:
          activateTimer();
          break;
      }
      return Future.value(true);
    });
  }

  //uses logged in user email to get their username
  void getUserDetails() async {
    try {
      List<DocumentSnapshot> result = await Details.getUserDetail();
      if (result.length > 0) {
        var x = result[0].data() as Map;
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
          place = details['Destination'];
          Distance = details['Distance'] * 1000;
          groupLatitude = details['Location'].latitude;
          groupLongitude = details['Location'].longitude;
          destination = LatLng(
              details['Location'].latitude, details['Location'].longitude);
        });
      }
    });
  }

  void sendNotifications() async {
    final QuerySnapshot user = await _firestore
        .collection('active_members')
        .where('gid', isEqualTo: groupID)
        .get();
    final List<DocumentSnapshot> selected = user.docs;
    var i = 0;
    while (i < selected.length) {
      var result = selected[i].data() as Map;
      var uname = result['username'];
      final QuerySnapshot userTable = await _firestore
          .collection('users')
          .where('username', isEqualTo: uname)
          .get();
      final List<DocumentSnapshot> value = user.docs;
      var output = value[0].data() as Map;
      var token = output['tokenID'];
      memberTokens.add(token);
      _handleSendNotification(memberTokens, '$username is unsafe. ',
          '$username has moved away from $place beyond specified distance. Please check in');
    }
  }

  //TODO: CHange this to every 2 minutes
  //every minute, check if the user has arrived at location
  //once the activity is set to true, this timer stops working
  //checks user location when group is created compared to destination and either marks tracking as true
  //or false. true means you are now at location and tracking can begin. False means that you are not
  //yet at location and tracking cannot begin
  void activateTimer() {
    print(' the use is beibg tracked $tracking');
    if (tracking == false) {
      Timer.periodic(Duration(seconds: 60), (timer) async {
        var value = calcDist.trackingUser(
            userLatitude, userLongitude, groupLatitude, groupLongitude, 1000);
        //if the activity is now true, updating the tracking field in database and switching of timer
        if (value == true) {
          await _firestore.collection("active_members").doc(activeID).update({
            'tracking': true,
          });
          tracking = true;
          timer.cancel();
          trackingTimer();
          print('value is updateed and timer cancelled $tracking');
        }
      });
    } else {
      trackingTimer();
      // print('value is updateed and timer cancelled $tracking');
    }
  }

  //function that runs every 30 seconds and checks if you are still at location
  void trackingTimer() {
    Timer.periodic(Duration(seconds: 30), (timer) async {
      var value = calcDist.trackingUser(
          userLatitude, userLongitude, groupLatitude, groupLongitude, Distance);
      print(' the safety value is $value');
      //if the activity is now true, updating the tracking field in database and switching of timer
      if (value == false) {
        await _firestore.collection("active_members").doc(activeID).update({
          'isSafe': false,
        });
        if (sent == false) {
          triggerNotification();
        }
      } else {
        await _firestore.collection("active_members").doc(activeID).update({
          'isSafe': true,
        });
      }
    });
  }

  void triggerNotification() {
    sendNotifications();
    sent = true;
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
    getGroupDetails();
    activateTimer();
    startLocating();
    configOneSignel();
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );

    Workmanager().registerPeriodicTask(
      "1",
      fetchBackground,
      frequency: Duration(minutes: 15),
    );
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
                        onPressed: () {
                          Navigator.pushNamed(context, LeaveGroup.id);
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
          void getMemberDetails() async {
            final QuerySnapshot activity = await _firestore
                .collection('users')
                .where('username', isEqualTo: memberUname)
                .get();
            final List<DocumentSnapshot> selected = activity.docs;
            final x = selected[0].data() as Map;
            var token = x['tokenID'];
            tokenIDList.add(token);
          }

          final memberStatus = MemberStatus(
            member: memberUname,
            isSafe: memberSafety,
            isMe: username == memberUname,
            memberID: memberID,
            getDetails: getMemberDetails,
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
  MemberStatus(
      {this.member, this.isSafe, this.isMe, this.memberID, this.getDetails});

  final String memberID;
  final String member;
  final bool isSafe;
  final bool isMe;
  final void getDetails;

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
                    //accessing the safeTaps collection which is nested in groups
                    final QuerySnapshot safeDetails = await _firestore
                        .collection('active_members')
                        .doc(groupID)
                        .collection('safeTaps')
                        .where('username', isEqualTo: member)
                        .get();
                    final List<DocumentSnapshot> selected = safeDetails.docs;
                    var result = selected[0].data() as Map;
                    var safeID = selected[0].id;
                    safeTaps = result['safeTaps'];
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
                            .collection('safeTaps')
                            .doc(safeID)
                            .update({
                          'safeTaps': 0,
                        });
                        _handleSendNotification(
                            tokenIDList,
                            '$username marked $member as safe',
                            '$member had moved too far and $username has marked them as safe. \n If you are sure they are safe, please log in and click safe ignore on \n active group page ');
                      } else {
                        await _firestore
                            .collection("groups")
                            .doc(groupID)
                            .collection('safeTaps')
                            .doc(safeID)
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
                        _handleSendNotification(
                            tokenIDList,
                            '$username marked $member as safe',
                            '$member had moved too far and $username has marked them as safe. \n If you are sure they are safe, please log in and click safe ignore on \n active group page ');
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
