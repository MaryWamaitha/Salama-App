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
  String userID;
  User loggedInUser;
  String name;
  String phone;
  String Users;
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
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final  Map<String, Object> rcvdData = ModalRoute.of(context).settings.arguments;
    for ( var contact in  {rcvdData['list']}){
      Users = ( '$contact ');
    }
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
                'ADD CONTACT',
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
        child: Expanded (
          //TODO: Implement bottom navigation bar
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Card(
                  color: kPageColour,
                  elevation: 10,
                  child: Text(
                    'You are moving towards  ${rcvdData['destination']} and are expected to take\n'
                        ' ${rcvdData['time']} from  ${rcvdData['timeActivated']}.  \n $Users will be notified if you do not arrive on time ',
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
