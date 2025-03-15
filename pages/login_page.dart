import 'package:flutter/material.dart';
import 'package:firebase_authentication/services/authentication_service.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState(); // Now public
}

class LoginPageState extends State<LoginPage> { // Now public

  bool _obscureText = true;
  String? _email, _password;
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Alinghawa App Firebase learning"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _showTitle(),
                  _showEmailInput(),
                  _showPasswordInput(),
                  _showFormActions()
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
      "Login",
      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
                    backgroundColor: Colors.orange,
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
      _loginUser();
    } else {
      _showErrorSnack("Form is invalid");
    }
  }

  Future<void> _loginUser() async {
    if (_email == null || _password == null) {
      _showErrorSnack("Please enter email and password");
      return;
    }

    setState(() => _isSubmitting = true);

    final logMessage = await context
        .read<AuthenticationService>()
        .signIn(email: _email!, password: _password!);

    if (logMessage == "Signed In") {
      _showSuccessSnack(logMessage);
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
        backgroundColor: Colors.black,
        content: Text(message, style: const TextStyle(color: Colors.red)),
      ),
    );
    setState(() => _isSubmitting = false);
  }
}
