import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:salama/Screens/active_group_screen.dart';
import 'package:salama/Screens/create_pin.dart';
import 'package:salama/Screens/create_screen2.dart';
import 'package:salama/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'settings.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../models/add_member.dart';
import 'package:salama/Components/icons.dart';

const kGoogleApiKey = "AIzaSyDxzZPrCfZRX5FeTsWME8iJYl4EJiKSFQo";

class CreateGroup extends StatefulWidget {
  static String id = 'create_group_screen';
  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final _firestore = FirebaseFirestore.instance;
  String member;
  String creator;
  String email;
  String user;
  String place;
  String userID;
  User loggedInUser;
  String name;
  LatLng destination;
  double latitude;
  double longi;
  String status;
  int setPin;
  bool indicator = true;
  String groupName = 'e.g Bloom Friends';
  String safeWord = 'Not set';
  List<String> Users = [];
  List<Map> Members = [];
  List<double> Distance = [300, 500, 700, 900, 1000, 1200, 1500, 2000, 2500];
  double distance = 1000;
  String DistanceInfo = 'Select distance below';
  String SafeWordDetails = 'Tap the down arrow key to learn more';
  bool safety = true;
  bool inviteSent = true;
  final _controller = TextEditingController();
  final _auth = FirebaseAuth.instance;

  Future<void> getUsers() async {
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await _firestore.collection('users').get();
    ;
    // Get data from docs and convert map to List
    querySnapshot.docs.forEach((doc) {
      Users.add(doc["username"]);
      Users.remove(creator);
      return Users;
    });
  }

  addMember addition = addMember();
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

  //Getting current user so that we can add them as initial group member
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
        final x = selected[0].data() as Map;
        userID = selected[0].id;
        creator = x['username'];
        status = x['status'];
        final QuerySnapshot record = await _firestore
            .collection('pins')
            .where('userID', isEqualTo: userID)
            .get();
        final List<DocumentSnapshot> found = record.docs;
        setPin = found.length;
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

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getUsers();
    configOneSignel();
    Indicator();
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
                'CREATE GROUP',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
          ),
          backgroundColor: kMainColour,
        ),
      ),
      body: status == 'inactive'
          ? ModalProgressHUD(
              inAsyncCall: indicator,
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 10.0),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 16.0, top: 15),
                                child: Text(
                                  'Group Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Center(
                                  child: SizedBox(
                                    width: 350,
                                    height: 100,
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.black),
                                      onChanged: (value) {
                                        groupName = value;
                                      },
                                      decoration: InputDecoration(
                                        hintText: '$groupName',
                                        fillColor: Colors.white,
                                        filled: true,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 10.0),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(32.0)),
                                          borderSide: BorderSide(
                                              color: Colors.amberAccent,
                                              width: 2.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          borderSide: BorderSide(
                                              color: Colors.amberAccent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.amberAccent,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text(
                                  'Search for users',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, top: 5, right: 14),
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: new BorderRadius.all(
                                          const Radius.circular(10.0),
                                        ),
                                        border: Border.all(
                                          color: Colors.amberAccent,
                                        ),
                                        color: Colors.white70),
                                    child: Autocomplete<String>(
                                      optionsBuilder: (TextEditingValue value) {
                                        // When the field is empty
                                        if (value.text.isEmpty) {
                                          return [];
                                        }
                                        // The logic to find out which ones should appear
                                        return Users.where((suggestion) =>
                                            suggestion.toLowerCase().contains(
                                                value.text.toLowerCase()));
                                      },
                                      onSelected: (value) async {
                                        //TODO: Send request for user to join group
                                        final QuerySnapshot activity =
                                            await _firestore
                                                .collection('users')
                                                .where('username',
                                                    isEqualTo: value)
                                                .get();
                                        final List<DocumentSnapshot> available =
                                            activity.docs;
                                        var result = available[0].data() as Map;
                                        var details = new Map<String, String>();
                                        var status = result['status'];
                                        var tokenID = result['tokenID'];
                                        if (status == 'active') {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text(
                                                  ' User cannot be added to group'),
                                              content: Text(
                                                  'The user is currently active in another group'),
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
                                        } else {
                                          setState(() {
                                            // print(available);
                                            details['username'] = value;
                                            details['tokenID'] = tokenID;
                                            Members.add(details);
                                            Users.remove(value);
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.0),
                              SizedBox(height: 10.0),
                              for (var user in Members)
                                Members != null
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15.0, right: 11, top: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10.0),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0, right: 20),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                          backgroundImage:
                                                              AssetImage(
                                                                  'images/person.png'),
                                                          radius: 25,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 8.0),
                                                          child: Text(
                                                            user['username'],
                                                            style: TextStyle(
                                                              fontSize: 14.0,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          Members.remove(user);
                                                          addition.addMembers(
                                                              user['username']
                                                                  .toString());
                                                        });
                                                      },
                                                      icon: Icon(
                                                        Icons.cancel_rounded,
                                                        color:
                                                            Colors.amberAccent,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    // SizedBox(height: 15.0),
                                    : Text(
                                        ' There are no members in the group'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Center(
                            child: TextButton(
                              onPressed: () {
                                //when button is clicked check if the user has group members
                                if (Members.length == 0) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(' Add Members'),
                                      content: Text(
                                          'Hello, you need to add at least one group member to the group.'),
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
                                } else {
                                  if (groupName == null || groupName == '') {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text(' Group Name'),
                                        content:
                                            Text('Please enter a group name'),
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
                                  } else {
                                    Navigator.pushNamed(context, FinalCreate.id,
                                        arguments: {
                                          "invites": Members,
                                          "groupName": groupName,
                                        });
                                  }
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.amberAccent,
                                    borderRadius: new BorderRadius.all(
                                      const Radius.circular(30.0),
                                    )),
                                height: 50,
                                width: 250.00,
                                child: Center(
                                  child: Text(
                                    'Continue',
                                    style: TextStyle(
                                      color: kMainColour,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 230,
                        ),
                        Menu(),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : ModalProgressHUD(
              inAsyncCall: indicator,
              child: Padding(
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
                                      'You are already in a group, click below to go to your group',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, ActiveGroup.id);
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
                                        'Go to Group',
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
            ),
    );
  }
}
