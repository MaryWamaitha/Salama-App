import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salama/Screens/active_group_screen.dart';
import 'package:salama/Screens/emergency_contacts.dart';
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

const kGoogleApiKey = "AIzaSyDxzZPrCfZRX5FeTsWME8iJYl4EJiKSFQo";
const ktextFieldPadding = const EdgeInsets.fromLTRB(60.0, 20, 60, 20);

class MovingActive extends StatefulWidget {
  static String id = 'moving_active';
  @override
  _MovingActiveState createState() => _MovingActiveState();
}

class _MovingActiveState extends State<MovingActive> {
  final _firestore = FirebaseFirestore.instance;
  String member;
  String creator;
  String contactEmail;
  String email;
  String destination;
  String user;
  String place;
  bool isSafe;
  String userID;
  String docID;
  User loggedInUser;
  int ETA;
  LatLng userLocation;
  double userLatitude;
  double userLongitude;
  LatLng destLocation;
  double destLatitude;
  double destLongitude;
  String name;
  String phone;
  String Users = '';
  String safeWord = 'Not set';
  List<String> Contacts = [];
  List<String> Members = [];

  String DistanceInfo = 'Select distance below';
  String SafeWordDetails = 'Tap the down arrow key to learn more';
  bool safety = true;
  bool inviteSent = true;
  final _controller = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool userNameValidate = false;
  TextEditingController userNameController = TextEditingController();

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
          print(' the location evben  when changed ois $userLocation');
        }
      }
    } catch (e) {
      print(e);
    }
  }

  bool trackingUser(lat1, lon1, lat2, lon2) {
    bool active;
    var p = 0.017453292519943295;
    //method for calculating distance between two points
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    double distance = 12742 * asin(sqrt(a));
    if (distance > 1) {
      setState(() {
        isSafe = false;
      });
    } else {
      setState(() {
        isSafe = true;
      });
    }
    print('user isSafe is $isSafe');
    print('distance is $distance');
    return isSafe;
  }

  void userCheckIn() {
    Timer.periodic(Duration(minutes: ETA), (timer) async {
      getUserLocation();
      var safety = trackingUser(
          userLatitude, userLongitude, destLatitude, destLongitude);
      if (safety == false) {
//TODO: Activating moving mode
      }
    });
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
        final QuerySnapshot moving = await _firestore
            .collection('moving_mode')
            .where('userID', isEqualTo: userID)
            .get();
        final List<DocumentSnapshot> isMoving = moving.docs;
        final m = isMoving[0].data() as Map;
        ETA = m['duration'];
        destination = m['destination'];
        Contacts = m['selectedContacts'];
        destLatitude = m['destCoordinates'].latitude;
        destLongitude = m['destCoordinates'].longitude;
      }
    } catch (e) {
      print(e);
    }
  }
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Object> rcvdData =
        ModalRoute.of(context).settings.arguments;
    for (var contact in rcvdData['list']) {
      setState(() {
        Users = Users + contact.toString();
      });
    }
    userID = rcvdData['userID'];
    docID = rcvdData['docID'];
    return Scaffold(
      backgroundColor: kBackgroundColour,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
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
                'MOVING MODE ACTIVATED',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
          ),
          backgroundColor: kMainColour,
        ),
      ),
      body:
          //TODO: Getting to this page even when if coming from home page and still having the values
          SafeArea(
        child: Expanded(
          //TODO: Implement bottom navigation bar
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  height: 200,
                  child: Card(
                    color: kPageColour,
                    elevation: 10,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                        child: Text(
                          'You are moving towards  ${rcvdData['destination']} and are expected to take'
                          ' ${rcvdData['time']} from  ${rcvdData['timeActivated']}.  \n \n $Users will be notified if you do not arrive on time ',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await _firestore
                      .collection("moving_mode")
                      .doc(docID)
                      .delete();
                  await _firestore.collection("users").doc(userID).update({
                    'status': 'inactive',
                  });
                  Navigator.pushNamed(context, MainScreen.id);
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(60.0, 10, 60, 60),
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
                        'DEACTIVATE',
                        style: TextStyle(
                          color: Colors.black,
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
      ),
    );
  }
}
