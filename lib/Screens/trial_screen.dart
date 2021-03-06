import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class RoutesWidget extends StatefulWidget {
  static String id = 'trial_screen';

  @override
  _RoutesWidgetState createState() => _RoutesWidgetState();
}

class _RoutesWidgetState extends State<RoutesWidget> {
  TextEditingController textEditingController = TextEditingController();
  String currentText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KindaCode.com'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: PinCodeTextField(
            length: 6,
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