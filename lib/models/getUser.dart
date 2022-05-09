import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

User loggedInUser;
LatLng userLocation;
double userLatitude;
final _firestore = FirebaseFirestore.instance;
Map userDets;
List<DocumentSnapshot> selected =[];

class getDetails {
  final _auth = FirebaseAuth.instance;
  Future <List<DocumentSnapshot>> getUserDetail() async {
    //once a user is registered or logged in then this current user will have  a variable
    //the current user will be null if nobody is signed in
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        var member1 = loggedInUser.email;
        final QuerySnapshot activity = await _firestore
            .collection('users')
            .where('email', isEqualTo: member1)
            .get();
           selected = activity.docs;
        //TODO: What happens if invite does not exist
      }
    } catch (e) {
      print(e);
    }
    return selected;
  }
}
