import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:salama/Screens/active_group_screen.dart';
import 'package:salama/Screens/bottommenu.dart';
import 'package:salama/Screens/create_group_screen.dart';
import 'package:salama/Screens/create_pin.dart';
import 'package:salama/Screens/emergency_contacts.dart';
import 'package:salama/Screens/moving_screen.dart';
import 'package:salama/Screens/repeat_pin.dart';
import 'Screens/welcome_screen.dart';
import 'Screens/registration_screen.dart';
import 'Screens/main_screen.dart';
import 'Screens/login_screen.dart';
import 'Screens/trial_screen.dart';
import 'Screens/invite_screen.dart';
import 'Screens/emergency_contacts.dart';
import 'Screens/settings.dart';
import 'Screens/add_contact.dart';
import 'Screens/moving_active.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Salama());
}

class Salama extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.black54),
        ),
        hintColor: Colors.grey,
      ),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        MainScreen.id: (context) => MainScreen(),
        CreateGroup.id: (context) => CreateGroup(),
        RoutesWidget.id: (context) => RoutesWidget(),
        Invite.id: (context) => Invite(),
        ActiveGroup.id: (context) => ActiveGroup(),
        EmergencyContact.id: (context) => EmergencyContact(),
        SettingsPage.id: (context) => SettingsPage(),
        AddContact.id: (context) => AddContact(),
        Moving.id: (context) => Moving(),
        MovingActive.id: (context) => MovingActive(),
        CreatePin.id: (context) => CreatePin(),
        RepeatPin.id: (context) => RepeatPin(),
      },
      //TODO: If user is already logged in on device, they should be redirected to the main_screen page
      home: WelcomeScreen(),
    );
  }
}
