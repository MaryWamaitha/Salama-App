import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../constants.dart';

class Moving extends StatefulWidget {
  static String id = 'login_screen';
  @override
  _MovingState createState() => _MovingState();
}

class _MovingState extends State<Moving> {
  final _auth = FirebaseAuth.instance;
  String email;
  String password;
  bool showSpinner = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    );
  }
}