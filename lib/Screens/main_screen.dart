import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Components/icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'login_screen.dart';
import 'package:workmanager/workmanager.dart';



class MainScreen extends StatefulWidget {
  static String id = 'main_screen';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _firestore = FirebaseFirestore.instance;
  User loggedInUser;
  Position _location;
  int selectedPage = 0;
  String username;
  List<Map> Members = [];
  LatLng userLocation;
  String status;
  String docuID;
  String groupID;
  Set<Marker> _markers = Set<Marker>();
  final _auth = FirebaseAuth.instance;
  //the text controller helps us in managing the text field eg clearing it when the send button is clicked
  final messageTextController = TextEditingController();
  String email;
  String messageText;

  static const fetchBackground = "fetchBackground";

  void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      switch (task) {
        case fetchBackground:
          final _locationData = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.bestForNavigation);
          setState(() {
            _location = _locationData;
          });
          if (status == 'active') {
            // if a user is acrive, save their location to database anytime it is changed
            await _firestore.collection("users").doc(docuID).update({
              'location': GeoPoint(_location.latitude, _location.longitude),
            });
          };
          break;
      }
      return Future.value(true);
    });
  }

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
    });
    if (status == 'active') {
      // if a user is acrive, save their location to database anytime it is changed
      await _firestore.collection("users").doc(docuID).update({
        'location': GeoPoint(_location.latitude, _location.longitude),
      });
    };

  }

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  LatLng _initialcameraposition = LatLng(-1.3134, 36.9555);
  GoogleMapController _controller;
  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
  );
  // final Set<Marker> _markers = {};


  void _onMapCreated(GoogleMapController _cntlr) async {
    getGroupMembers;
    getUserLocation();
    _controller = _cntlr;
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_location.latitude, _location.longitude),
          zoom: 15.0,
        ),
      ),
    );

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      if (status == 'active') {
        // if a user is active, save their location to database anytime it is changed
        _firestore.collection("users").doc(docuID).update({
          'location': GeoPoint(position.latitude, position.longitude),
        });
      }
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.0,
          ),
        ),
      );

      _markers.removeWhere((m) => m.markerId.value == '$username');
      _markers.add(Marker(
        markerId: MarkerId('$username'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: InfoWindow(
          title: '$username',
        ),
      ));
      for (Map member in Members) {
        _markers.removeWhere((m) => m.markerId.value == member['username']);
        _markers.add(Marker(
          markerId: MarkerId(member['username']),
          position: member['location'],
          infoWindow: InfoWindow(
            title: member['username'],
          ),
        ));
      }
    });
  }

  //create an instance of firebase auth that we will use out all through out the page

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
        if (selected.length > 0) {
          var x = selected[0].data() as Map;
          //setting the username, docuID and status to the values gotten from the database
          setState(() {
            username = x['username'];
            //getting userID so that we use it to update location
            docuID = selected[0].id;
            status = x['status'];
          });
         var tokenID= x['tokenID'];
          OneSignal.shared.setAppId("25effc79-b2cc-460d-a1d0-dfcc7cb65146");
          var Notifystatus = await OneSignal.shared.getDeviceState();
          String deviceTokenID = Notifystatus.userId;
         if (tokenID != deviceTokenID ){
           _firestore.collection("users").doc(docuID).update({
             'tokenID': deviceTokenID,
           });
         }

        }
        getGroupMembers();
      }
    } catch (e) {
      print(e);
    }
  }


  void getGroupMembers() async {
    //once a user is registered or logged in then this current user will have  a variable
    //the current user will be null if nobody is signed in
    try {
      //Todo: Add a condition here of what happens if the group ID is null

      final QuerySnapshot activity = await _firestore
          .collection('active_members')
          .where('username', isEqualTo: username)
          .get();
      final List<DocumentSnapshot> selected = activity.docs;

      if (selected.length > 0) {
        var x = selected[0].data() as Map;
        //setting the username, docuID and status to the values gotten from the database
        setState(() {
          groupID = x['gid'];
          print('the group ID is $groupID');
        });

        if (groupID != null && groupID != '') {
          final QuerySnapshot members = await _firestore
              .collection('active_members')
              .where('gid', isEqualTo: groupID)
              .get();
          final List<DocumentSnapshot> found = members.docs;
          //TODO: What happens if invite does not exist
          var i = 0;
          int lengthy = found.length;
          while (i < lengthy) {
            var member = found[i].data() as Map;
            print(' member is $member');
            var memberUname = member['username'];
            final QuerySnapshot membersDets = await _firestore
                .collection('users')
                .where('username', isEqualTo: memberUname)
                .get();
            final List<DocumentSnapshot> locDets = membersDets.docs;
            var details = new Map();
            var result = locDets[0];
            final returned = result.data() as Map;
            LatLng destination = LatLng(
                returned['location'].latitude, returned['location'].longitude);
            details['username'] = returned['username'];
            details['location'] = destination;
            setState(() {
              Members.add(details);
            });


            ++i;
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  //TODO: find why the location is updating for all users instead of the logged in user only
  void trackingMembers() {
    Timer.periodic(Duration(seconds: 10), (timer) async {
      getGroupMembers();
    });
  }

  //this initiliazes the following methods when screen is started
  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getUserLocation();
    trackingMembers();
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );

    Workmanager().registerPeriodicTask(
      "1",
      fetchBackground,
      frequency: Duration(minutes: 15),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                // // the firebase signout method
                _auth.signOut();
                Navigator.pushNamed(context, LoginScreen.id);
              }),
        ],
        title: Text('Salama'),
        backgroundColor: kMainColour,
      ),
      body: _location != null
          ? SafeArea(
              child: Column(
                children: [
                  Flexible(
                    child: SizedBox(
                      width: MediaQuery.of(context)
                          .size
                          .width, // or use fixed size like 200
                      height: MediaQuery.of(context).size.height,
                      //TODO: Add map zoom feature
                      child: GoogleMap(
                        minMaxZoomPreference: MinMaxZoomPreference(4, 20),
                        zoomGesturesEnabled: true,
                        onMapCreated: _onMapCreated,
                        myLocationEnabled: true,
                        initialCameraPosition: CameraPosition(
                          target:
                              LatLng(_location.latitude, _location.longitude),
                          // zoom: 15.0,
                        ),
                        markers: _markers,
                        mapType: MapType.normal,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              child: SpinKitFoldingCube(
                color: Colors.green,
                size: 100.0,
              ),
            ),
    );
  }
}
