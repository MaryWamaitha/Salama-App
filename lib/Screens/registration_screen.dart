import 'package:salama/Screens/bottommenu.dart';
import 'package:salama/constants.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'main_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  //creating an instance of firestore
  final _firestore = FirebaseFirestore.instance;

  //we create the the authentification as private to avoid other classes from tampering with it
  final _auth = FirebaseAuth.instance;
  String email;
  String username;
  String status = 'inactive';
  String password;
  String cPassword;
  bool showSpinner = false;
  int available = 0;
  String tokenID;

  //the method is used to initialize and set the one Signal app ID, and also gets the device token ID which is used to send notifications
  void configOneSignel() async {
    OneSignal.shared.setAppId("25effc79-b2cc-460d-a1d0-dfcc7cb65146");
    var Notifystatus = await OneSignal.shared.getDeviceState();
    String tokenID = Notifystatus.userId;
  }

  //initiliazing the form which is used for registering. Additionally, once the form is validated, thats when the registration can happen
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    configOneSignel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                //the final hero widget
                //the hero widgets need to share the same tag
                Flexible(
                  child: Hero(
                    tag: 'logo',
                    child: Container(
                      height: 200.0,
                      child: Image.asset('images/logo.png'),
                    ),
                  ),
                ),
                SizedBox(
                  height: 24.0,
                ),
                TextFormField(
                  //this puts the @ sign in the keyboard when typing emails
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                  onChanged: (value) {
                    email = value;
                  },
                  validator: (email) {
                    if (email == null || email.isEmpty) {
                      return 'Email must be entered';
                    }
                    if (!email.contains(RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"))) {
                      return "Please enter a valid email";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kMainColour, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kMainColour, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextFormField(
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                  onChanged: (value) async {
                    username = value.toString().trim();
                    final QuerySnapshot result = await _firestore
                        .collection('users')
                        .where('username', isEqualTo: username)
                        .get();
                    final List<DocumentSnapshot> documents = result.docs;
                    available = documents.length;
                  },
                  //validator is useed to check if the username field is empty and if it is, an error, the returned value is displayed as an error
                  validator: (username) {
                    if (username == null || username.isEmpty) {
                      return 'Please enter a username';
                    } else {
                      return null;
                    }
                  },
                  // decoration  for the textfield
                  decoration: InputDecoration(
                    hintText: 'Enter a unique Username',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kMainColour, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kMainColour, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                //password textfield and decoration
                TextFormField(
                  //obscure text is what makes passwords look like passwords
                  obscureText: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                  onChanged: (value) {
                    password = value; //Do something with the user input.
                  },
                  //validator is useed to check if the password field is empty and if it is, an error, the returned value is displayed as an error
                  validator: (password) {
                    if (password == null || password.isEmpty) {
                      return 'Please enter a password';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    //TODO: Managing password to match the reentered one
                    hintText: 'Enter your password',
                    fillColor: Colors.blueGrey,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kMainColour, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kMainColour, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),

                TextFormField(
                  //obscure text is what makes passwords look like passwords
                  obscureText: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                  onChanged: (value) {
                    cPassword = value; //Do something with the user input.
                  },
                  //validator is used to check if the repeat password field is empty and if it is, an error, the returned value is displayed as an error
                  //the validator also confirms if the entered password is equal to what was previously entered, and if it is not, an error is displayed
                  validator: (cPassword) {
                    if (cPassword == null || cPassword.isEmpty) {
                      return 'Please enter a password';
                    } else if (cPassword != password) {
                      return 'The passwords do not much, please try again';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Repeat the password entered',
                    fillColor: Colors.blueGrey,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kMainColour, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kMainColour, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 24.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Material(
                    color: kMainColour,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    elevation: 5.0,
                    child: MaterialButton(
                      onPressed: () async {
                        //if all the form text fields are valid, then the following instructions are implemented
                        if (_formKey.currentState.validate()) {
                         //checking if there is a user record with the same name since usernames are expected to be unique
                          final QuerySnapshot result = await _firestore
                              .collection('users')
                              .where('username', isEqualTo: username)
                              .get();
                          final List<DocumentSnapshot> documents = result.docs;
                          available = documents.length;
                          //if a record with the same username exists, a dialog box comes up that displays the error
                          if (available > 0) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(' Username is already taken'),
                                content: Text(
                                    'Usernames need to be unique. Please enter another username'),
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
                            //if the username does not include in the database, the user details are saved to the user table
                            try {
                              _firestore.collection('users').add({
                                'email': email,
                                'username': username,
                                'status': status,
                                'location': GeoPoint(0, 0),
                                'tokenID': tokenID,
                              });
                              final newUser =
                                  await _auth.createUserWithEmailAndPassword(
                                      email: email, password: password);
                              if (newUser != null) {
                                showSpinner = false;
                                //once the process happens successfully, the user is redirected to the main screen
                                Navigator.pushNamed(context, HomePage.id);
                              }
                            } on FirebaseAuthException catch (e) {
                              //if an error pops up during the process, it is displayed in a dialog box
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('Ops! Registration Failed'),
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
                          }
                        }
                      },
                      minWidth: 200.0,
                      height: 42.0,
                      child: Text(
                        'Register',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
