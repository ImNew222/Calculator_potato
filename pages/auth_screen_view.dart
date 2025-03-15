// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_authentication/pages/login_page.dart';
import 'package:firebase_authentication/pages/register_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AuthScreenView extends StatefulWidget {
  const AuthScreenView({super.key});

  @override
  _AuthScreenViewState createState() => _AuthScreenViewState();
}

class _AuthScreenViewState extends State<AuthScreenView> {
  late final PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  void onTap(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children: [
          LoginPage(),
          RegisterPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        onTap: onTap,
        selectedItemColor: Theme.of(context).primaryColor,
        items: const [
          BottomNavigationBarItem(
            label: "Log In",
            icon: Icon(FontAwesomeIcons.rightToBracket), // Updated icon
          ),
          BottomNavigationBarItem(
            label: "Register",
            icon: Icon(FontAwesomeIcons.userPlus),
          ),
        ],
      ),
    );
  }
}
