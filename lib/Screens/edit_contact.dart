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

class AddContact extends StatefulWidget {
  static String id = 'edit_contact';

  @override
  _AddContactState createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  final _firestore = FirebaseFirestore.instance;
  String member;
  String creator;
  String contactEmail;
  String email;
  String user;

  String userID;
  User loggedInUser;
  String name;
  String phone;
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
                child: Form(
                  key: _formKey,
                  child: Card(
                    color: kPageColour,
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: ktextFieldPadding,
                            child: TextFormField(
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black),
                               controller: userNameController,
                                onChanged: (value) {
                                  name = value;
                                },
                              validator: (name) {
                                if (name == null || name.isEmpty) {
                                  return 'Name cannot be empty';
                                }
                                return null;
                              },
                                decoration: InputDecoration(
                                  hintText: 'Contact Name',
                                  fillColor: Colors.white,
                                  filled: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.amberAccent, width: 2.0),
                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                ),),
                          ),
                          Padding(
                            padding: ktextFieldPadding,
                            child: TextFormField(
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black),
                                onChanged: (value) {
                                  phone = value;
                                },
                                validator: (phone) {
                                  if (phone == null || phone.isEmpty) {
                                    return 'Phone number must be entered';
                                  }
                                  if (!phone.contains(RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)'))) {
                                    return "Please enter a valid phone number";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Phone with country code',
                                  fillColor: Colors.white,
                                  filled: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.amberAccent, width: 2.0),
                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                )),
                          ),
                          Padding(
                            padding: ktextFieldPadding,
                            child: TextFormField(
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black),
                                onChanged: (value) {
                                  contactEmail = value;
                                },
                              validator: (contactEmail) {
                                if (contactEmail == null || contactEmail.isEmpty) {
                                  return 'Email must be entered';
                                }
                                if (!contactEmail.contains(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"))) {
                                  return "Please enter a valid email";
                                }
                                return null;
                              },
                                decoration:InputDecoration(
                                  hintText: 'Contact email',
                                  fillColor: Colors.white,
                                  filled: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.amberAccent, width: 2.0),
                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                ),),
                          ),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  _firestore.collection('emergency_contacts').add({
                                    'name': name,
                                    'email': contactEmail,
                                    'phone': phone,
                                    'userID': userID,
                                  });
                                  name = '';
                                  phone='';
                                  contactEmail='';
                                  Navigator.pushNamed(context, EmergencyContact.id);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(60.0, 30, 60, 30),
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
                                      'Save Contact',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
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
