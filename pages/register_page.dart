import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_authentication/services/authentication_service.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState(); // Now public
}

class RegisterPageState extends State<RegisterPage> { // Now public

  bool _obscureText = true;
  String? _username, _email, _password;
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DateTime timestamp = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alinghawa App Firebase learning"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _showTitle(),
                  _showUsernameInput(),
                  _showEmailInput(),
                  _showPasswordInput(),
                  _showFormActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _showTitle() {
    return const Text(
      "Register",
      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    );
  }

  Widget _showUsernameInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: TextFormField(
        onSaved: (val) => _username = val?.trim(),
        validator: (val) =>
            val == null || val.length < 6 ? "Username is too short." : null,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Username",
          hintText: "Enter Valid Username",
          icon: Icon(Icons.face, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: TextFormField(
        onSaved: (val) => _email = val?.trim(),
        validator: (val) =>
            val == null || !val.contains("@") ? "Invalid Email" : null,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Email",
          hintText: "Enter Valid Email",
          icon: Icon(Icons.mail, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: TextFormField(
        onSaved: (val) => _password = val,
        validator: (val) =>
            val == null || val.length < 6 ? "Password is too short" : null,
        obscureText: _obscureText,
        decoration: InputDecoration(
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscureText = !_obscureText),
            child: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          ),
          border: const OutlineInputBorder(),
          labelText: "Password",
          hintText: "Enter Valid Password",
          icon: const Icon(Icons.lock, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _showFormActions() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          _isSubmitting
              ? CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                )
              : ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    elevation: 8.0,
                    backgroundColor: const Color.fromARGB(255, 80, 230, 142),
                    foregroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  child: const Text("Submit", style: TextStyle(fontSize: 18)),
                ),
        ],
      ),
    );
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      _registerUser();
    } else {
      _showErrorSnack("Form is invalid");
    }
  }

  Future<void> _registerUser() async {
    if (_email == null || _password == null || _username == null) {
      _showErrorSnack("Please fill all fields");
      return;
    }

    setState(() => _isSubmitting = true);

    final logMessage = await context
        .read<AuthenticationService>()
        .signUp(email: _email!, password: _password!);

    if (logMessage == "Signed Up") {
      _showSuccessSnack(logMessage);
      await createUserInFirestore();
    } else {
      _showErrorSnack(logMessage);
      setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        content: Text(message, style: const TextStyle(color: Colors.green)),
      ),
    );
    _formKey.currentState?.reset();
  }

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color.fromARGB(255, 233, 231, 231),
        content: Text(message, style: const TextStyle(color: Colors.red)),
      ),
    );
    setState(() => _isSubmitting = false);
  }

  Future<void> createUserInFirestore() async {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      _showErrorSnack("Error creating user profile. Try again.");
      return;
    }

    try {
      await context.read<AuthenticationService>().addUserToDB(
            uid: currentUser.uid,
            username: _username!,
            email: currentUser.email ?? _email!,
            timestamp: timestamp,
          );
    } catch (e) {
      _showErrorSnack("Error saving user to Firestore.");
      debugPrint("Error creating user in Firestore: $e");
    }
  }
}
