import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salama/Screens/create_pin.dart';
import '../Components/icons.dart';
import '../constants.dart';
import 'emergency_contacts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salama/models/getUser.dart';
import 'package:salama/Screens/edit_pin.dart';
import 'login_screen.dart';

class SettingsPage extends StatefulWidget {
  static String id = 'settings';
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _auth = FirebaseAuth.instance;
  String email;
  String password;
  bool showSpinner = false;
  getDetails Details = getDetails();
  final _firestore = FirebaseFirestore.instance;
  String username;
  int set;

  void setPin() async {
    List<DocumentSnapshot> result = await Details.getUserDetail();
    if (result.length > 0) {
      var x = result[0].data() as Map;
      setState(() {
        userID = selected[0].id;
        username = x['username'];
      });
      //using the username gotten to get the user record in the pin table and check if the user has a pin
      final QuerySnapshot record = await _firestore
          .collection('pins')
          .where('userID', isEqualTo: userID)
          .get();
      final List<DocumentSnapshot> found = record.docs;
      //getting the length of the returned document. If its length is greater than 0, it means a pin exists, set will
      //have a length that is greater than zero and we can get the pin
      set = found.length;
    }
  }

  @override
  void initState() {
    super.initState();
    setPin();
  }

  @override
  Widget build(BuildContext context) {
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
                    'SETTINGS',
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
              backgroundColor: kMainColour,
            )),
        body: SafeArea(
          child: Column(
            children: [
              // settingsItems(
              //   mainText: 'Emergency Contacts',
              //   explanation:
              //       'Edit your emergency contacts, add new ones \n or delete existing ones here',
              //   page: EmergencyContact.id,
              // ),
              // SizedBox(
              //   height: 60,
              // ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 40, 10, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Safety Pin',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Set or edit your security code which you need to leave groups \n and for viewing safe words',
                            style: TextStyle(
                              fontSize: 11.0,
                            ),
                          )
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          if (set == 0) {
                            Navigator.pushNamed(context, CreatePin.id);
                          } else {
                            Navigator.pushNamed(context, EditPin.id);
                          }
                        },
                        icon: Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: Colors.white,
                        ),
                      )
                    ],
                  )),
             divider,
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 5, 10, 10),
                child: TextButton(
                  onPressed: (){
                    _auth.signOut();
                    Navigator.pushNamed(context, LoginScreen.id);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app,
                      color: Colors.white,),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          'LogOut',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}

class settingsItems extends StatelessWidget {
  settingsItems({this.mainText, this.explanation, this.page});
  final String mainText;
  final String explanation;
  final String page;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mainText,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              explanation,
              style: TextStyle(
                fontSize: 11.0,
              ),
            )
          ],
        ),
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, page);
          },
          icon: Icon(
            Icons.arrow_forward_ios_outlined,
            color: Colors.white,
          ),
        )
      ],
    );
  }
}
