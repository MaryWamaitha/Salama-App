import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Components/icons.dart';
import 'create_group_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'trial_screen.dart';
import 'bottommenu.dart';
import 'invite_screen.dart';
import 'moving_screen.dart';
import 'settings.dart';
import 'login_screen.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class MainScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Position _location;
  int selectedPage = 0;
  String username;

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
  }

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  LatLng _initialcameraposition = LatLng(-1.3134, 36.9555);
  GoogleMapController _controller;
  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 100,
  );
  // final Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController _cntlr) {
    getUserLocation();
    _controller = _cntlr;
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_location.latitude, _location.longitude),
          zoom: 18.0,
        ),
      ),
    );
    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 18.0,
          ),
        ),
      );
      final marker = Marker(
        markerId: MarkerId('place_name'),
        position: LatLng(position.latitude, position.longitude),
        // icon: BitmapDescriptor.,
        infoWindow: InfoWindow(
          title: '$username',
        ),
      );

      setState(() {
        markers[MarkerId('place_name')] = marker;
      });
    });
  }

  //create an instance of firebase auth that we will use out all through out the page
  final _auth = FirebaseAuth.instance;
  //the text controller helps us in managing the text field eg clearing it when the send button is clicked
  final messageTextController = TextEditingController();
  String email;
  String messageText;
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

  //this initiliazes the get user method when screen is started
  @override
  void initState() {
    super.initState();
    getUserLocation();
    getCurrentUser();
  }

  //this method returns a future

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
                Navigator.pushNamed(context,LoginScreen.id);
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
                          zoom: 12.0,
                        ),
                        markers: markers.values.toSet(),
                        mapType: MapType.normal,
                      ),
                    ),
                  ),
                  Menu()
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

