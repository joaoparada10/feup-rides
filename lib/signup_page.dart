import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feup_rides/form_container.dart';
import 'package:feup_rides/home.dart';
import 'package:feup_rides/profile_page.dart';
import 'package:feup_rides/user_auth/fire_base_auth_implement/fire_base_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController(); // New controller for confirming password

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                Navigator.pop(context); // Go back to the last screen
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                FormContainerWidget(
                  controller: _emailController,
                  hintText: "Email",
                  isPassword: false,
                ),
                const SizedBox(height: 10),
                FormContainerWidget(
                  controller: _passwordController,
                  hintText: "Password",
                  isPassword: true,
                ),
                const SizedBox(height: 10),
                FormContainerWidget(
                  controller: _confirmPasswordController,
                  hintText: "Confirm Password",
                  isPassword: true,
                ),
                const SizedBox(height: 30),
                SizedBox(
                    width: 160,
                    child: ElevatedButton(
                    onPressed: () {
                      _signUp();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const SizedBox(
                      height: 45,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Sign up",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.arrow_right,
                                color: Colors.black,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      print("Passwords do not match");
      return;
    }

    try {
      User? user = await _auth.signUpWithEmailAndPassword(email, password);

      if (user != null) {
        print("User is successfully created");
        await linkUserWithFirestore(user.uid);
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(userUid: user.uid)));
      } else {
        print("User is null");
      }
    } catch (e) {
      print("Signup Error: $e");
    }
  }
}

Future<void> linkUserWithFirestore(String userUid) async {
  try {
    // Reference to the Firestore document
    final DocumentReference userDocRef = FirebaseFirestore.instance.collection('Users').doc(userUid);

    // Check if the document already exists
    final DocumentSnapshot docSnapshot = await userDocRef.get();
    if (!docSnapshot.exists) {
      // If the document doesn't exist, create it
      await userDocRef.set({
        'uid': userUid,
        // Other user data can be added here
      });
      print("User document created successfully");
    }
  } catch (e) {
    print("Firestore linking error: $e");
  }
}