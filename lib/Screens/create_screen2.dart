import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salama/Screens/active_group_screen.dart';
import 'package:salama/Screens/create_pin.dart';
import 'package:salama/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:salama/Components/icons.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'settings.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../models/add_member.dart';
import 'package:salama/models/getUser.dart';

const kGoogleApiKey = "AIzaSyDxzZPrCfZRX5FeTsWME8iJYl4EJiKSFQo";

class FinalCreate extends StatefulWidget {
  static String id = 'create_screen2';
  @override
  _FinalCreateState createState() => _FinalCreateState();
}

class _FinalCreateState extends State<FinalCreate> {
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
  getDetails Details = getDetails();
  final _auth = FirebaseAuth.instance;

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
      List<DocumentSnapshot> selected = await Details.getUserDetail();
      if (selected.length > 0) {
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
    configOneSignel();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Object> rcvdData =
        ModalRoute.of(context).settings.arguments;
    groupName = rcvdData['groupName'];
    Members = rcvdData['invites'];
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
      body: status == 'inactive' || status == null
          ? SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.0),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Row(
                              children: [
                                Text(
                                  'Where are you guys going to ?',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Flexible(
                                  child: IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text('Tracking Distance'),
                                          content: Text(
                                            'Tracking will begin once you are close to or arrive here',
                                            textAlign: TextAlign.left,
                                          ),
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
                                    },
                                    icon: Icon(Icons.info_outline_rounded),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 10, bottom: 10),
                            child: Container(
                              height: 60.0,
                              child: TextButton(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: new BorderRadius.all(
                                      const Radius.circular(10.0),
                                    ),
                                    border: Border.all(
                                      color: Colors.amberAccent,
                                    ),
                                  ),
                                  height: 100.0,
                                  width: 300.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      place != null
                                          ? Text(
                                              '$place',
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            )
                                          : Text(
                                              ' e.g Bondai Restaurant ',
                                              style: TextStyle(
                                                color: Colors.black54,
                                              ),
                                            )
                                    ],
                                  ),
                                ),
                                onPressed: () async {
                                  _handlePressButton();
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Row(
                              children: [
                                Text(
                                  'Add Group Safe Words',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Flexible(
                                  child: IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text('Tracking Distance'),
                                          content: Text(
                                            'This is a word only known to group members and that you can use to indicate you are unsafe when attacker is around as friends are checking in. The group members need to enter their pin to see it',
                                            textAlign: TextAlign.justify,
                                          ),
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
                                    },
                                    icon: Icon(Icons.info_outline_rounded),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 25.0, left: 10),
                              child: SizedBox(
                                width: 300,
                                height: 100,
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
                                      borderSide:
                                          BorderSide(color: Colors.amberAccent),
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
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Tracking Distance',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Flexible(
                                  child: IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text('Tracking Distance'),
                                          content: Text(
                                            'This is how far group members can move without triggering an alert. Once users go beyond this distance from the location, an alert is sent to all group members.\nYou can either select a distance from the drop down or '
                                            'else the system distance of 1000 m will be used.\n The distance is in metres',
                                            textAlign: TextAlign.left,
                                          ),
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
                                    },
                                    icon: Icon(Icons.info_outline_rounded),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 50.0),
                                  child: Container(
                                    child: Center(child: androidDropdown()),
                                    height: 35.0,
                                    width: 80.0,
                                    // padding: EdgeInsets.only(bottom: 30.0),

                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                      ),
                                      borderRadius: new BorderRadius.all(
                                        const Radius.circular(5.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0, bottom: 8.0),
                      child: Center(
                        child: TextButton(
                          onPressed: () async {
                            //when button is clicked check if the user has group members
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
                                    .collection("groups")
                                    .doc(documentId)
                                    .collection("safeTaps")
                                    .add({
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
                                  List<String> tokenList = [];
                                  tokenList.add(invite['tokenID'].toString());
                                  print('the token ID is $tokenList');
                                  _handleSendNotification(
                                      tokenList,
                                      '$creator has invited you to join $groupName',
                                      '$creator has invited you to join group to $place.\nTo accept invite, please go to invites page ');
                                }
                                if (setPin == 0) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text('Set pin'),
                                      content: Text(
                                          'Hey there, you do not have a pin. Please set your pin in settings You will need the pin to leave your groups yourself'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                                context, CreatePin.id);
                                          },
                                          child: Text('Okay'),
                                        )
                                      ],
                                    ),
                                  );
                                } else {
                                  Navigator.pushNamed(context, ActiveGroup.id);
                                }
                              } catch (e) {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(' Ops! Group creation Failed'),
                                    content: Text(
                                        'The group creation wasnt successful'),
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
                                'Create Group',
                                style: TextStyle(
                                  color: kMainColour,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Menu(),
                  ],
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
                                    'You are already in a group, click below to go to your group',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, ActiveGroup.id);
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
    );
  }
}
