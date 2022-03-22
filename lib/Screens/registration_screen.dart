import 'package:salama/constants.dart';

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

  final _formKey = GlobalKey<FormState>();
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
                    email = value; //Do something with the user input.
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blueAccent, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blueAccent, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextFormField(
                  //this puts the @ sign in the keyboard when typing emails
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
                    validator:
                    (value) {
                      if (username == null || username.isEmpty) {
                        return 'Please enter some text';
                      } else if (documents.length > 0) {
                        return 'Username is already taken';
                      } else {
                        username = value;
                        return null;
                      }
                    };
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter a unique Username',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blueAccent, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blueAccent, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextField(
                  //obscure text is what makes passwords look like passwords
                  obscureText: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                  onChanged: (value) {
                    password = value; //Do something with the user input.
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
                      borderSide:
                          BorderSide(color: Colors.blueAccent, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blueAccent, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextField(
                  //obscure text is what makes passwords look like passwords
                  obscureText: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                  onChanged: (value) {
                    cPassword = value; //Do something with the user input.
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
                      borderSide:
                          BorderSide(color:kMainColour, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: kMainColour, width: 2.0),
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
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    elevation: 5.0,
                    child: MaterialButton(
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          final QuerySnapshot result = await _firestore
                              .collection('users')
                              .where('username', isEqualTo: username)
                              .get();
                          final List<DocumentSnapshot> documents = result.docs;
                          if (documents.length != 0) {
                            print('username exists');
                            setState(() {
                              Text(
                                  'The Username is taken.Please enter a new username',
                                  style: kErrorTextStyle);
                            });
                          } else {
                            final QuerySnapshot emailresult = await _firestore
                                .collection('users')
                                .where('email', isEqualTo: email)
                                .get();
                            final List<DocumentSnapshot> emaildocuments =
                                emailresult.docs;
                            if (emaildocuments.length == 0) {
                              if (password == cPassword) {
                                setState(() {
                                  Text('The passwords entered do not much',
                                      style: kErrorTextStyle);
                                });
                                //TODO: Make username a unique field and show error if duplicated
                                try {
                                  _firestore.collection('users').add({
                                    'email': email,
                                    'username': username,
                                    'status': status,
                                  });
                                  final newUser = await _auth
                                      .createUserWithEmailAndPassword(
                                          email: email, password: password);
                                  if (newUser != null) {
                                    showSpinner = false;
                                    Navigator.pushNamed(context, MainScreen.id);
                                  }
                                } on FirebaseAuthException catch (e) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(' Ops! Registration Failed'),
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
                            } else {
                              setState(() {
                                Text(
                                    'The Username is taken.Please enter a new username',
                                    style: kErrorTextStyle);
                              });
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
