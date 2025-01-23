import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/colors.dart';

class Aboutpage extends StatelessWidget {
  const Aboutpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Info",style: TextStyle(color: Colors.white),),
      
      backgroundColor: AppColors.primaryColor,
      
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text("Privacy Policy")
          ],
        ),
      ),
    );
  }
}