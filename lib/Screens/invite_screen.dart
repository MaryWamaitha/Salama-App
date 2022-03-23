import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_screen.dart';
import 'package:geocoding/geocoding.dart';
import '../constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'active_group_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salama/constants.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

final _firestore = FirebaseFirestore.instance;

class Invite extends StatefulWidget {
  static String id = 'invite_screen';
  @override
  _InviteState createState() => _InviteState();
}

class _InviteState extends State<Invite> {
  final _auth = FirebaseAuth.instance;
  String sender;
  String username;
  bool showSpinner = false;
  String groupName;
  LatLng destination;
  String groupID;
  double latitude;
  double longitude;
  String address;
  String place;
  List <Map> Invites =[];

  //uses logged in user email to get their username
  void getInvites() async {
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
          username = x['username'];
          getDetails();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  //use username to get invite details like GID, sender etc
  void getDetails() async {
    final QuerySnapshot invites = await _firestore
        .collection('invites')
        .where('username', isEqualTo: username)
        .get();
    final List<DocumentSnapshot> selected = invites.docs;
    var i = 0;
    print(selected);
    int lengthy = selected.length;
    while (i <= 2) {
      final result = selected[i].data() as Map;
      print(result);
      //Add map here that the information is added to
      var details = new Map();
      groupID = result['gid'];
      sender = result['sender'];
      place = result['destination'];
      FirebaseFirestore.instance
          .collection('groups')
          .doc(groupID)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          final group = documentSnapshot.data() as Map;
          groupName = group['Name'];
          place = group['place'];
          latitude = group['Location'].latitude;
          longitude = group['Location'].longitude;
          getAddress(latitude, longitude);
          print('Document data: ${documentSnapshot.data()}');
          var len = group.length;
          print('length is $lengthy');
          details['groupName'] = groupName;
          details['sender'] = sender;
          details['place'] = result['destination'];
          Invites.add(details);

          print('invites are $Invites');
          print(username);
        } else {
          var notPresent = true;
          //TODO: What happens when a user does not have an invite
          Navigator.pushNamed(context, ActiveGroup.id);
          print('Document does not exist on the database');
        }
      });
      ++i;
    }
  }

  void getAddress(lat, long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    print(' place is $placemarks');
  }

  @override
  void initState() {
    super.initState();
    getInvites();
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
                  'GROUPS',
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
