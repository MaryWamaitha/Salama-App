import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salama/constants.dart';

class CreateGroup extends StatefulWidget {
  static String id = 'create_group_screen';
  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(100),
              bottomRight: Radius.circular(100),
            ),
          ),
          title: Center(
            child: Text(
              'CREATE GROUP',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ),
          backgroundColor: kMainColour,
        ),
      ),
      body: SafeArea(
        child: Column(),
      ),
    );
  }
}
