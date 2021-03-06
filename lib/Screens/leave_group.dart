import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:salama/Screens/active_group_screen.dart';
import '../constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salama/models/getUser.dart';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt_io.dart';
import 'dart:async';
import 'bottommenu.dart';
import 'main_screen.dart';
import 'package:salama/utilities/rsa_helper.dart';
import 'package:salama/Components/icons.dart';

final _firestore = FirebaseFirestore.instance;
final keyPair = RsaKeyHelper().generateKeyPair();

class LeaveGroup extends StatefulWidget {
  static String id = 'leave_group';

  @override
  _LeaveGroupState createState() => _LeaveGroupState();
}

class _LeaveGroupState extends State<LeaveGroup> {
  TextEditingController textEditingController = TextEditingController();
  String currentText = "";
  String userID;
  String username;
  getDetails Details = getDetails();
  String pin;
  Encrypter encrypter;
  Encrypted encrypted;
  String decrypted;
  String activeID;
  int set = 0;
  bool indicator = true;
  
  void Indicator() {
    Timer.periodic(Duration(seconds: 3), (timer) async {
      setState(() {
        indicator = false;
      });
      timer.cancel();
    });
  }

  void getUserDetails() async {
    try {
      List<DocumentSnapshot> result = await Details.getUserDetail();
      if (result.length > 0) {
        var x = result[0].data() as Map;
        setState(() {
          userID = selected[0].id;
          username = x['username'];
        });
        final QuerySnapshot record = await _firestore
            .collection('pins')
            .where('userID', isEqualTo: userID)
            .get();
        final List<DocumentSnapshot> found = record.docs;
        set = found.length;
        print('the pin exists ');
        var entry = found[0].data() as Map;
        pin = entry['pin'];
      }
      // final publicKey = await parseKeyFromFile<RSAPublicKey>('test/public.pem');
      // final privKey = await parseKeyFromFile<RSAPrivateKey>('test/private.pem');
      // encrypter = Encrypter(RSA(publicKey: publicKey, privateKey: privKey));
      // decrypted = encrypter.decrypt(encrypted);
      final QuerySnapshot user = await _firestore
          .collection('active_members')
          .where('username', isEqualTo: username)
          .get();
      final List<DocumentSnapshot> returned = user.docs;
      print('Group details are $result');
      setState(() {
        activeID = returned[0].id;
        // print('the active ID is $activeID');
      });
    } catch (e) {
      print(e);
    }
  }
  @override
  void initState() {
    super.initState();
    getUserDetails();
    Indicator();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPageColour,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: AppBar(
          automaticallyImplyLeading: false,
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
      body: set != 0
          ? Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60,left: 30, right: 30),
                child: Container(
                  color: Colors.black26,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Center(
                        child: PinCodeTextField(
                          length: 4,
                          obscureText: false,
                          keyboardType: TextInputType.number,
                          animationType: AnimationType.fade,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            inactiveColor: Colors.amberAccent,
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
                              await _firestore
                                  .collection("active_members")
                                  .doc(activeID)
                                  .delete();
                              await _firestore
                                  .collection("users")
                                  .doc(userID)
                                  .update({
                                'status': 'inactive',
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => HomePage(currentIndex: 0)),
                              );
                            }
                          },
                          onChanged: (value) {
                            debugPrint(value);
                            setState(() {
                              currentText = value;
                              print('the current data is $currentText');
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
                ),
              ),
              Menu()
            ],
          )
          : ModalProgressHUD(
        inAsyncCall: indicator,
            child: SafeArea(
              child: Container(
                  color: kBackgroundColour,
                  child: Column(

                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(25,15,25,0),
                          child: Container(
                            color: kMainColour,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 15.0),
                                    child: Text(
                                        'You have not set a pin but are already \n in a group. Please ask your squad to \n mark you as safe so that you can leave \n group and afterwards set a pin for future \n groups'),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, ActiveGroup.id);
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
                                          'Go Back',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Menu()
                    ],
                  ),
                ),
            ),
          ),
    );
  }
}
