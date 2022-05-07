import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Services {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  Future<String> signIn({String email, String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return 'Signed In';
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String> signUp({String email, String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      CollectionReference users = _firestore.collection('users');
      users
          .doc(_auth.currentUser.uid)
          .set({'email': email, 'user_uid': _auth.currentUser.uid})
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));

      return 'Signed Up';
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String> resetPassword(email) async {
    await _auth.sendPasswordResetEmail(email: email);
    return 'reset password email sent';
  }

  Future<String> signOut() async {
    await _auth.signOut();
    return 'Signed Out';
  }
}
