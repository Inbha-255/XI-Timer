import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import Get package for navigation
import '../../constants/colors.dart';
import 'add_athlete.dart';

class BasicModeScreen extends StatefulWidget {
  const BasicModeScreen({super.key});

  @override
  State<BasicModeScreen> createState() => _BasicModeScreenState();
}

class _BasicModeScreenState extends State<BasicModeScreen> {
  String? selectedAthlete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "Basic Mode",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () {
            // Navigate back to Homepage
            Get.offNamed('/home');
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          "Athlete",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Athlete'),
                                content: const Text(
                                  "Athletes are assigned lap times to track individual performance during a session "
                                  "and review it later in the history. "
                                  "In Basic Mode, you can focus on timing just one athlete, keeping it simple and streamlined.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.help),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                          bottom: 10,
                          left: 10,
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SelectAthletePage(),
                              ),
                            ).then((selected) {
                              if (selected != null) {
                                setState(() {
                                  selectedAthlete = selected as String;
                                });
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            backgroundColor: AppColors.primaryColor,
                          ),
                          child: Text(
                            selectedAthlete != null
                                ? 'Change Athlete'
                                : 'Add Athlete',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      if (selectedAthlete != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                            'Selected: $selectedAthlete',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  // Handle "Start Session" button action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: const Text(
                  "START SESSION",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
