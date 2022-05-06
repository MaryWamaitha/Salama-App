import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:salama/Screens/active_group_screen.dart';
import 'package:salama/Screens/bottommenu.dart';
import '../constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salama/models/getUser.dart';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt_io.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'main_screen.dart';
import 'package:salama/utilities/rsa_helper.dart';
import 'package:salama/Components/icons.dart';

final _firestore = FirebaseFirestore.instance;
final keyPair = RsaKeyHelper().generateKeyPair();

class SafeWord extends StatefulWidget {
  static String id = 'safe_word';

  @override
  _SafeWordState createState() => _SafeWordState();
}

class _SafeWordState extends State<SafeWord> {
  TextEditingController textEditingController = TextEditingController();
  String currentText = "";
  String userID;
  String username;
  getDetails Details = getDetails();
  String pin;
  Encrypter encrypter;
  Encrypted encrypted;
  String decrypted;
  String groupID;
  String activeID;
  int set = 0;
  String safeWord;

  void getUserDetails() async {
    try {
      //geting the user details
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
        if ( set > 0){
          var entry = found[0].data() as Map;
          pin = entry['pin'];
        }

      }

      //using the username, we access the active_members table where we get the GID
      final QuerySnapshot user = await _firestore
          .collection('active_members')
          .where('username', isEqualTo: username)
          .get();
      final List<DocumentSnapshot> returned = user.docs;
      var data =returned[0].data() as Map;
      setState(() {
        activeID = returned[0].id;
        groupID = data[0]['gid'];
      });
      //the gid is used to get a record in the group table that matches the gid gotten and this is used  to get the safe word
      final QuerySnapshot group = await _firestore
          .collection('groups')
          .where('gid', isEqualTo: groupID)
          .get();
      final List<DocumentSnapshot> groupDoc = group.docs;
      var groupMap =groupDoc[0].data() as Map;
      setState(() {
        activeID = returned[0].id;
        safeWord = groupMap[0]['safeWord'];
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
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
                'Enter Pin',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
          ),
          backgroundColor: kMainColour,
        ),
      ),
      body:  Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: new BorderRadius.all(
                  const Radius.circular(30.0),
                )
            ),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: PinCodeTextField(
                  length: 4,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  keyboardType: TextInputType.number,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    inactiveColor: Colors.green,
                    activeFillColor: Colors.green,
                    fieldHeight: 50,
                    fieldWidth: 40,
                    selectedFillColor: Colors.yellow,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  controller: textEditingController,
                  onCompleted: (v) async {
                    if (pin != currentText) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(' Pins dont match'),
                          content: Text(
                              'The pin entered does not much the password on record'),
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
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(' Safe Word' ),
                          content: Text(
                              'The safe word for the group is $safeWord'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HomePage(currentIndex: 3,),
                                  ),
                                );
                              },
                              child: Text('Go back to group'),
                            )
                          ],
                        ),
                      );
                    }
                  },
                  onChanged: (value) {
                    debugPrint(value);
                    setState(() {
                      currentText = value;
                    });
                  },
                  beforeTextPaste: (text) {
                    return true;
                  },
                  appContext: context,
                ),
              ),
            ),
          ),
          Menu()
        ],
      )
          // : Container(
          //     color: kBackgroundColour,
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Center(
          //           child: Padding(
          //             padding: const EdgeInsets.fromLTRB(25,2,25,0),
          //             child: Center(
          //               child: Container(
          //                 color: kMainColour,
          //                 child: Column(
          //                   mainAxisAlignment: MainAxisAlignment.center,
          //                   children: [
          //                     Center(
          //                       child: Padding(
          //                         padding: const EdgeInsets.only(top: 15.0),
          //                         child: Text(
          //                             'You have not set a pin and hence cannot see the Safe Word.\n Please go to settings to set pin'),
          //                       ),
          //                     ),
          //                     TextButton(
          //                       onPressed: () {
          //                         Navigator.pushNamed(context, ActiveGroup.id);
          //                       },
          //                       child: Padding(
          //                         padding: const EdgeInsets.fromLTRB(60.0, 30, 60, 60),
          //                         child: Container(
          //                           decoration: BoxDecoration(
          //                               color: Colors.amberAccent,
          //                               borderRadius: new BorderRadius.all(
          //                                 const Radius.circular(30.0),
          //                               )),
          //                           height: 50,
          //                           width: 150.00,
          //                           child: Center(
          //                             child: Text(
          //                               'Go Back',
          //                               style: TextStyle(
          //                                 color: Colors.black,
          //                               ),
          //                             ),
          //                           ),
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //             ),
          //           ),
          //         ),
          //         Menu()
          //       ],
          //     ),
          //   ),
    );
  }
}
