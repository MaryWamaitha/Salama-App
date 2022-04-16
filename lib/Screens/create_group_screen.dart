import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salama/Screens/active_group_screen.dart';
import 'package:salama/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:math';
import 'main_screen.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import '../Components/icons.dart';
import 'invite_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/add_member.dart';

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
  String groupName;
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

  Future<void> _handlePressButton() async {
    // show input autocomplete with selected mode
    // then get the Prediction selected
    Prediction p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      radius: 10000000,
      types: [],
      strictbounds: false,
      // onError: onError,
      mode: Mode.overlay,
      language: "en",
      decoration: InputDecoration(
        hintText: 'Search',
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
      ),
      components: [Component(Component.country, "gh")],
    );

    displayPrediction(p);
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
      }
    } catch (e) {
      print(e);
    }
  }

  //Drop Down
  DropdownButton<double> androidDropdown() {
    List<DropdownMenuItem<double>> dropdownItems = [];
    for (double dist in Distance) {
      var newItem = DropdownMenuItem(
        child: Text(
          '$dist',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        value: dist,
      );
      dropdownItems.add(newItem);
    }

    return DropdownButton<double>(
      value: distance,
      items: dropdownItems,
      onChanged: (value) {
        setState(() {
          distance = value;
        });
      },
    );
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      // get detail (lat/lng)
      GoogleMapsPlaces _places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;
      final name = detail.result.name;
      setState(() {
        place = name;
        destination = LatLng(lat, lng);
        latitude = destination.latitude;
        longi = destination.longitude;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getUsers();
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
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.0),
              Container(
                margin: EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                    color: kPageColour,
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(30.0),
                      topRight: const Radius.circular(30.0),
                    )),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12, left: 12),
                        child: Text(
                          'Search for Users by typing their user names below',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Center(
                        child: Container(
                          color: Colors.white54,
                          child: Autocomplete<String>(
                            optionsBuilder: (TextEditingValue value) {
                              // When the field is empty
                              if (value.text.isEmpty) {
                                return [];
                              }
                              // The logic to find out which ones should appear
                              return Users.where((suggestion) => suggestion
                                  .toLowerCase()
                                  .contains(value.text.toLowerCase()));
                            },
                            onSelected: (value) async {
                              //TODO: Send request for user to join group
                              final QuerySnapshot activity = await _firestore
                                  .collection('users')
                                  .where('username', isEqualTo: value)
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
                                    title:
                                        Text(' User cannot be added to group'),
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
                      SizedBox(height: 20.0),
                      Center(
                        child: Text(
                          'Group Members ',
                          style: kMajorHeadings,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      for (var user in Members)
                        Members != null
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Card(
                                  margin: EdgeInsets.only(right: 15, left: 5),
                                  color: Colors.white30,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5.0, right: 4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          user['username'],
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              Members.remove(user);
                                              addition.addMembers(
                                                  user['username'].toString());
                                            });
                                          },
                                          icon: Icon(Icons.cancel),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            // SizedBox(height: 15.0),
                            : Text(' There are no members in the group'),
                      divider,
                      Text(
                        'Where are you guys going to ?',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Tracking will begin once you are close to or arrive here',
                        style: TextStyle(
                          fontSize: 13.0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10, bottom: 10),
                        child: Container(
                          height: 45.0,
                          child: TextButton(
                            child: Container(
                              height: 40.0,
                              width: 250.0,
                              color: Colors.amberAccent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Press here to select location',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.lightBlue,
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () async {
                              _handlePressButton();
                            },
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Destination: ',
                            style: kMajorHeadings,
                          ),
                          place != null
                              ? Text(
                                  '$place',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                )
                              : Text('')
                        ],
                      ),
                      divider,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Tracking Distance in metres',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Flexible(
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  DistanceInfo =
                                      'This is how far group members can move without triggering an\n alert. Once users go beyond this distance from the location, \n an alert is triggered';
                                });
                              },
                              icon: Icon(Icons.arrow_downward),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                DistanceInfo = '';
                              });
                            },
                            icon: Icon(Icons.arrow_upward),
                          ),
                        ],
                      ),
                      DistanceInfo != ''
                          ? Row(
                              children: [
                                Text(
                                  '$DistanceInfo',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                  ),
                                ),
                              ],
                            )
                          : Text('Select distance below'),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Container(
                          child: Center(child: androidDropdown()),
                          height: 35.0,
                          width: 80.0,
                          // padding: EdgeInsets.only(bottom: 30.0),
                          color: Colors.white54,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            distance = 1000;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          child: Row(
                            children: [
                              Icon(
                                Icons.radio_button_checked_outlined,
                                color: Colors.white70,
                              ),
                              Text(
                                'Use system set distance of 1 KM',
                                style: TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ), //)[[
                      ),
                      divider,
                      Row(
                        children: [
                          Text(
                            'Set up group Safe word ?',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                SafeWordDetails =
                                    ' This is a word only known to group members and that you can use to indicate you are unsafe when attacker is around but is only known to you and your group members';
                              });
                            },
                            icon: Icon(Icons.arrow_downward),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                SafeWordDetails =
                                    'Click down arrow to learn more';
                              });
                            },
                            icon: Icon(Icons.arrow_upward),
                          ),
                        ],
                      ),
                      SafeWordDetails != ''
                          ? Text(
                              '$SafeWordDetails',
                              style: TextStyle(
                                fontSize: 11.0,
                              ),
                            )
                          : Text('Click down arrow to learn more'),
                      // Text(
                      //   'This is a word only known to group members and that you can use to indicate you are unsafe when attacker is around but is only known to you and your group members',
                      //   style: TextStyle(
                      //     fontSize: 13.0,
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(right: 25.0, top: 10.0),
                        child: SizedBox(
                          width: 250,
                          child: TextField(
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black),
                            onChanged: (value) {
                              safeWord = value;
                            },
                            decoration: InputDecoration(
                              hintText: 'Enter safe word',
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 10.0),
                              // border: OutlineInputBorder(
                              //   borderRadius:
                              //       BorderRadius.all(Radius.circular(32.0)),
                              // ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.amberAccent, width: 2.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      divider,
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Center(
                          child: SizedBox(
                            width: 200,
                            child: TextField(
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black),
                              onChanged: (value) {
                                groupName = value;
                              },
                              decoration: InputDecoration(
                                hintText: 'Enter group name',
                                fillColor: Colors.white,
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 10.0),
                                // border: OutlineInputBorder(
                                //   borderRadius:
                                //       BorderRadius.all(Radius.circular(32.0)),
                                // ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.amberAccent, width: 2.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
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
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Center(
                  child: TextButton(
                    onPressed: () async {
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
                              content: Text('Please enter a group name'),
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
                          if (place == null || place == '') {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(' Destination'),
                                content: Text(
                                    'Hello, you need to select the destination to create the group'),
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
                            try {
                              var docRef =
                                  await _firestore.collection('groups').add({
                                'Name': groupName,
                                'Distance': distance,
                                'SafeWord': safeWord,
                                'Location': GeoPoint(latitude, longi),
                                'Destination': place,
                              });

                              var documentId = docRef.id;
                              await _firestore
                                  .collection("groups").doc(documentId)
                                  .collection("safeTaps").add({
                                'username': creator,
                                'safeTaps': 0,
                              });
                              print('document ID is $documentId');
                              await _firestore
                                  .collection('active_members')
                                  .add({
                                'username': creator,
                                'isSafe': true,
                                'gid': documentId,
                                'tracking': false,
                              });
                              await _firestore
                                  .collection("users")
                                  .doc(userID)
                                  .update({
                                'status': 'active',
                              });
                              for (var invite in Members) {
                                _firestore.collection('invites').add({
                                  'username': invite['username'],
                                  'gid': documentId,
                                  'inviteSent': inviteSent,
                                  'sender': creator,
                                  'destination': place,
                                });
                                List tokenList = [invite['tokenID']];
                                _handleSendNotification(
                                    tokenList,
                                    '$username has invited you to join $groupName',
                                    '$creator has invited you to join group to $place. \n To accept invite, please go to invites page ');
                              }
                              Navigator.pushNamed(context, ActiveGroup.id);
                            } catch (e) {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(' Ops! Group creation Failed'),
                                  content: Text('${e.message}'),
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
                          }
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
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Menu(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
