import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../Components/icons.dart';
import 'create_group_screen.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class MainScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _userLocation;

  Future<void> _getUserLocation() async {
    Location location = Location();

    // Check if location service is enable
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Check if permission is granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final _locationData = await location.getLocation();
    setState(() {
      _userLocation = _locationData;
    });
  }

  LatLng _initialcameraposition = LatLng(-1.3134, 36.9555);
  GoogleMapController _controller;
  Location _location = Location();

  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
    _location.onLocationChanged.listen((l) {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude, l.longitude)),
        ),
      );
    });
  }

  //create an instance of firebase auth that we will use out all through out the page
  final _auth = FirebaseAuth.instance;
  //the text controller helps us in managing the text field eg clearing it when the send button is clicked
  final messageTextController = TextEditingController();
  String email;
  String messageText;

  //this initiliazes the get user method when screen is started
  @override
  void initState() {
    super.initState();
    _getUserLocation();
    getCurrentUser();
  }

  //this method returns a future
  void getCurrentUser() {
    //once a user is registered or logged in then this current user will have  a variable
    //the current user will be null if nobody is signed in
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
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
                Navigator.pop(context);
              }),
        ],
        title: Text('Salama'),
        backgroundColor: kMainColour,
      ),
      body: _userLocation != null
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
                        minMaxZoomPreference: MinMaxZoomPreference(14, 17),
                        zoomGesturesEnabled: true,
                        initialCameraPosition:
                            CameraPosition(target: _initialcameraposition),
                        mapType: MapType.normal,
                        onMapCreated: _onMapCreated,
                        myLocationEnabled: true,
                      ),
                    ),
                  ),
                  Container(
                    height: 66,
                    color: kMainColour,
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          MenuItem(
                            icon: Icons.home,
                            label: 'Home',
                          ),
                          MenuItem(
                            icon: Icons.people,
                            label: 'Create Group',
                            page: CreateGroup.id,
                            //Go to Group screen,
                          ),
                          MenuItem(
                              icon: Icons.location_on_rounded,
                              label: 'Active Group'),
                          MenuItem(icon: Icons.directions_car, label: 'Moving'),
                          MenuItem(icon: Icons.settings, label: 'Settings'),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          : Container(), //TODO Add what to show if user location is null eg error message
    );
  }
}
