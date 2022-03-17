import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salama/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_places_for_flutter/google_places_for_flutter.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';


class CreateGroup extends StatefulWidget {
  static String id = 'create_group_screen';
  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final _firestore = FirebaseFirestore.instance;
  String member ;
  String email;
  String user ;
  List<String> Users = [];
  List<String> Members = [];
  final _controller = TextEditingController();
  Future<void> getUsers() async {
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await _firestore.collection('users').get();
    ;
    // Get data from docs and convert map to List
    querySnapshot.docs.forEach((doc) {
      Users.add(doc["username"]);
      return Users;
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getUsers();
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
                'CREATE GROUP',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
          ),
          backgroundColor: kMainColour,
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.0),
              Container(
                margin: EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                    color: kPageColour,
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(30.0),
                      topRight: const Radius.circular(30.0),
                    )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, left: 12),
                      child: Text(
                        'Search for Users ',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Center(
                      child: Autocomplete<String>(
                        optionsBuilder: (TextEditingValue value) {
                          // When the field is empty
                          if (value.text.isEmpty) {
                            return [];
                          }
                          // The logic to find out which ones should appear
                          return Users.where((suggestion) => suggestion
                              .toLowerCase()
                              .contains(value.text.toLowerCase()));
                        },
                        onSelected: (value) async {
                          final QuerySnapshot activity = await _firestore
                              .collection('users')
                              .where('username', isEqualTo: value)
                              .get();
                          final List<DocumentSnapshot> available =
                              activity.docs;
                          var result = available[0].data() as Map;
                          var status = result['status'];
                          if (status == 'active') {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title:
                                    Text(' User cannot be added to group'),
                                content: Text(
                                    'The user is currently active in another group'),
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
                            setState(() {
                              // print(available);
                              Members.add(value);
                              Users.remove(value);
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Center(
                      child: Text(
                        'Group Members ',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    for (var user in Members)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Card(
                          margin: EdgeInsets.only(right: 15, left: 5),
                          color: Colors.white30,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5.0, right: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  user,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      Members.remove(user);
                                      Users.add(user);
                                    });
                                  },
                                  icon: Icon(Icons.cancel),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: 15.0),
                    Text('Where are you guys going to ?',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                        )),
                    Text(
                      'Tracking will begin once you are close to or arrive here',
                      style: TextStyle(
                        fontSize: 13.0,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Padding(
                      padding: EdgeInsets.only(right: 10, top: 10, bottom: 10),

                      child: Container(
                        height: 45.0,
                        child: TextField(
                          controller: _controller,
                          onTap: () async {
                            // placeholder for our places search later
                          },
                          obscureText: true,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            hintText: 'Search for location',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
