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
import '../constants.dart';
import 'add_contact.dart';

const kGoogleApiKey = "AIzaSyDxzZPrCfZRX5FeTsWME8iJYl4EJiKSFQo";
final _firestore = FirebaseFirestore.instance;
String userID;
User loggedInUser;

class EmergencyContact extends StatefulWidget {
  static String id = 'emergency_contacts';
  @override
  _EmergencyContactState createState() => _EmergencyContactState();
}

class _EmergencyContactState extends State<EmergencyContact> {
  String member;
  String creator;
  String contactEmail;
  String email;
  String user;
  String place;
  String name;
  String phone;
  String safeWord = 'Not set';
  List<String> Users = [];
  List<String> Members = [];
  double distance = 1.5;
  String DistanceInfo = 'Select distance below';
  String SafeWordDetails = 'Tap the down arrow key to learn more';
  bool safety = true;
  bool inviteSent = true;
  final _controller = TextEditingController();
  final _auth = FirebaseAuth.instance;

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
                'EMERGENCY CONTACTS',
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
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(

                    child: ContactsStream()),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AddContact.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(60.0, 30, 60, 60),
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
                          'Add New',
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
      ),
    );
  }
}

class ContactsStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('emergency_contacts')
          .where('userID', isEqualTo: userID)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text(
              'You dont have an emergncy contact, /n add new ones below',
            ),
          );
        }
        final members = snapshot.data.docs.reversed;
        List<Contact> ContactList = [];
        for (var member in members) {
          final contactName = member['name'];
          final phone = member['phone'];
          final email = member['email'];
          final docuID = member.id;

          final contact = Contact(
            name: contactName,
            phone: phone,
            email: email,
            docuID: docuID,
          );

          ContactList.add(contact);
        }
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              decoration: BoxDecoration(
                  color: kPageColour,
                  borderRadius: new BorderRadius.all(
                 const Radius.circular(10.0),
                  )),
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                children: ContactList,
              ),
            ),
          ),
        );
      },
    );
  }
}

class Contact extends StatelessWidget {
  Contact({this.name, this.phone, this.email, this.docuID});

  final String name;
  final String phone;
  final String email;
  final String docuID;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8,15,18.0,15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.left,
              ),
              Text(
                phone,
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              Text(
                email,
                style: TextStyle(
                  fontSize: 11,
                ),
              )
            ],
          ),
          TextButton(
            onPressed: () {
              //TODO: when edit button is clicked, pass over the contact Id to be used in editing on edit page
            },
            child: Row(
              children: [
                Text('Edit',
               ),
                Icon(
                  Icons.arrow_forward_ios_outlined,
                  size: 15,
                )
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.white70,
              size: 20.0,
            ),
            onPressed: () async {
              await _firestore
                  .collection("emergency_contacts")
                  .doc(docuID)
                  .delete();
            },
          ),
        ],
      ),
    );
  }
}
