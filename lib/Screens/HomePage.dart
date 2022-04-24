// import 'package:flutter/material.dart';
// import 'package:salama/Screens/invite_screen.dart';
// import 'package:salama/Screens/active_group_screen.dart';
// import 'package:salama/Screens/main_screen.dart';
// import 'package:salama/Screens/create_group_screen.dart';
// import 'package:salama/Screens/settings.dart';
//
// class MyHomePage extends StatefulWidget {
//   static String id = 'HomePage';
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _currentIndex = 0;
//   _getDrawerItemWidget(int pos) {
//     switch (pos) {
//       case 0:
//         return new MainScreen();
//       case 1:
//         return new Invite();
//       case 2:
//         return new CreateGroup();
//       case 3:
//         return new ActiveGroup();
//       case 4:
//         return new SettingsPage();
//
//       default:
//         return new Text("Error");
//     }
//   }
//
//   List<String> titleList = ["Invites", "Home", "Create Group", "Active Group", "Settings"];
//
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;
//
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Text(titleList[_currentIndex]),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _currentIndex,
//         backgroundColor: colorScheme.surface,
//         selectedItemColor: colorScheme.onSurface,
//         unselectedItemColor: colorScheme.onSurface.withOpacity(.60),
//         selectedLabelStyle: textTheme.caption,
//         unselectedLabelStyle: textTheme.caption,
//         onTap: (value) {
//           setState(() {
//             _currentIndex = value;
//           });
//         },
//         items: [
//           BottomNavigationBarItem(
//            label: 'Home',
//             icon: Icon(Icons.favorite),
//           ),
//           BottomNavigationBarItem(
//           label: 'Invites',
//             icon: Icon(Icons.music_note),
//           ),
//           BottomNavigationBarItem(
//             label: 'Create Group' ,
//             icon: Icon(Icons.location_on),
//           ),
//           BottomNavigationBarItem(
//             label: 'Active Group' ,
//             icon: Icon(Icons.location_on),
//           ),
//           BottomNavigationBarItem(
//             label: 'Active Group' ,
//             icon: Icon(Icons.location_on),
//           ),
//         ],
//       ),
//       body: _getDrawerItemWidget(_currentIndex),
//     );
//   }
// }