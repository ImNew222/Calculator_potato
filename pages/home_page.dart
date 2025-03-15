import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_authentication/models/user_model.dart';
import 'package:firebase_authentication/services/authentication_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState(); // Now public
}

class HomePageState extends State<HomePage> { // Now public

  FirebaseAuth auth = FirebaseAuth.instance;
  final userRef = FirebaseFirestore.instance.collection("users");

  UserModel? _currentUser;
  String? _uid;
  String? _username;
  String? _email;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        return;
      }

      UserModel? currentUser = await context
          .read<AuthenticationService>()
          .getUserFromDB(uid: user.uid);

      if (mounted) {
        setState(() {
          _currentUser = currentUser;
          _uid = currentUser?.uid;
          _username = currentUser?.username;
          _email = currentUser?.email;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error getting user: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HomePage"),
        centerTitle: true,
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "UID: ${_uid ?? 'N/A'}\nEmail: ${_email ?? 'N/A'}\nName: ${_username ?? 'N/A'}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await context.read<AuthenticationService>().signOut();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 8.0,
                      backgroundColor: const Color.fromARGB(255, 155, 154, 152),
                      foregroundColor:
                          Colors.black, // Preferred over TextStyle(color)
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    child: const Text("Logout", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
    );
  }
}
