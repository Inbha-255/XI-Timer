import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/colors.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Historypage extends StatefulWidget {
  const Historypage({super.key});

  @override
  State<Historypage> createState() => _HistorypageState();
}

class _HistorypageState extends State<Historypage> {
  int _currentIndex = 0; // To track the selected tab

  void _showMoreOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              top: 5, // Position below the AppBar
              right: 5, // Position close to the right edge
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 230, // Adjust the width as needed
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.settings),
                        title: Text('Settings'),
                        onTap: () {
                          Navigator.of(context).pop();
                          Get.toNamed("/settings");
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.play_circle_outlined),
                        title: Text('Tutorial Videos'),
                        onTap: () {
                          Navigator.of(context).pop();
                          Get.toNamed("/about");
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.school_outlined),
                        title: Text('FAQ'),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.info),
                        title: Text('About'),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.share),
                        title: Text('Share this App'),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          "XI-Timer",
          style: GoogleFonts.roboto(color: AppColors.backgroundColor),
        ),
        actions: [
          IconButton(
              onPressed: _showMoreOptionsDialog,
              icon: Icon(
                Icons.more_vert,
                color: AppColors.backgroundColor,
              ))
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            AppColors.primaryColor, // Background color for the navigation bar
        currentIndex: _currentIndex, // Highlight the selected tab
        selectedItemColor:
            AppColors.backgroundColor, // Color for the selected icon
        unselectedItemColor: const Color.fromARGB(
            255, 103, 103, 103), // Color for unselected icons
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the selected tab
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: () {
                  Get.toNamed("/home");
                },
                icon: const Icon(Icons.timer_outlined)),
            label: 'Timer',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: () {
                  Get.toNamed("/athletes");
                },
                icon: const Icon(Icons.groups)),
            label: 'Athletes',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: () {
                  Get.toNamed("/history");
                },
                icon: const Icon(Icons.leaderboard)),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
