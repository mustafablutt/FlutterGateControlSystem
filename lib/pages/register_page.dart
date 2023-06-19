import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gate_control_system/components/my_textfield.dart';
import 'package:gate_control_system/components/my_button.dart';
import 'package:gate_control_system/components/square_tile.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();

  // registration success flag
  bool registrationSuccess = false;

  // sign user up method
  void signUserUp() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // try sign up
    try {
      if (passwordController.text == confirmPasswordController.text) {
        final UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // add user data to Realtime Database
        final database = FirebaseDatabase.instance.ref();
        await database.child('users').child(userCredential.user!.uid).set({
          'email': emailController.text,
          'username': usernameController.text,
        });

        // set registration success flag
        setState(() {
          registrationSuccess = true;
        });

        // Now, sign in as the admin again
        // Now, sign in as the admin again
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: "mymail1@gmail.com",  // use your admin email here
            password: "123123",  // use your admin password here
          );
          printCurrentUserEmail();
        } catch(e) {
          // Handle error
          print("Error signing in as admin: $e");
        }


        printCurrentUserEmail();

        // pop the loading circle
        Navigator.pop(context);

        // registration successful message
        registrationSuccessfulMessage();
      } else {
        // pop the loading circle
        Navigator.pop(context);

        // Unmatched password error message
        // Create the unMatchPasswordMessage function to handle this error
        print("Unmatched passwords error.");
      }
    } on FirebaseAuthException catch (e) {
      // pop the loading circle
      Navigator.pop(context);

      if (e.code == 'email-already-in-use') {
        // email already in use
        // Create the emailAlreadyInUseMessage function to handle this error
        print("Email already in use error.");
      } else if (e.code == 'invalid-email') {
        // Invalid email error message
        // Create a new function or modify the existing wrongEmailMessage function to handle this error
        print("Invalid email error.");
      }
    }
  }



  // wrong email message popup
  void wrongEmailMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              'Incorrect Email',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  void printCurrentUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if(user != null){
      print("Current user email: ${user.email}");
    }
    else{
      print("No user is currently signed in.");
    }
  }


  // unmatched password message popup
  void unMatchPasswordMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              "Passwords don't match!",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  // email already in use message popup
  void emailAlreadyInUseMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              'The email address is already in use by another account.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  // registration successful message popup
  void registrationSuccessfulMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              'Registration Successful',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    ).then((value) {
      // clear text fields if registration is successful
      if (registrationSuccess) {
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        usernameController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // logo
                const Icon(
                  Icons.lock,
                  size: 100,
                ),

                const SizedBox(height: 50),

                // welcome back, you've been missed!
                Text(
                  'Let\'s add a new user',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                // email textfield
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 20),

                // username textfield
                MyTextField(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),

                const SizedBox(height: 20),

                // password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 20),

                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // forgot password?


                const SizedBox(height: 30),

                // sign in button
                MyButton(
                  text: 'Add a new User',
                  onTap: signUserUp,
                ),

                const SizedBox(height: 50),

                // or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),

                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // google + apple sign in buttons

                // not a member? register now

              ],
            ),
          ),
        ),
      ),
    );
  }
}