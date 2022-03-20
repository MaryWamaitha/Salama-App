import 'package:flutter/material.dart';

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kErrorTextStyle = TextStyle(
  color: Colors.red,
  fontWeight: FontWeight.bold,
  fontSize: 14.0,
);

const kMajorHeadings = TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.w700,
  color: Colors.white,
);


const divider =Divider(
thickness: 1, // thickness of the line
color: Colors
    .white70, // The color to use when painting the line.
height: 20, // The divider's height extent.
);
const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
);

const kMainColour = Color(0xff466558);
const kPageColour = Color(0xff31463d);
const kBackgroundColour = Color(0xff24342e);

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter a value',
  hintStyle: TextStyle(color: Colors.black),
  contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(7)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(7.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black, width: 1.5),
    borderRadius: BorderRadius.all(Radius.circular(7)),
  ),
);
