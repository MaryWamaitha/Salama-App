import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:salama/Components/icons.dart';
import '../constants.dart';
import 'repeat_pin.dart';
import 'package:salama/models/getUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'active_group_screen.dart';

final _firestore = FirebaseFirestore.instance;

class CreatePin extends StatefulWidget {
  static String id = 'create_pin';

  @override
  _CreatePinState createState() => _CreatePinState();
}

class _CreatePinState extends State<CreatePin> {
  TextEditingController textEditingController = TextEditingController();
  String currentText = "";
  getDetails Details = getDetails();
  String username;
  String userID;
  bool safety = true;

  void isSafe () async {
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
      }
      } catch (e) {
      print(e);
    }
  }
  void initState() {
    super.initState();
    isSafe();
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
      body: safety != false
          ? Container(
        color: kBackgroundColour,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10,40,10,30),
                child: Container(
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
                        keyboardType: TextInputType.number,
                        obscureText: false,
                        animationType: AnimationType.fade,
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
                        onCompleted: (v) {
                          Navigator.pushNamed(context, RepeatPin.id, arguments: {
                            "pin": currentText,
                          });
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
              ),
            ),
            Menu(),
          ],
        ),
      ) : Padding(
        padding: EdgeInsets.only(top: 120),
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
                                'You cannot set a pin while unsafe in a group. Please ask \n your friends to mark you as safe for you to be able to set your pin'),
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
