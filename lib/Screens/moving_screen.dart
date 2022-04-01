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
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import '../Components/icons.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'moving_active.dart';

const kGoogleApiKey = "AIzaSyDxzZPrCfZRX5FeTsWME8iJYl4EJiKSFQo";

class Moving extends StatefulWidget {
  static String id = 'moving_screen';
  @override
  _MovingState createState() => _MovingState();
}

class _MovingState extends State<Moving> {
  final _firestore = FirebaseFirestore.instance;
  String member;
  String creator;
  String email;
  String user;
  String place;
  String userID;
  User loggedInUser;
  Position _location;
  String name;
  LatLng destination;
  double latitude;
  double longi;
  double currentLat;
  double currentLong;
  String groupName;
  int timeInSeconds;
  String safeWord = 'Not set';
  List<String> Members = [];
  bool checkValue = false;
  List<double> Distance = [1, 1.5, 2, 3, 4, 5];
  double distance = 1.5;
  String ETAInfo = '';
  bool safety = true;
  bool inviteSent = true;
  List<Map> Contacts = [];
  List<String> contactNames = [];
  List<String> selectedContacts = [];
  final _controller = TextEditingController();
  final _auth = FirebaseAuth.instance;

  //getting current user location
  Future getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final _locationData = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    setState(() {
      _location = _locationData;
      currentLat = _location.latitude;
      currentLong = _location.longitude;
    });
  }

  void getContacts() async {
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await _firestore
        .collection('emergency_contacts')
        .where('userID', isEqualTo: userID)
        .get();
    ;
    // Get data from docs and convert map to List
    querySnapshot.docs.forEach((doc) {
      var details = new Map<String, String>();
      details['docID'] = doc.id;
      details['name'] = doc["name"];
      Contacts.add(details);
      print(Contacts);
      return Contacts;
    });
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
        getContacts();
      }
    } catch (e) {
      print(e);
    }
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
        print('the destination is $destination');
        getUserLocation();
        getDistanceMatrix();
      });
    }
  }

  //for calculating distance and time from current location ti
  void getDistanceMatrix() async {
    try {
      var response = await Dio().get(
          'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=$latitude,$longi&origins=$currentLat,$currentLong&key=$kGoogleApiKey');

      setState(() {
        timeInSeconds =
            response.data['rows'][0]['elements'][0]['duration']['value'];
        ETAInfo = response.data['rows'][0]['elements'][0]['duration']['text'];
      });
      print(' the info is $timeInSeconds');
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
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
                'MOVING MODE',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
          ),
          backgroundColor: kMainColour,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      Text(
                        'Where are you going to today ?',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Your contacts will be notified if you do not arrive here \n in the estimate time shown below',
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
                            'Estimated time of Arrival',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                ETAInfo =
                                    'This is how long our current calculations indicate it will take to \n to get to the destination. Please \n note that traffic conditions may cause affect this and if you are safe just taking \n longer than expected, you will be asked to enter a pin';
                              });
                            },
                            icon: Icon(Icons.arrow_downward),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                ETAInfo = '';
                              });
                            },
                            icon: Icon(Icons.arrow_upward),
                          ),
                        ],
                      ),
                      Text(
                        '$ETAInfo',
                        style: TextStyle(
                          fontSize: 13.0,
                        ),
                      ),
                      divider,
                      for (Map contact in Contacts)
                        Contacts != null
                            ? CheckboxGroup(
                                labels: <String>[contact['name']],
                                onSelected: (List<String> checked) {
                                  if (Contacts.length > 3) {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text('Maximum of 3 Contacts'),
                                        content: Text(
                                            'You can only add up to 3 contacts to be notified. \n Please unselect one to select another one'),
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
                                    if (checked != null) {
                                      selectedContacts.add(contact['docID']);
                                      contactNames.add(contact['name']);
                                      print(checked.toString());
                                      print(selectedContacts);
                                    }
                                  }
                                })
                            : Text(''),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Center(
                  child: TextButton(
                    onPressed: () async {
                      try {
                        var contacts = selectedContacts.toSet().toList();
                        var durationInMinutes = timeInSeconds / 60;
                        var docRef =
                            await _firestore.collection('moving_mode').add({
                          'selectedContacts': contacts,
                          'destination': place,
                          'duration': durationInMinutes,
                          'destCoordinates': GeoPoint(latitude, longi),
                          'userID': userID,
                        });
                        await _firestore
                            .collection("users")
                            .doc(userID)
                            .update({
                          'status': 'active',
                        });
                        var now = DateTime.now();
                        var formatterTime = DateFormat('kk:mm');
                        String actualTime = formatterTime.format(now);
                        Navigator.pushNamed(context, MovingActive.id,
                            arguments: {"time": ETAInfo, "destination": place, "list": contactNames, "timeActivated": actualTime,});
                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(' Ops! Moving mode activation failed'),
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
                          'Activate',
                          style: TextStyle(
                            color: Colors.black,
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
      ),
    );
  }
}
