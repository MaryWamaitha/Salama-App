import 'package:flutter/material.dart';
import 'package:salama/Screens/active_group_screen.dart';
import '../constants.dart';
import '../Screens/create_group_screen.dart';
import '../Screens/trial_screen.dart';
import '../Screens/invite_screen.dart';
import '../Screens/moving_screen.dart';
import '../Screens/settings.dart';
import '../Screens/main_screen.dart';

class MenuItem extends StatelessWidget {
  MenuItem({this.icon, this.label, this.page});
  final IconData icon;
  final String label;
  final String page;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: Colors.white70,
            size: 30.0,
          ),
          onPressed: () {
            Navigator.pushNamed(context, page);
          },
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
          ),
        )
      ],
    );
  }
}

class Menu extends StatelessWidget {
  const Menu({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      color: kMainColour,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MenuItem(
              icon: Icons.home,
              label: 'Home',
              page: MainScreen.id,
            ),
            MenuItem(
              icon: Icons.person_add,
              label: 'Invites',
              page: Invite.id,
            ),
            MenuItem(
              icon: Icons.people,
              label: 'Create Group',
              page: CreateGroup.id,
              //Go to Group screen,
            ),
            MenuItem(
              icon: Icons.location_on_rounded,
              label: 'Active Group',
              page: ActiveGroup.id,
            ),
            MenuItem(icon: Icons.directions_car, label: 'Moving', page: Moving.id,),
            MenuItem(icon: Icons.settings, label: 'Settings', page: SettingsPage.id,),
          ],
        ),
      ),
    );
  }
}
