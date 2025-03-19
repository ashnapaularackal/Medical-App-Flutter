/// Critical Patients Screen
///
/// Created by: Ashna Paul - 301479554
/// Date: February 25, 2025
///
/// This screen displays a list of patients in critical condition.
/// It provides a quick overview for medical staff to prioritize care.

import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/api_service.dart';
import '../widgets/patient_card.dart';

class CriticalPatientsScreen extends StatefulWidget {
  @override
  _CriticalPatientsScreenState createState() => _CriticalPatientsScreenState();
}

class _CriticalPatientsScreenState extends State<CriticalPatientsScreen> {
  List<Patient> criticalPatients = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCriticalPatients();
  }

  // Load critical patients from the API
  Future<void> _loadCriticalPatients() async {
    try {
      final loadedPatients = await ApiService.getCriticalPatients();
      setState(() {
        criticalPatients = loadedPatients;
        _loading = false;
      });
    } catch (e) {
      print('Error loading critical patients: $e');
      setState(() {
        _loading = false;
      });
      _showErrorSnackBar('Failed to load critical patients. Please try again.');
    }
  }

  // Show error message to the user
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
        title: Text('Critical Patients', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.red[100]!, Colors.orange[100]!],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? Center(child: CircularProgressIndicator())
              : criticalPatients.isEmpty
                  ? Center(
                      child: Text(
                        'No critical patients found.',
                        style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadCriticalPatients,
                      child: ListView.builder(
                        itemCount: criticalPatients.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: _buildCriticalPatientCard(
                                criticalPatients[index]),
                          );
                        },
                      ),
                    ),
        ),
      ),
    );
  }

  // Build a custom card for critical patients
  Widget _buildCriticalPatientCard(Patient patient) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.warning, color: Colors.white),
        ),
        title: Text(
          patient.name ?? 'N/A',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Age: ${patient.age}, Gender: ${patient.gender}'),
            SizedBox(height: 4),
            Text(
              'Critical Condition',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () => _navigateToPatientDetails(patient),
      ),
    );
  }

  // Navigate to patient details screen
  void _navigateToPatientDetails(Patient patient) {
    Navigator.pushNamed(context, '/patient_details', arguments: patient);
  }
}
