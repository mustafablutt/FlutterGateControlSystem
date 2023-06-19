import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gate_control_system/utils/smart_device_box.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:hidden_drawer_menu/controllers/simple_hidden_drawer_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // padding constants
  final double horizontalPadding = 40;
  final double verticalPadding = 25;
  SimpleHiddenDrawerController? controller;

  final user = FirebaseAuth.instance.currentUser!;
  final databaseReference = FirebaseDatabase.instance.ref().child('LED_STATUS');
  String username = '';

  // sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }



  @override
  void initState() {
    super.initState();
    getLedStatus();
    getUsername();
  }

  void getLedStatus() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('LED_STATUS');

    // Get the data once
    DatabaseEvent event = await ref.once();

    // Check the data of the snapshot
    if (event.snapshot.value != null) {
      print("Debug Log: LED_STATUS value is ${event.snapshot.value}");
      setState(() {
        mySmartDevices[0][2] = event.snapshot.value == 1;
      });
    } else {
      print("Debug Log: LED_STATUS value is null");
    }
  }

  void getUsername() async {
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users').child(user.uid);

    // get the user snapshot
    DataSnapshot userSnapshot = await userRef.get();

    // check if the snapshot exists
    if (userSnapshot.exists) {
      setState(() {
        username = userSnapshot.child('username').value.toString();
      });
    }
  }

  // list of smart devices
  List mySmartDevices = [
    // [ smartDeviceName, iconPath , powerStatus ]
    ["Smart Gate", "lib/icons/light-bulb.png", false],
  ];
  void ledControl(bool status) async {
    if (status) {
      recordLedActivity(user.uid, status ? 1 : 0);
      // Buton açıldığında 1 değerini gönder
      await databaseReference.set(1); // Kapıyı açık olarak işaretle
      Fluttertoast.showToast(
        msg: "Door has been opened!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      // 5 saniye sonra kapıyı kapat
      Future.delayed(Duration(seconds: 1), () async {
        await databaseReference.set(0); // Kapıyı kapalı olarak işaretle
        setState(() {
          mySmartDevices[0][2] = false; // Butonun LED status değerini 0 (kapalı) olarak güncelle
        });
      });
    } else {
      setState(() {
        mySmartDevices[0][2] = false; // Butonun LED status değerini 0 (kapalı) olarak güncelle
      });
    }
  }






  // Record LED activity
  void recordLedActivity(String userId, int ledStatus) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('LED_ACTIVITIES');
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users').child(userId);

    // get the user snapshot
    DataSnapshot userSnapshot = await userRef.get();

    // check if the snapshot exists
    if (userSnapshot.exists) {
      // get the current time
      String timeStamp = DateTime.now().toIso8601String();

      // create a new activity entry
      try {
        String formattedTime = DateFormat('d MMM y, \'Time:\' HH:mm').format(DateTime.parse(timeStamp));

        await ref.push().set({
          'username': username.isNotEmpty ? username : (user.email == "mymail1@gmail.com" ? "Admin" : "User"),
          'timestamp': formattedTime,
          'led_status': ledStatus,
        });
        print('Debug Log: Activity record created successfully');
      } catch (e) {
        print('Debug Log: Error while creating activity record: $e');
      }
    } else {
      print('Debug Log: User snapshot does not exist');
    }
  }



  // power button switched
  void powerSwitchChanged(bool value, int index) {
    setState(() {
      mySmartDevices[index][2] = value;
    });
    ledControl(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (user.email == "mymail1@gmail.com")
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          SimpleHiddenDrawerController.of(context).open();
                        },
                        child: Image.asset(
                          'lib/icons/menu.png',
                          height: 45,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  if (user.email != "mymail1@gmail.com")
                    Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey[800],
                    ),
                  IconButton(
                    padding: EdgeInsets.only(top: 0.0),
                    icon: Icon(
                      Icons.logout,
                      size: 45,
                      color: Colors.grey[800],
                    ),
                    onPressed: () {
                      signUserOut();
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Apartment,",
                    style: TextStyle(fontSize: 20, color: Colors.grey.shade800),
                  ),
                  Text(
                    username.isNotEmpty ? username : (user.email == "mymail1@gmail.com" ? "Management" : "User"),
                    style: GoogleFonts.bebasNeue(fontSize: 52),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Divider(
                thickness: 1,
                color: Color.fromARGB(255, 204, 204, 204),
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Text(
                "Smart Devices",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                itemCount: 1,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 25),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1 / 1.3,
                ),
                itemBuilder: (context, index) {
                  return SmartDeviceBox(
                    smartDeviceName: mySmartDevices[index][0],
                    iconPath: mySmartDevices[index][1],
                    powerOn: mySmartDevices[index][2],
                    onChanged: (value) => powerSwitchChanged(value, index),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}