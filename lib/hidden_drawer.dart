import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gate_control_system/pages/auth_page.dart';
import 'package:gate_control_system/pages/home_page.dart';
import 'package:gate_control_system/pages/login_page.dart';
import 'package:gate_control_system/pages/register_page.dart';
import 'package:gate_control_system/user/user_activity_list_screen.dart';
import 'package:gate_control_system/user/user_list_screen.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';

class HiddenDrawer extends StatefulWidget {
  const HiddenDrawer({Key? key}) : super(key: key);

  @override
  State<HiddenDrawer> createState() => _HiddenDrawerState();
}

class _HiddenDrawerState extends State<HiddenDrawer> {

  List<ScreenHiddenDrawer> _pages= [];
  final user = FirebaseAuth.instance.currentUser!;

  void initState() {
    super.initState();




    // Debug işlemi
    debugPrint('Kullanıcı e-posta adresi: ${user.email}');

    _pages = [

      ScreenHiddenDrawer(ItemHiddenMenu(
        name: 'Home Page',
        baseStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black,

        ),
        selectedStyle: const TextStyle(),
        colorLineSelected: Colors.black,
      ), const HomePage(),
      ),

      ScreenHiddenDrawer(ItemHiddenMenu(
        name: 'User List',
        baseStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black,

        ),
        selectedStyle: const TextStyle(),
        colorLineSelected: Colors.black,
      ), UserListScreen(),
      ),

      ScreenHiddenDrawer(ItemHiddenMenu(
        name: 'User Activity',
        baseStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black,

        ),
        selectedStyle: const TextStyle(),
        colorLineSelected: Colors.black,
      ), UserActivityListScreen(),
      ),

      ScreenHiddenDrawer(ItemHiddenMenu(
        name: 'Add User',
        baseStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black,

        ),
        selectedStyle: const TextStyle(),
        colorLineSelected: Colors.black,
      ), RegisterPage(),
      ),

    ];

    // Kodun geri kalanı
    // ...
  }

  @override
  Widget build(BuildContext context) {
    bool isDraggable = false;
    if (user.email == 'mymail1@gmail.com') {
      isDraggable = true;
    }

    return HiddenDrawerMenu(
      backgroundColorMenu: Colors.grey[300]!,

      screens: _pages,
      initPositionSelected: 0,
      disableAppBarDefault: true,
      slidePercent: 50,
      contentCornerRadius: 80,
      typeOpen: TypeOpen.FROM_LEFT,
      isDraggable: isDraggable,

    );
  }
}
