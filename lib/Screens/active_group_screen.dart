import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_screen.dart';

import '../constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salama/constants.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

final _firestore = FirebaseFirestore.instance;

class ActiveGroup extends StatefulWidget {
  static String id = 'active_group_screen';
  @override
  _ActiveGroupState createState() => _ActiveGroupState();
}

class _ActiveGroupState extends State<ActiveGroup> {
  final _auth = FirebaseAuth.instance;
  String sender;
  String username;
  bool showSpinner = false;
  String groupName;
  LatLng destination;
  String groupID;
  double latitude;
  double longitude;


  //uses logged in user email to get their username
  void getCurrentUser() async {
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
        if (selected.length > 0){
          var x = selected[0].data() as Map;
          username = x['username'];
        }

      }
    } catch (e) {
      print(e);
    }
  }

  //use username to get invite details like GID, sender etc
  void getDetails() async {
    final QuerySnapshot invite = await _firestore
        .collection('invites')
        .where('username', isEqualTo: username)
        .get();
    final List<DocumentSnapshot> selected = invite.docs;
    var result = selected[0].data() as Map;
    groupID= result['gid'];
    sender = result['sender'];
    FirebaseFirestore.instance
        .collection('groups')
        .doc(groupID)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        final group = documentSnapshot.data() as Map;
        groupName = group['Name'];
        latitude = group['Location'].latitude;
        longitude= group['Location'].longitude;
        print('Document data: ${documentSnapshot.data()}');
        print(' destination is $latitude');
      } else {
        //TODO: What happens when a user does not have an invite
        print('Document does not exist on the database');
      }
    });

  }
  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getDetails();
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
          ),
        ));
  }
}
