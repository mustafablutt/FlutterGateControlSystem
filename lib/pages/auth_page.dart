import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gate_control_system/hidden_drawer.dart';
import 'package:gate_control_system/pages/login_page.dart';
import 'home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user is logged in
          if (snapshot.hasData) {
            return HiddenDrawer();
          }

          // user is NOT logged in
          else {
            return LoginPage();
          }
        },
      ),
    );
  }
}