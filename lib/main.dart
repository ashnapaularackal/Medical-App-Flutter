/// WellCare Hospital Management App
///
/// Created by: Ashna Paul - 301479554
/// Date: February 25, 2025
///
/// This is the main entry point of the WellCare Hospital Management application.
/// It sets up the app's theme, routes, and main screen with bottom navigation.

import 'package:flutter/material.dart';
import 'screens/patient_list_screen.dart';
import 'screens/add_patient_screen.dart';
import 'screens/critical_patients_screen.dart';
import 'screens/patient_detail_screen.dart';
import 'models/patient.dart';

void main() {
  runApp(MyApp());
}

/// The root widget of the application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WellCare Hospital Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
      routes: {
        '/add_patient': (context) => AddPatientScreen(),
        '/patient_details': (context) => PatientDetailScreen(
              patient: ModalRoute.of(context)!.settings.arguments as Patient,
            ),
      },
    );
  }
}

/// The main screen widget with bottom navigation
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
// Index of the currently selected tab
  int _currentIndex = 0;

// List of screens corresponding to each tab
  final List<Widget> _children = [
    PatientListScreen(),
    AddPatientScreen(),
    CriticalPatientsScreen(),
  ];

// Function to handle tab selection
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
// Display the currently selected screen
      body: _children[_currentIndex],
// Bottom navigation bar setup
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Add Patient',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Critical',
          ),
        ],
      ),
    );
  }
}
