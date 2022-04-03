import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salama/Screens/create_pin.dart';
import 'main_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../constants.dart';
import 'emergency_contacts.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kBackgroundColour,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(100.0),
            child: AppBar(
              automaticallyImplyLeading: false,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                  bottomRight: Radius.circular(100),
                ),
              ),
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 40, 10, 10),
            child: Column(
              children: [
                settingsItems(
                  mainText: 'Emergency Contacts',
                  explanation:
                      'Edit your emergency contacts, add new ones \n or delete existing ones here',
                  page: EmergencyContact.id,
                ),
                SizedBox(
                  height: 60,
                ),
                settingsItems(
                  mainText: 'Security Code',
                  explanation:
                      'Set your security code which you can use to let \n people tracking you know you are safe',
                  page: CreatePin.id,
                ),
              ],
            ),
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
