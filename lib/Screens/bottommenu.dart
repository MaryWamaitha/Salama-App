import 'package:flutter/material.dart';
import 'package:salama/Screens/active_group_screen.dart';
import 'create_group_screen.dart';
import 'invite_screen.dart';
import 'moving_screen.dart';
import'main_screen.dart';
import 'settings.dart';


class HomePage extends StatefulWidget {
  static String id = 'bottommenu';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedPage = 0;

  final _pageOptions = [
    MainScreen(),
    Invite(),
    CreateGroup(),
    ActiveGroup(),
    Moving(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: _pageOptions[selectedPage],
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person_add, size: 30), label: 'Invites'),
            BottomNavigationBarItem(icon: Icon(Icons.people, size: 30), label:'Create Group'),
            BottomNavigationBarItem(icon: Icon(Icons.location_on_rounded, size: 30), label:'Active Group'),
            BottomNavigationBarItem(icon: Icon(Icons.directions_car, size: 30), label:'Moving'),
            BottomNavigationBarItem(icon: Icon(Icons.settings, size: 30), label:'Settings'),
          ],
          selectedItemColor: Colors.green,
          elevation: 5.0,
          unselectedItemColor: Colors.green[900],
          currentIndex: selectedPage,
          backgroundColor: Colors.white,
          onTap: (index){
            setState(() {
              selectedPage = index;
            });
          },
        )
    );
  }
}