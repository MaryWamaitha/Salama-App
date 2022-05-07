import 'package:flutter/material.dart';
import 'package:salama/Screens/active_group_screen.dart';
import 'package:salama/Screens/create_screen2.dart';
import 'package:salama/Screens/safe_word.dart';
import 'create_screen1.dart';
import 'invite_screen.dart';
import'main_screen.dart';
import 'settings.dart';
import 'package:salama/constants.dart';


class PinMenu extends StatefulWidget {
  static String id = 'pin_menu';

  @override
  _PinMenuState createState() => _PinMenuState();
}

class _PinMenuState extends State<PinMenu> {
  int selectedPage = 0;

  final _pageOptions = [
    MainScreen(),
    Invite(),
    CreateGroup(),
    SafeWord(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: _pageOptions[selectedPage],
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: 'Home', backgroundColor: kMainColour),
            BottomNavigationBarItem(icon: Icon(Icons.person_add, size: 30), label: 'Invites', backgroundColor: kMainColour),
            BottomNavigationBarItem(icon: Icon(Icons.people, size: 30), label:'Create Group', backgroundColor: kMainColour),
            BottomNavigationBarItem(icon: Icon(Icons.location_on_rounded, size: 30), label:'Active Group', backgroundColor: kMainColour),
            BottomNavigationBarItem(icon: Icon(Icons.settings, size: 30), label:'Settings', backgroundColor: kMainColour),
          ],
          selectedItemColor: Colors.white70,
          elevation: 5.0,
          unselectedItemColor:Colors.white70,
          currentIndex: selectedPage,
          onTap: (index){
            setState(() {
              selectedPage = index;
            });
          },
        )
    );
  }
}