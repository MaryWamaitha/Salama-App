// import 'package:salama/constants.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:async';
// import 'dart:math';
// final _auth = FirebaseAuth.instance;
// final _firestore = FirebaseFirestore.instance;
// String creator;
//
// void getCurrentUser() async {
//   //once a user is registered or logged in then this current user will have  a variable
//   //the current user will be null if nobody is signed in
//   try {
//     final user = _auth.currentUser;
//     if (user != null) {
//       loggedInUser = user;
//       var member1 = loggedInUser.email;
//       final QuerySnapshot activity = await _firestore
//           .collection('users')
//           .where('email', isEqualTo: member1)
//           .get();
//       final List<DocumentSnapshot> selected = activity.docs;
//       var x = selected[0].data() as Map;
//       creator = x['username'];
//     }
//   } catch (e) {
//     print(e);
//   }
// }