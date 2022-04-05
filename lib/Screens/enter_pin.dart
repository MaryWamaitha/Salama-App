import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../constants.dart';

class UnsafePin extends StatefulWidget {
  static String id = 'enter_pin';

  @override
  _UnsafePinState createState() => _UnsafePinState();
}

class _UnsafePinState extends State<UnsafePin> {
  TextEditingController textEditingController = TextEditingController();
  String currentText = "";

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
      body: Padding(
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
            onCompleted: (v) {
              print("Completed");
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
    );
  }
}