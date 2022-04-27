import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salama/Screens/create_screen1.dart';
import 'package:salama/Screens/create_pin.dart';
import 'package:salama/Screens/settings.dart';
import 'main_screen.dart';
import 'package:geocoding/geocoding.dart';
import '../constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'active_group_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salama/constants.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:salama/Components/icons.dart';

final _firestore = FirebaseFirestore.instance;

class Invite extends StatefulWidget {
  static String id = 'invite_screen';
  @override
  _InviteState createState() => _InviteState();
}

class _InviteState extends State<Invite> {
  final _auth = FirebaseAuth.instance;
  String sender;
  User loggedInUser;
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
  String tokenID;
  List<Map> Invites = [];
  String senderName;
  String userID;
  int setPin;

  //getting token ID to be used for notifications

  void configOneSignel() {
    OneSignal.shared.setAppId("25effc79-b2cc-460d-a1d0-dfcc7cb65146");
  }

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
    //getting the User Document ID so that we can update it
    final QuerySnapshot loggedUser = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    final List<DocumentSnapshot> person = loggedUser.docs;
    userID = person[0].id;
    //getting the invites that have the username in them
    final QuerySnapshot invites = await _firestore
        .collection('invites')
        .where('username', isEqualTo: username)
        .get();
    var Notifystatus = await OneSignal.shared.getDeviceState();
    String tokenID = Notifystatus.userId;
    print(' the token ID is $tokenID');
    final List<DocumentSnapshot> selected = invites.docs;
    var i = 0;
    print(selected);
    int lengthy = selected.length;
    while (i < lengthy) {
      var doID = selected[i].id;
      final result = selected[i].data() as Map;
      print(result);
      //Add map here that the information is added to
      var details = new Map<String, String>();
      groupID = result['gid'];
      sender = result['sender'];
      place = result['destination'];
      details['sender'] = sender;
      details['gid'] = groupID;
      details['userID'] = userID;
      details['docID'] = doID;
      FirebaseFirestore.instance
          .collection('groups')
          .doc(groupID)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          var doc_id2 = documentSnapshot.id;
          final group = documentSnapshot.data() as Map;
          groupName = group['Name'];
          place = group['place'];
          latitude = group['Location'].latitude;
          longitude = group['Location'].longitude;
          getAddress(latitude, longitude);
          var docuID = details['docID'];
          print('Document data: $docuID');
          var len = group.length;
          print('length is $lengthy');
          details['groupName'] = groupName;
          details['place'] = result['destination'];
          // details['street']= street;
          setState(() {
            Invites.add(details);
          });
          print('invites are $Invites');
          print(username);
        } else {
          var notPresent = true;
          Navigator.pushNamed(context, ActiveGroup.id);
        }
      });
      ++i;
    }
    final QuerySnapshot record = await _firestore
        .collection('pins')
        .where('userID', isEqualTo: userID)
        .get();
    final List<DocumentSnapshot> found = record.docs;
    setPin = found.length;
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
        preferredSize: Size.fromHeight(100.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Center(
            child: Padding(
              padding: EdgeInsets.only(top: 50.0, bottom: 10),
              child: Text(
                'INVITES',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
          ),
          backgroundColor: kMainColour,
        ),
      ),
      body: Invites.isNotEmpty
          ? SingleChildScrollView(
              child: SafeArea(
                child: Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (Map user in Invites)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 30.0, right: 30.0, top: 10),
                                child: Card(
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            backgroundImage:
                                                AssetImage('images/group.png'),
                                            radius: 40,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 8.0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  'Sender:',
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  user['sender'].toString(),
                                                  style: TextStyle(
                                                      fontSize: 20.0,
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Group Name: ',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            user['groupName'].toString(),
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        thickness: 1,
                                        indent: 5,
                                        endIndent: 5, // thickness of the line
                                        color: Colors
                                            .grey, // The color to use when painting the line.
                                        height: 15, // The divider's height extent.
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_city_outlined,
                                            color: Colors.green,
                                            size: 40,
                                          ),
                                          Text(
                                            user['place'].toString(),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          TextButton(
                                            onPressed: () async {
                                              var id = user['docID'];
                                              var gid = user['gid'];
                                              await _firestore
                                                  .collection('active_members')
                                                  .add({
                                                'username': username,
                                                'isSafe': true,
                                                'gid': gid,
                                                'tracking': false,
                                              });
                                              await _firestore
                                                  .collection('users').doc(id)
                                                  .update({
                                                'status': 'active',
                                              });
                                              await _firestore
                                                  .collection("invites")
                                                  .doc(id)
                                                  .delete();
                                              setState(() {
                                                Invites.remove(user);
                                              });
                                              await _firestore
                                                  .collection("groups")
                                                  .doc(gid)
                                                  .collection("safeTaps")
                                                  .add({
                                                'username': username,
                                                'safeTaps': 0,
                                              });
                                              if (setPin == 0) {
                                                showDialog(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title: Text('Set pin'),
                                                    content: Text(
                                                        'Hey there, please set your pin in settings \n You will need the pin to leave your groups yourself'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pushNamed(
                                                              context,
                                                              CreatePin.id);
                                                        },
                                                        child: Text('Okay'),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              } else {
                                                Navigator.pushNamed(
                                                    context, ActiveGroup.id);
                                              }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                      new BorderRadius.all(
                                                    Radius.circular(10.0),
                                                  )),
                                              child: Center(
                                                child: Text('Accept',
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                    )),
                                              ),
                                              width: 80,
                                              height: 30,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              var ID = user['docID'];
                                              setState(() {
                                                _firestore
                                                    .collection("invites")
                                                    .doc(ID)
                                                    .delete();
                                                Invites.remove(user);
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius:
                                                      new BorderRadius.all(
                                                    Radius.circular(10.0),
                                                  )),
                                              child: Center(
                                                child: Text('Decline',
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                    )),
                                              ),
                                              width: 80,
                                              height: 30,
                                            ),
                                          ),
                                        ],
                                      )
                                    ]),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Menu(),
                    ],
                  ),
                ),
              ),
            )
          : Padding(
              padding: EdgeInsets.only(top: 120),
              child: Container(
                color: kBackgroundColour,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(25, 15, 25, 0),
                        child: Container(
                          color: kMainColour,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text(
                                    'You do not have any invites. You can create '
                                    'a group and send invites by clicking the button below',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, CreateGroup.id);
                                },
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
                                      'Create Group',
                                      style: TextStyle(
                                        color: Colors.black,
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
                    Menu(),
                  ],
                ),
              ),
            ),
    );
  }
}
