import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/constants/colors.dart';
import 'package:get/get.dart';

class Historypage extends StatefulWidget {
  const Historypage({super.key});

  @override
  State<Historypage> createState() => _HistorypageState();
}

class _HistorypageState extends State<Historypage> {
  List<Map<String, dynamic>> historyRecords = [];
  int _currentIndex = 0;
  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index; // Update the current selected index
    });
    switch (index) {
      case 0:
        Get.toNamed("/home"); // Navigate to Timer page
        break;
      case 1:
        Get.toNamed("/Athlete"); // Navigate to Athletes page
        break;
      case 2:
        Get.toNamed("/history"); // Navigate to History page
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  // Function to load saved data from Shared Preferences
  Future<void> _loadHistoryData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedData = prefs.getStringList('detectionHistory') ?? [];

    List<Map<String, dynamic>> loadedData = savedData
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();

    setState(() {
      historyRecords = loadedData;
    });
  }

  // Function to delete a record with confirmation
  Future<void> _deleteRecord(int index) async {
    bool confirmDelete = await _showDeleteConfirmationDialog();
    if (confirmDelete) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Remove the selected record
      setState(() {
        historyRecords.removeAt(index);
      });

      // Update SharedPreferences
      List<String> updatedData =
          historyRecords.map((record) => jsonEncode(record)).toList();
      await prefs.setStringList('detectionHistory', updatedData);
    }
  }

  // Function to show delete confirmation dialog
  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Deletion"),
              content:
                  const Text("Are you sure you want to delete this record?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child:
                      const Text("Delete", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          "History",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: historyRecords.isEmpty
            ? const Center(child: Text("No history available"))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  border: TableBorder.all(
                    color: Colors.grey, // ✅ Adds lines between columns
                    width: 1.0,
                  ),
                  headingRowColor: MaterialStateColor.resolveWith((states) =>
                      Colors.lightBlue.shade100), // ✅ Light blue heading row
                  columnSpacing: 20,
                  columns: const [
                    DataColumn(
                        label: Text("Athlete Name",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text("Detected Time",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text("Image",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text("Actions",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: List.generate(historyRecords.length, (index) {
                    final record = historyRecords[index];
                    return DataRow(
                      cells: [
                        DataCell(Text(record['athleteName'] ?? 'Unknown')),
                        DataCell(Text(record['time'] ?? 'N/A')),
                        DataCell(
                          record['imagePath'] != null &&
                                  File(record['imagePath']).existsSync()
                              ? Image.file(
                                  File(record['imagePath']),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image_not_supported),
                        ),
                        // ✅ Delete icon with confirmation dialog
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete, color: AppColors.primaryColor),
                            onPressed: () => _deleteRecord(index),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.primaryColor,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.white, // Set selected icon and label to white
        unselectedItemColor:
            const Color(0xFF676767), // Dull color for unselected items
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold, // Bold text for selected label
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal, // Normal text for unselected labels
        ),
        onTap: _navigateToPage,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            label: 'Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Athletes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
