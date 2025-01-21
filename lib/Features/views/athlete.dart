import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Data/Modals/add_athlete_json.dart';

class Athlete extends Root {
  Athlete({required String name, required int number})
      : super(name: name, number: number);

  static Athlete fromJson(Map<String, dynamic> json) {
    return Athlete(name: json['name'], number: json['number']);
  }

  @override
  // ignore: unnecessary_overrides
  Map<String, dynamic> toJson() {
    return super.toJson();
  }
}

class SelectAthletePage extends StatefulWidget {
  const SelectAthletePage({super.key});

  @override
  State<SelectAthletePage> createState() => _SelectAthletePageState();
}

class _SelectAthletePageState extends State<SelectAthletePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode(); // Manage TextField focus
  int? _selectedNumber;
  late List<int> _numbers;
  final List<Athlete> _athletes = [];

  @override
  void initState() {
    super.initState();
    _loadAthletesFromPreferences();
    _generateNumbers();
  }

  void _generateNumbers() {
    _numbers = List.generate(999, (index) => index + 1);
    _updateAvailableNumbers();
  }

  void _updateAvailableNumbers() {
    final usedNumbers = _athletes.map((e) => e.number).toList();
    _numbers.removeWhere((number) => usedNumbers.contains(number));
  }

  void _addOrUpdateAthlete(Athlete athlete, {int? index}) {
    setState(() {
      if (index == null) {
        _athletes.add(athlete);
      } else {
        _athletes[index] = athlete;
      }
      _updateAvailableNumbers();
      _saveAthletesToPreferences();
    });
  }

  void _deleteAthlete(int index) {
    setState(() {
      _athletes.removeAt(index);
      _updateAvailableNumbers();
      _saveAthletesToPreferences();
    });
  }

  Future<void> _saveAthletesToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _athletes.map((athlete) => athlete.toJson()).toList();
    prefs.setString('athletes', json.encode(jsonList));
  }

  Future<void> _loadAthletesFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('athletes');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        _athletes.clear();
        _athletes
            .addAll(jsonList.map((json) => Athlete.fromJson(json)).toList());
        _updateAvailableNumbers();
      });
    }
  }

  Future<void> _showCreateAthleteDialog({int? index, Athlete? athlete}) async {
    if (_numbers.isEmpty && athlete == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No numbers available!')),
      );
      return;
    }

    if (athlete != null) {
      _nameController.text = athlete.name!;
      _selectedNumber = athlete.number;
      _numbers.add(athlete.number!);
      _numbers.sort();
    } else {
      _nameController.clear();
      _selectedNumber = _numbers.first;
    }

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(athlete == null ? 'Create New Athlete' : 'Edit Athlete'),
          content: SingleChildScrollView(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("Name"),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 10),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Name is required'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Number:'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 120,
                            child: CupertinoPicker(
                              itemExtent: 40.0,
                              scrollController: FixedExtentScrollController(
                                initialItem: athlete != null
                                    ? _numbers.indexOf(athlete.number!)
                                    : 0,
                              ),
                              onSelectedItemChanged: (int index) {
                                setState(() {
                                  _selectedNumber = _numbers[index];
                                });
                              },
                              children: _numbers
                                  .map((number) =>
                                      Center(child: Text(number.toString())))
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate() &&
                    _selectedNumber != null) {
                  final newAthlete = Athlete(
                    name: _nameController.text,
                    number: _selectedNumber!,
                  );
                  _addOrUpdateAthlete(newAthlete, index: index);
                  Navigator.of(dialogContext).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
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
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'XI Timer',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => _showCreateAthleteDialog(),
            icon: const Icon(Icons.person_add, color: Colors.white),
          ),
        ],
      ),
      body: _athletes.isEmpty
          ? const Center(child: Text('No athletes yet. Add one!'))
          : ListView.builder(
              itemCount: _athletes.length,
              itemBuilder: (context, index) {
                final athlete = _athletes[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(5),
                    tileColor: Colors.white,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${athlete.number}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      athlete.name!,
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: AppColors.primaryColor),
                          onPressed: () => _showCreateAthleteDialog(
                            index: index,
                            athlete: athlete,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: AppColors.primaryColor),
                          onPressed: () => _deleteAthlete(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
