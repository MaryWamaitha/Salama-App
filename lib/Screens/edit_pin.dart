import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:salama/Screens/active_group_screen.dart';
import '../constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salama/models/getUser.dart';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt_io.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'main_screen.dart';
import 'package:salama/utilities/rsa_helper.dart';
import 'package:salama/Components/icons.dart';
import 'create_pin.dart';

final _firestore = FirebaseFirestore.instance;
final keyPair = RsaKeyHelper().generateKeyPair();

class EditPin extends StatefulWidget {
  static String id = 'edit_pin';

  @override
  _EditPinState createState() => _EditPinState();
}

class _EditPinState extends State<EditPin> {
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
  bool safety = true;

  void getUserDetails() async {
    try {
      List<DocumentSnapshot> result = await Details.getUserDetail();
      if (result.length > 0) {
        var x = result[0].data() as Map;
        setState(() {
          userID = selected[0].id;
          username = x['username'];
        });
        final QuerySnapshot user = await _firestore
            .collection('active_members')
            .where('username', isEqualTo: username)
            .get();
        final List<DocumentSnapshot> returned = user.docs;
        print('Group details are $result');
        setState(() {
          safety = returned[0]['isSafe'];
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
              padding: EdgeInsets.only(top: 50.0, bottom: 15),
              child: Text(
                'Enter Current Pin',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
          ),
          backgroundColor: kMainColour,
        ),
      ),
      body: safety != false
          ? Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60,left: 30, right: 30),
                child: Container(
                  color: Colors.black26,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: PinCodeTextField(
                        length: 4,
                        obscureText: false,
                        animationType: AnimationType.fade,
                        keyboardType: TextInputType.number,
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
                                    'The pin entered does not much the pin on record'),
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
                            Navigator.pushNamed(context, CreatePin.id);
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
              Menu()
            ],
          )
          : Padding(
        padding: EdgeInsets.only(top: 120),
        child: Container(
          color: kBackgroundColour,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 15, 25, 0),
                  child: Container(
                    color: kMainColour,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Text(
                                'You cannot set a pin while unsafe in a group. Please ask \n your friends to mark you as safe for you to be able to set your pin'),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, ActiveGroup.id);
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                60.0, 30, 60, 60),
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
                                  'Go to Active Group',
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
    );
  }
}
