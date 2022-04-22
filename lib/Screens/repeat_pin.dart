import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'settings.dart';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt_io.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:salama/Components/rsa_helper.dart';
import 'package:salama/Components/icons.dart';

final keyPair = RsaKeyHelper().generateKeyPair();

class RepeatPin extends StatefulWidget {
  static String id = 'repeat_pin';

  @override
  _RepeatPinState createState() => _RepeatPinState();
}

class _RepeatPinState extends State<RepeatPin> {
  TextEditingController textEditingController = TextEditingController();
  String currentText = "";
  String userID;
  String enteredPin;
  final _firestore = FirebaseFirestore.instance;
  String member;
  String creator;
  String email;
  String user;
  String docID;
  User loggedInUser;
  final _auth = FirebaseAuth.instance;
  Encrypter encrypter;
  Encrypted encrypted;

  void getCurrentUser() async {
    //once a user is registered or logged in then this current user will have  a variable
    //the current user will be null if nobody is signed in
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        var member1 = loggedInUser.email;
        final QuerySnapshot activity = await _firestore
            .collection('users')
            .where('email', isEqualTo: member1)
            .get();
        final List<DocumentSnapshot> selected = activity.docs;
        final x = selected[0].data() as Map;
        setState(() {
          userID = selected[0].id;
          creator = x['username'];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Object> rcvdData =
        ModalRoute.of(context).settings.arguments;
    setState(() {
      enteredPin = rcvdData['pin'];
    });
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
                'Repeat Pin',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
          ),
          backgroundColor: kMainColour,
        ),
      ),
      body: Container(
        color: kBackgroundColour,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: PinCodeTextField(
                  length: 4,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: Colors.black26,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  backgroundColor: Colors.blue.shade50,
                  enableActiveFill: true,
                  controller: textEditingController,
                  onCompleted: (v) async {
                    if (currentText != enteredPin) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('The pins dont match'),
                          content: Text(
                              'The pin you entered on this page does not match the . \n pin initially entered'),
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
                      // final publicKey = 'sAlH158';
                      // final privKey = await parseKeyFromFile<RSAPrivateKey>('test/private.pem');
                      // encrypter = Encrypter(RSA(publicKey: publicKey, privateKey: privKey));
                      // encrypted = encrypter.encrypt(currentText);
                      // var setPin = encrypted.base64;
                      // print(' password is $setPin');
                      await _firestore.collection('pins').add({
                        'pin': currentText,
                        'userID': userID,
                      });
                      Navigator.pushNamed(context, SettingsPage.id);
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
            Menu(),
          ],
        ),
      ),
    );
  }
}
