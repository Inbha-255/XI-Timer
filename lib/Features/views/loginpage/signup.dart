import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/colors.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;

  // 🔹 REPLACE WITH YOUR API URL
  final String signUpApiUrl =
      "https://api.jslpro.in:4661/register"; // Change this

  // Function to validate inputs
  bool _validateInputs() {
    String firstname = firstnameController.text.trim();
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    String namePattern = r'^[a-zA-Z]+$';
    String usernamePattern = r'^[a-zA-Z0-9]+$';
    String emailPattern = r'^[a-zA-Z0-9]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp nameRegex = RegExp(namePattern);
    RegExp usernameRegex = RegExp(usernamePattern);
    RegExp emailRegex = RegExp(emailPattern);

    if (firstname.isEmpty || !nameRegex.hasMatch(firstname)) {
      Get.snackbar("Invalid Firstname", "Please enter a valid Firstname.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    }

    if (username.isEmpty || !usernameRegex.hasMatch(username)) {
      Get.snackbar("Invalid Username", "Please enter a valid Username.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    }

    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      Get.snackbar("Invalid Email", "Please enter a valid Email address.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    }

    if (password.isEmpty || password.length < 6) {
      Get.snackbar(
          "Invalid Password", "Password must be at least 6 characters long.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    }

    return true;
  }

  // Function to handle user signup via API
  Future<void> _signUpUser() async {
    if (!_validateInputs()) return;

    // Create request body
    Map<String, dynamic> requestBody = {
      "firstname": firstnameController.text.trim(),
      "username": usernameController.text.trim(),
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
    };

    try {
      // 🔹 REPLACE WITH YOUR API URL
      final response = await http.post(
        Uri.parse(signUpApiUrl), // Replace this with your API URL
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Successful registration
        Get.snackbar("Registration Successful", "You are now registered!",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);

        // Clear input fields
        firstnameController.clear();
        usernameController.clear();
        emailController.clear();
        passwordController.clear();

        // Navigate to Login Page
        Future.delayed(const Duration(seconds: 2), () {
          Get.toNamed('/login');
        });
      } else {
        // API returned an error
        Map<String, dynamic> errorResponse = jsonDecode(response.body);
        String errorMessage = errorResponse["message"] ??
            "An error occurred during registration.";

        Get.snackbar("Registration Failed", errorMessage,
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to connect to the server.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("Sign Up", style: TextStyle(color: AppColors.backgroundColor)),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Register Here",
                style: GoogleFonts.roboto(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: firstnameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.person, color: AppColors.primaryColor),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.person, color: AppColors.primaryColor),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.email, color: AppColors.primaryColor),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUpUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("SIGN UP",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Get.toNamed('/login');
                },
                child: Text("Already have an account? Login",
                    style:
                        TextStyle(color: AppColors.primaryColor, fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
