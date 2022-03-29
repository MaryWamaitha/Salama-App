import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../constants.dart';

class SettingsPage extends StatefulWidget {
  static String id = 'login_screen';
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
              settingsItems(mainText:'Emergency Contacts', explanation: 'Edit your emergency contacts, add new ones or delete here'),
              settingsItems(mainText:'Security Code', explanation: 'Set your security code which you can use to let people tracking you know you are safe'),
            ],
          ),
        ));
  }
}

class settingsItems extends StatelessWidget {
  settingsItems({this.mainText,this.explanation, this.page});
  final String mainText;
  final String explanation;
  final String page;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Text(
             mainText,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(explanation
             ,
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
