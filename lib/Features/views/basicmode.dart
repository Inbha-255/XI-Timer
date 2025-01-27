import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import 'add_athlete.dart';

class BasicModeScreen extends StatefulWidget {
  const BasicModeScreen({super.key});

  @override
  State<BasicModeScreen> createState() => _BasicModeScreenState();
}

class _BasicModeScreenState extends State<BasicModeScreen> {
  Athlete? selectedAthlete;

  @override
  void initState() {
    super.initState();
    // Retrieve the passed athlete from the previous screen, if any
    selectedAthlete = Get.arguments as Athlete?;
  }

  void _navigateToSelectAthlete() async {
    // Navigate to SelectAthletePage using GetX and await the selected athlete
    final athlete = await Get.to(() => const AddAthletePage());

    if (athlete != null && athlete is Athlete) {
      // Update the selected athlete
      setState(() {
        selectedAthlete = athlete;
      });
    }
  }

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
            // Navigate back to Homepage using GetX
            Get.offNamed('/home');
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            color: Colors.white,
            onPressed: () {
              // Show help dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Basic Mode'),
                    content: const Text(
                        "In Basic Mode, the session begins when the 'Manual Start' button is clicked."
                        "It starts recording time and ends automatically upon detecting the athlete's motion."
                        "\nNote: The camera must remain fixed and steady without any movement"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Get.back();
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
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          // Show help dialog
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
                                      Get.back();
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

                  // Display selected athlete's details if available
                  if (selectedAthlete != null)
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(
                          8.0), // Add some padding around the container
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 15, // Adjust the size of the CircleAvatar
                            backgroundColor: AppColors.primaryColor,
                            child: Text(
                              selectedAthlete!.number.toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(
                              width:
                                  8), // Adjust this to control spacing between avatar and text
                          Text(
                            selectedAthlete!.name ?? 'Unknown Athlete',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ElevatedButton(
                      onPressed: _navigateToSelectAthlete,
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
                  if (selectedAthlete != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Session started for ${selectedAthlete!.name ?? 'Unknown Athlete'}')),
                    );
                    Get.offNamed('/stopwatch');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select an athlete first!')),
                    );
                  }
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
