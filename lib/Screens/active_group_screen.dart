import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_screen.dart';
import '../constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salama/constants.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

final _firestore = FirebaseFirestore.instance;
String username;
String groupID;
String leaveGroup = '                         ';

class ActiveGroup extends StatefulWidget {
  static String id = 'active_group_screen';
  @override
  _ActiveGroupState createState() => _ActiveGroupState();
}

class _ActiveGroupState extends State<ActiveGroup> {
  final _auth = FirebaseAuth.instance;
  String sender;
  bool showSpinner = false;
  String groupName;
  LatLng destination;
  LatLng userLocation;
  double userLatitude;
  double userLongitude;
  double groupLatitude;
  double groupLongitude;
  String status;
  double Distance;

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
              status = x['status'];
              username = x['username'];
              userLocation =
                  LatLng(x['location'].latitude, x['location'].longitude);
              userLatitude = x['location'].latitude;
              userLongitude = x['location'].longitude;
            });

                print('username is $username');
                print('status is $status');
                print('initial location is $userLocation');
                getGroupDetails();
                getUserLocation();
              }

      }
    } catch (e) {
      print(e);
    }
  }

  void startLocating (){
    Timer.periodic(Duration(seconds: 20), (timer) async {
      getUserLocation();
    });
  }

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
            userLocation =
                LatLng(x['location'].latitude, x['location'].longitude);
            userLatitude = x['location'].latitude;
            userLongitude = x['location'].longitude;
          });
          //every ten seconds, get the user location from the database
          print(' the location evben  when changed ois $userLocation');
        }


      }
    } catch (e) {
      print(e);
    }
  }



  //use username to get invite details like GID, sender etc
  void getGroupDetails() async {
    //getting the username which is used to get the users active group - user can only be in active group for one group
    final QuerySnapshot user = await _firestore
        .collection('active_members')
        .where('username', isEqualTo: username)
        .get();
    final List<DocumentSnapshot> selected = user.docs;
    var result = selected[0].data() as Map;
    print('Grpup details are $result');
    setState(() {
      groupID = result['gid'];
      sender = result['sender'];
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
          Distance = details['Distance'];
          groupLatitude = details['Location'].latitude;
          groupLongitude = details['Location'].longitude;
          destination = LatLng(
              details['Location'].latitude, details['Location'].longitude);
          print(' destination is $destination');
        });
      }
    });
  }

  //track user function
  void activity() {
    Timer.periodic(Duration(seconds: 60), (timer)  {
      trackUser(userLatitude, userLongitude, groupLatitude, groupLongitude);
    });
  }

  void trackUser(lat1, lon1, lat2, lon2) {
    bool active;

    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    double distance = 12742 * asin(sqrt(a));
    if (distance < 2) {
      active = true;
      // Timer.periodic(Duration(seconds: 30), (timer) {});
    } else {
      active = false;
    }
    print('activity is $active');

    print('distance is $distance');
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
    activity();
    startLocating();
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
                    'ACTIVE GROUPS',
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
                      MembersStream(),

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
        List<MemberStatus> MembersStatuses = [];
        for (var member in members) {
          final memberUname = member['username'];
          final memberSafety = member['isSafe'];

          final currentUser = loggedInUser.email;

          final memberStatus = MemberStatus(
            member: memberUname,
            isSafe: memberSafety,
            isMe: username == memberUname,
          );

          MembersStatuses.add(memberStatus);
        }
        return Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: MembersStatuses,
          ),
        );
      },
    );
  }
}

class MemberStatus extends StatelessWidget {
  MemberStatus({this.member, this.isSafe, this.isMe});

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
          Column(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('images/profile.jpg'),
                radius: 20,
              ),
              Text('$member'),
            ],
          ),
          isSafe == true
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.check_box,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                    // isMe == true ? Text('Leave Group') : Text(''),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.red,
                      size: 40,
                    ),
                    isMe == true ? Text('Leave Group') : Text(''),
                  ],
                ),
          isMe == true
              ? TextButton(
                  onPressed: () {
                    //TODO: When user clicks leave group, show Pin screen requesting pin to process leaving
                  },
                  child: Text('Exit Group'),
                )
              : Text('$leaveGroup'),
        ],
      ),
    );
  }
}
