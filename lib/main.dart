import 'package:flutter/material.dart';
import 'package:gate_control_system/hidden_drawer.dart';
import 'package:gate_control_system/pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gate_control_system/pages/register_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => AuthPage(),
        '/home': (context) => HiddenDrawer(),

      },
    );
  }
}
