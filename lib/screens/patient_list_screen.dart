/// Patient List Screen
///
/// Created by: Ashna Paul - 301479554
/// Date: February 25, 2025
///
/// This screen displays a list of all patients in the system.
/// It allows viewing patient details and adding new patients.

import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../widgets/patient_card.dart';
import '../services/api_service.dart';
import 'patient_detail_screen.dart';

class PatientListScreen extends StatefulWidget {
  @override
  _PatientListScreenState createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  // List to store all patients
  List<Patient> patients = [];
  // Loading state flag
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  /// Loads all patients from the API
  Future<void> _loadPatients() async {
    try {
      final loadedPatients = await ApiService.getAllPatients();
      setState(() {
        patients = loadedPatients;
        _loading = false;
      });
    } catch (e) {
      print('Error loading patients: $e');
      setState(() {
        _loading = false;
      });
      _showErrorSnackBar('Failed to load patients. Please try again.');
    }
  }

  /// Displays an error message to the user
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Patient List', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        // Gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[100]!, Colors.purple[100]!],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? Center(child: CircularProgressIndicator())
              : patients.isEmpty
                  ? Center(
                      child: Text('No patients found.',
                          style: TextStyle(fontSize: 18)))
                  : RefreshIndicator(
                      onRefresh: _loadPatients,
                      child: ListView.builder(
                        itemCount: patients.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: PatientCard(
                              patient: patients[index],
                              onTap: () =>
                                  _navigateToPatientDetails(patients[index]),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPatient,
        child: Icon(Icons.add),
        backgroundColor: Colors.purple[700],
        tooltip: 'Add New Patient',
      ),
    );
  }

  /// Navigates to the Patient Detail Screen
  void _navigateToPatientDetails(Patient patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(patient: patient),
      ),
    );
  }

  /// Navigates to the Add Patient Screen
  void _navigateToAddPatient() async {
    final result = await Navigator.pushNamed(context, '/add_patient');
    if (result == true) {
      _loadPatients();
    }
  }
}
