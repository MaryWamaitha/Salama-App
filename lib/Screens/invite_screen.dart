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
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
  String street;
  List<Map> Invites = [];
  String senderName;

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
    while (i <= lengthy) {
      final result = selected[i].data() as Map;
      print(result);
      //Add map here that the information is added to
      var details = new Map<String, String>();
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
          // details['street']= street;
          setState(() {
            Invites.add(details);
          });
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

  final optionsMap = {
    111: "First option",
    222: "Second option",
  };

  void getAddress(lat, long) async {
    List<Placemark> address = await placemarkFromCoordinates(lat, long);
    Placemark placeMark = address[0];
    street = placeMark.street;
    print(' place is $street');
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
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Text('Pending Invites'),
              for (Map user in Invites)
                Invites.isNotEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        child: Card(
                  color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.quick_contacts_mail_rounded,
                                    color: Colors.brown,),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Row(
                                        children: [
                                          Text('Sender:',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black,
                                          ),),
                                          Text(user['sender'].toString(),
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold
                                            ),),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text('Group Name:',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                      ),),
                                    Text(user['groupName'].toString(),
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold
                                      ),),
                                  ],
                                ),
                                Divider(
                                  thickness: 1,
                                  indent: 5,
                                  endIndent: 5,// thickness of the line
                                  color: Colors
                                      .grey, // The color to use when painting the line.
                                  height: 15, // The divider's height extent.
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.location_city_outlined,
                                      color: Colors.green,),
                                    Text(user['place'].toString(),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold
                                      ),),
                                  ],
                                ),
                              ]),
                            ),
                          ),
                      ),
                    )
                    : Container(
                        child: SpinKitFoldingCube(
                          color: Colors.green,
                          size: 100.0,
                        ),
                      ),
            ],
          ),
        ),
      ),
    );
  }
}
