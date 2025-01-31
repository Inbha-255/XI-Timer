import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class DetectionResultScreen extends StatefulWidget {
  final String imagePath;
  final String elapsedTime;

  const DetectionResultScreen({
    super.key,
    required this.imagePath,
    required this.elapsedTime,
  });

  @override
  DetectionResultScreenState createState() => DetectionResultScreenState();
}

class DetectionResultScreenState extends State<DetectionResultScreen> {
  String athleteName = "Unknown Athlete"; // Default value

  @override
  void initState() {
    super.initState();
    _loadAthleteName();
  }

  // Load athlete name from SharedPreferences
  Future<void> _loadAthleteName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      athleteName = prefs.getString('selectedAthlete') ?? 'Unknown Athlete';
    });
  }

  // Function to save detected data
  Future<void> _saveDetectionData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Create JSON object with detected data
    Map<String, dynamic> detectionData = {
      'time': widget.elapsedTime,
      'athleteName': athleteName,
      'imagePath': widget.imagePath,
    };

    // Retrieve existing history data
    List<String> existingData = prefs.getStringList('detectionHistory') ?? [];

    // Add new data entry
    existingData.add(jsonEncode(detectionData));

    // Save updated list to SharedPreferences
    await prefs.setStringList('detectionHistory', existingData);

    // Show confirmation message
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection Result'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display detected image
              SizedBox(
                height: 300,
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              // Display detected time
              Text(
                'Detected Time: ${widget.elapsedTime}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Display athlete's name
              Text(
                'Athlete: $athleteName', // ✅ Retrieved dynamically
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              // Save Button
              ElevatedButton(
                onPressed:
                    _saveDetectionData, // ✅ Saves data to SharedPreferences
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
