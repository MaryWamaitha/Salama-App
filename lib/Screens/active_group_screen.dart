import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salama/Screens/bottommenu.dart';
import 'package:salama/Screens/create_screen1.dart';
import 'package:salama/Screens/pin_menu.dart';
import 'package:salama/Screens/safe_word.dart';
import 'main_screen.dart';
import 'dart:math';
import '../constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salama/constants.dart';
import '../Components/icons.dart';
import 'package:workmanager/workmanager.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:salama/models/calculateDistance.dart';
import '../models/getUser.dart';
import 'package:salama/Screens/leave_group.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

final _firestore = FirebaseFirestore.instance;
String username;
String groupID;
String leaveGroup = '                         ';
User loggedInUser;
int minApprovals;
int safeTaps;
List<String> tokenIDList = [];
List<String> memberTokens = [];

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

//configuring oneSignel and setting the appID
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
  bool showSpinner = true;
  String userID;
  String groupName ='';
  LatLng destination;
  LatLng userLocation;
  double userLatitude;
  double userLongitude;
  double groupLatitude;
  double groupLongitude;
  String status;
  bool tracking ;
  double Distance = 0;
  String activeID;
  bool isSafe;
  bool sent = false;
  String place;
  bool indicator = true;
  getDetails Details = getDetails();
  static const backgroundTracking = "backgroundTracking";

  //the following function runs the activating function and also the tracking instructions if the app
  //is in the background
  void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      switch (task) {
        case backgroundTracking:
          getUserLocation();
          if (tracking == false) {
            Timer.periodic(Duration(seconds: 60), (timer) async {
              calculateDistance calcDist = calculateDistance();
              var value = calcDist.trackingUser(userLatitude, userLongitude,
                  groupLatitude, groupLongitude, 1000);
              //if the activity is now true, updating the tracking field in database and switching of timer
              if (value == true) {
                await _firestore
                    .collection("active_members")
                    .doc(activeID)
                    .update({
                  'tracking': true,
                });
                tracking = true;
                timer.cancel();
                var value = calcDist.trackingUser(userLatitude, userLongitude,
                    groupLatitude, groupLongitude, Distance);
                //if the user is not safe ( tracking User function returned a false)
                //the isSafe value is updated in the database as false ( this also changes the icon colour)
                if (value == false) {
                  await _firestore
                      .collection("active_members")
                      .doc(activeID)
                      .update({
                    'isSafe': false,
                  });
                  //this checks if the notification had been previously sent
                  //false means a  notification has not been sent and true means this particular instance of the notification has been sent
                  if (sent == false) {
                    triggerNotification();
                  }
                } else {
                  await _firestore
                      .collection("active_members")
                      .doc(activeID)
                      .update({
                    'isSafe': true,
                  });
                }
              }
            });
          } else {
            calculateDistance calcDist = calculateDistance();
            var value = calcDist.trackingUser(userLatitude, userLongitude,
                groupLatitude, groupLongitude, Distance);
            //if the user is not safe ( tracking User function returned a false)
            //the isSafe value is updated in the database as false ( this also changes the icon colour)
            if (value == false) {
              await _firestore
                  .collection("active_members")
                  .doc(activeID)
                  .update({
                'isSafe': false,
              });
              //this checks if the notification had been previously sent
              //false means a  notification has not been sent and true means this particular instance of the notification has been sent
              if (sent == false) {
                triggerNotification();
              }
            } else {
              await _firestore
                  .collection("active_members")
                  .doc(activeID)
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

  //uses logged in user email to get their username
  void getUserDetails() async {
    try {
      //accessing the user details from the getUser Class
      //this returns a list of document snapshots
      List<DocumentSnapshot> result = await Details.getUserDetail();
      if (result.length > 0) {
        //changing the returned data to a map so that we can read it
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
        //using the returned username to get the user record in the active_members table
        final QuerySnapshot user = await _firestore
            .collection('active_members')
            .where('username', isEqualTo: username)
            .get();
        //once we find the record, we get the groupID from it. The group ID is used in loading the stream
        final List<DocumentSnapshot> groupDets = user.docs;
        activeID = groupDets[0].id;
        var record = groupDets[0].data() as Map;
        groupID = record['gid'];
        tracking = record['tracking'];
        var Notifystatus = await OneSignal.shared.getDeviceState();
        String tokenId = Notifystatus.userId;
        print('the user active is $record');
        getGroupDetails();
        activateTimer();
      }
    } catch (e) {
      print(e);
    }
  }

  void Indicator() {
    Timer.periodic(Duration(seconds: 3), (timer) async {
      setState(() {
        indicator = false;
      });
      timer.cancel();
    });
  }

  //method for getting user location from database and updating it locally
  Future <LatLng> getUserLocation() async {
      //this returns a list of document snapshots with user record from user table
      List<DocumentSnapshot> result = await Details.getUserDetail();
      if (result.length > 0) {
        //changing the returned data to a map so that we can read it
        var x = result[0].data() as Map;
          //getting the user location from the database and putting it in a local variable
          userLocation =
              LatLng(x['location'].latitude, x['location'].longitude);
      }
      return userLocation;
  }

  //getting group details which are displayed on the page
  void getGroupDetails() async {
    //using the GID to get group details
    _firestore
        .collection('groups')
        .doc(groupID)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        final details = documentSnapshot.data() as Map;
        setState(() {
          // assigning the groupName and other variables to the values from the database
          groupName = details['Name'];
          place = details['Destination'];
          Distance = details['Distance'];
          destination = LatLng(
              details['Location'].latitude,
              details['Location'].longitude);
          groupLatitude = destination.latitude;
          groupLongitude = destination.longitude;
          print('group Lat is $destination');
        });

      }
    });
  }

  //if a user is unsafe, this function is run
  //the function uses the group ID to get a list of all active_mmebers with the same groupID
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

  //every 2 minute, check if the user has arrived at location
  //once the activity is set to true, this timer stops working
  //checks user location when group is created compared to destination and either marks tracking as true
  //or false. true means you are now at location and tracking can begin. False means that you are not
  //yet at location and tracking cannot begin
  void activateTimer() {
    if(tracking == false) {
      Timer.periodic(Duration(minutes: 2), (timer) async {
        calculateDistance calcDist = calculateDistance();
        var userCoord = await getUserLocation();
        userLatitude = userCoord.latitude;
        userLongitude = userCoord.longitude;
        bool active;
        var p = 0.017453292519943295;
        //method for calculating distance between two points
        var a = 0.5 -
            cos((groupLatitude - userLatitude) * p) / 2 +
            cos(userLatitude * p) * cos(groupLatitude * p) *
                (1 - cos((groupLongitude - userLongitude) * p)) / 2;
        double distance = 12742 * asin(sqrt(a));
        distance = distance * 1000;
        if (distance > 500) {
          active = false;
        } else {
          active = true;
        }
        //if the activity is now true, updating the tracking field in database and switching of timer
        print('the activating is $active and the distance is $distance');
        if (active == true) {
          //set the tracking to true in database
          await _firestore.collection("active_members").doc(activeID).update({
            'tracking': true,
          });
          tracking = true;
          //cancelling the activating timer
          timer.cancel();
          trackingTimer();
        }
      });
    } else {
      trackingTimer();
    }
  }

  //function that runs every 60 seconds and checks if you are still at location
  void trackingTimer() {
    print('tracking is true');
    Timer.periodic(Duration(seconds: 60), (timer) async {
      print('timer cameon');
      LatLng userCoord = await getUserLocation();
      userLatitude = userCoord.latitude;
      userLongitude=userCoord.longitude;
      print ('coordinates are $userCoord');
      bool active;
      var p = 0.017453292519943295;
      //method for calculating distance between two points
      var a = 0.5 -
          cos((groupLatitude - userLatitude) * p) / 2 +
          cos(userLatitude * p) * cos(groupLatitude * p) * (1 - cos((groupLongitude - userLongitude) * p)) / 2;
      double distance = 12742 * asin(sqrt(a));
      double dist = distance * 1000;
      print('distance is $dist');
      if (dist > Distance) {
        active = false;
      } else {
        active = true;
      }
      //if the user is not safe is now true, updating the isSafe value in DB
      print('the user safety is $active and the distance is $distance and the set distane is $Distance');
      if (active == false) {
        await _firestore.collection("active_members").doc(activeID).update({
          'isSafe': false,
        });
        //this checks if the notification had been previously sent
        //false means a  notification has not been sent and true means this particular instance of the notification has been sent
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
    sendSafetyNotifications();
    sent = true;
  }

  //the following functions are run when the screen is initialized
  @override
  void initState() {
    super.initState();
    configOneSignel();
    Indicator();
    getUserDetails();
    getGroupDetails();
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );

    Workmanager().registerPeriodicTask(
      "1",
      backgroundTracking,
      frequency: Duration(minutes: 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColour,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: AppBar(
            automaticallyImplyLeading: false,
            title: Center(
              child: Padding(
                padding: EdgeInsets.only(top: 50.0, bottom: 20),
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
      //if the user status is active, the UI loads stream, leave group button etc
      body: status == 'active'
          ? SafeArea(
          child:
          indicator == false ?
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child:
                      Text('Group: $groupName', style: kMajorHeadings),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_pin,),
                        Text('$place', style: TextStyle(
                          fontSize: 14,
                        )),
                      ],
                    ),
                  ],
                ),
              ),
              MembersStream(),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, SafeWord.id);
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(60.0, 0, 60, 0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: kMainColour,
                        borderRadius: new BorderRadius.all(
                          const Radius.circular(30.0),
                        )),
                    height: 50,
                    width: 200.00,
                    child: Center(
                      child: Text(
                        'View Group Safe Word',
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
                    width: 170.00,
                    child: Center(
                      child: Text(
                        'Leave Group',
                        style: TextStyle(
                          color: kMainColour,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ) : Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top:
                  60, left: 40),
                  child: Row(
                    children: [
                      Text('Loading Group'),
                      CircularProgressIndicator(
                        color: Colors.amberAccent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
      )
      //if the user is not active in any group, they are informed that they are not in any group
          : Padding(
        padding: EdgeInsets.only(top: 40),
        child: Container(
          color: kBackgroundColour,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                  child: Container(
                    color: kMainColour,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('images/create.png'),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Text(
                              'You are not in any group. Click the button below to create a group ',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HomePage(currentIndex: 2)),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                60.0, 0, 60, 0),
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
                                  'Create a group',
                                  style: TextStyle(
                                    color: kMainColour,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        //getting the length of the snapshot ( number of records) to determine the minApprovals
        var number = members.length;
        //if the number is greater than or equal to 2, the minApprovals are 2 else the minApprovals are 1
        if (number >= 2) {
          minApprovals = 2;
        } else {
          minApprovals = 1;
        }

        //loop through the returned snapshot and on each instance, get the username, safety status
        //userID and use the username
        List<MemberStatus> MembersStatuses = [];
        for (var member in members) {
          final memberUname = member['username'];
          final memberSafety = member['isSafe'];
          final memberID = member.id;
          //function uses the username to get the tokenID from the user table
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
          bool tapped = false;

          //pass the values from the previous step to the MemberStatus widget
          final memberStatus = MemberStatus(
            member: memberUname,
            isSafe: memberSafety,
            isMe: username == memberUname,
            memberID: memberID,
            getDetails: getMemberDetails,
            tapped: tapped,
          );

          //add the MemmberStatus widget to a list made up of memberStatus widgets
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
//ignore: must_be_immutable
class MemberStatus extends StatelessWidget {
  MemberStatus(
      {this.member, this.isSafe, this.isMe, this.memberID,
        this.tapped, this.getDetails});

  final String memberID;
  final String member;
  final bool isSafe;
  final bool isMe;
  final void getDetails;
  bool tapped;

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
          //if the user is safe, show a green check box and if not a red alert
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

          isMe == false && isSafe == false
              ? TextButton(
            onPressed: () async {
              //accessing the safeTaps collection which is nested in groups
              final QuerySnapshot safeDetails = await _firestore
                  .collection('groups')
                  .doc(groupID)
                  .collection('safeTaps')
                  .where('username', isEqualTo: member)
                  .get();
              final List<DocumentSnapshot> selected = safeDetails.docs;
              var result = selected[0].data() as Map;
              var safeID = selected[0].id;
              safeTaps = result['safeTaps'];
              print( 'the safe taps are $safeTaps');
              //checks if the button has already been clicked for this user to avoid one person clicking for both safeTaps
              if (tapped == false) {
                //if the button has not been clicked, increses the safeTaps by 1 and sets the tapped to true such that the user cannot click this again
                safeTaps = safeTaps + 1;
                tapped = true;
                //if the safe taps are no equal to or greater than the min approvals, the user who was unsafe is now marked as safe, their safeTaps at
                if (safeTaps >= minApprovals) {
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
                  //sending notifications using the tokenID from the getMemberDetails function that was passed
                  _handleSendNotification(
                      tokenIDList,
                      '$username marked $member as safe',
                      '$member had moved too far and $username has marked them as safe. \n');
                } else {
                  //if the safe Taps are not equal to minimum approvals, , update the users safe Tap number and alert the person who clicked that
                  //more safe taps are required.
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
                          'Please note that another member is required to click this for the user to be marked as safe'),
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
                  //sending notifications to the rest of the group on more safe taps being needed.
                  _handleSendNotification(
                      tokenIDList,
                      '$username marked $member as safe',
                      '$member had moved too far and $username has marked them as safe. \n If you are sure they are safe, please log in and click safe ignore on \n active group page ');
                }
                //if the user had already clicked the button, they are alerted that they cannot click it again
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