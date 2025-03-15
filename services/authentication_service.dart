import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_authentication/models/user_model.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthenticationService(this._firebaseAuth);

  // User state stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign In
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "Signed In";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        return "Wrong password provided for that user.";
      } else {
        return "Something Went Wrong.";
      }
    }
  }

  // Sign Up
  Future<String> signUp({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save user details to Firestore
      await addUserToDB(
        uid: userCredential.user!.uid,
        username: email.split('@')[0], // Example: Use email prefix as username
        email: email,
        timestamp: DateTime.now(),
      );

      return "Signed Up";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        return "The account already exists for that email.";
      } else {
        return "Something Went Wrong.";
      }
    }
  }

  // Add User to Firestore Database
  Future<void> addUserToDB({
    required String uid,
    required String username,
    required String email,
    required DateTime timestamp,
  }) async {
    UserModel userModel = UserModel(
      uid: uid,
      username: username,
      email: email,
      timestamp: timestamp,
    );

    await _firestore.collection("users").doc(uid).set(userModel.toMap());
  }

  // Get User from Firestore
  Future<UserModel?> getUserFromDB({required String uid}) async {
    DocumentSnapshot doc = await _firestore.collection("users").doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Sign Out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
