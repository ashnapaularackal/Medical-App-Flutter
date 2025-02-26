/// Patient Detail Screen
///
/// Created by: Ashna Paul - 301479554
/// Date: February 25, 2025
///
/// This screen displays detailed information about a patient,
/// including their personal details and medical tests.
/// It allows adding new tests and highlights critical patients.

import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/test.dart';
import '../services/api_service.dart';
import '../widgets/test_card.dart';
import 'add_test_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailScreen({Key? key, required this.patient})
      : super(key: key);

  @override
  _PatientDetailScreenState createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  List<Test> tests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  // Load tests for the patient
  Future<void> _loadTests() async {
    try {
      final loadedTests =
          await ApiService.getTestsForPatient(widget.patient.id);
      setState(() {
        tests = loadedTests;
        _loading = false;
      });
    } catch (e) {
      print('Error loading tests: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.patient.name, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[100]!, Colors.purple[100]!],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Details Card
                _buildPatientDetailsCard(),
                SizedBox(height: 20),
                // Medical Tests Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Medical Tests',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.purple[700],
                            fontWeight: FontWeight.bold,
                          )),
                ),
                SizedBox(height: 10),
                // Tests List
                _loading
                    ? Center(child: CircularProgressIndicator())
                    : tests.isEmpty
                        ? Center(child: Text('No tests found.'))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: tests.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: TestCard(test: tests[index]),
                              );
                            },
                          ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTestScreen(patientId: widget.patient.id),
            ),
          );
          if (result == true) {
            _loadTests();
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Add Test',
        backgroundColor: Colors.purple[700],
      ),
    );
  }

  // Build the patient details card
  Widget _buildPatientDetailsCard() {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Details',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700]),
            ),
            SizedBox(height: 10),
            _buildDetailRow('Age', widget.patient.age.toString()),
            _buildDetailRow('Gender', widget.patient.gender),
            _buildDetailRow('Address', widget.patient.address ?? 'N/A'),
            _buildDetailRow('Phone', widget.patient.phoneNumber ?? 'N/A'),
            SizedBox(height: 10),
            // Highlight for critical patients
            if (widget.patient.criticalCondition)
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Critical Condition',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper method to build detail rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
