import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/colors.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

import '../../../Data/Modals/datas.dart';

// JSON Data

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Boolean to toggle password visibility
  bool _obscureText = true;

  // Function to validate inputs
  bool _validateInputs() {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty) {
      Get.snackbar(
        "Invalid Username",
        "Please enter a valid Username.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }

    if (password.isEmpty || password.length < 6) {
      Get.snackbar(
        "Invalid Password",
        "Password must be at least 6 characters long.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  // Function to authenticate user
  void _authenticateUser() {
    if (_validateInputs()) {
      String username = usernameController.text.trim();
      String password = passwordController.text.trim();

      // Parse JSON data

      final Map<String, dynamic> data = jsonDecode(dataJson);
      final List<dynamic> dataList = jsonDecode(dataJsonList);

      // Combine single object and list for authentication
      final List<Map<String, dynamic>> allUsers = [
        
        data,
        ...dataList.map((e) => e as Map<String, dynamic>)
      ];

      // Check if the username and password match
      final user = allUsers.firstWhereOrNull(
        (user) => user['username'] == username && user['password'] == password,
      );

      if (user != null) {
        // Successful login
        Get.snackbar(
          "Login Successful",
          "Welcome ${user['firstname']}!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        // Navigate to Home page
        Get.offNamed('/home');
      } else {
        // Failed login
        Get.snackbar(
          "Login Failed",
          "Incorrect username or password.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Login",
          style: TextStyle(color: Colors.white),
        ),
  backgroundColor: AppColors.primaryColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Login Here",
                  style: GoogleFonts.roboto(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.person, color: AppColors.primaryColor),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.lock, color: AppColors.primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _authenticateUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "LOGIN",
                    style:
                        TextStyle(color: AppColors.backgroundColor, fontSize: 18),
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Get.toNamed('/forget'); // Navigate to Forgot Password Page
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(color: AppColors.primaryColor, fontSize: 14),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.toNamed('/signup'); // Navigate to Sign-Up Page
                  },
                  child: Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(color: AppColors.primaryColor, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
