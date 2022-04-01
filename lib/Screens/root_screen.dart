// import 'package:flutter/material.dart';
//
// class RootScreen extends StatefulWidget {
//   @override
//   _RootScreenState createState() => _RootScreenState();
// }
//
// class _RootScreenState extends State<RootScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Flutter Bottom Navbar Tutorial w/ Bloc'),
//       ),
//       bottomNavigationBar: BlocBuilder<NavigationCubit, NavigationState>(
//         builder: (context, state) {
//           return BottomNavigationBar(
//             currentIndex: state.index,
//             showUnselectedLabels: false,
//             items: [
//               BottomNavigationBarItem(
//                 icon: Icon(
//                   Icons.home,
//                 ),
//                 label: 'Home',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(
//                   Icons.settings,
//                 ),
//                 label: 'Settings',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(
//                   Icons.person,
//                 ),
//                 label: 'Profile',
//               ),
//             ],
//             onTap: (index) {
//               if (index == 0) {
//                 BlocProvider.of<NavigationCubit>(context)
//                     .getNavBarItem(NavbarItem.home);
//               } else if (index == 1) {
//                 BlocProvider.of<NavigationCubit>(context)
//                     .getNavBarItem(NavbarItem.settings);
//               } else if (index == 2) {
//                 BlocProvider.of<NavigationCubit>(context)
//                     .getNavBarItem(NavbarItem.profile);
//               }
//             },
//           );
//         },
//       ),
//       body: BlocBuilder<NavigationCubit, NavigationState>(
//           builder: (context, state) {
//             if (state.navbarItem == NavbarItem.home) {
//               return HomeScreen();
//             } else if (state.navbarItem == NavbarItem.settings) {
//               return SettingsScreen();
//             } else if (state.navbarItem == NavbarItem.profile) {
//               return ProfileScreen();
//             }
//             return Container();
//           }),
//     );
//   }
// }