/// Add Test Screen
///
/// Created by: Ashna Paul - 301479554
/// Date: February 25, 2025
///
/// This screen allows adding a new medical test for a patient.
/// It provides a form to select the test type and enter the test value.

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddTestScreen extends StatefulWidget {
  final String patientId;

  const AddTestScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  _AddTestScreenState createState() => _AddTestScreenState();
}

class _AddTestScreenState extends State<AddTestScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedTestType = 'Blood Pressure';
  final TextEditingController _valueController = TextEditingController();
  bool _isLoading = false;

  // List of available test types
  final List<String> _testTypes = [
    'Blood Pressure',
    'Respiratory Rate',
    'Blood Oxygen Level',
    'Heartbeat Rate'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Add Test', style: TextStyle(color: Colors.white)),
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
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Test Type Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedTestType,
                            decoration: InputDecoration(
                              labelText: 'Test Type',
                              border: OutlineInputBorder(),
                            ),
                            items: _testTypes.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedTestType = newValue!;
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          // Test Value Input
                          TextFormField(
                            controller: _valueController,
                            decoration: InputDecoration(
                              labelText: 'Test Value',
                              border: OutlineInputBorder(),
                            ),
                            validator: _validateTestValue,
                            keyboardType: TextInputType.text,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Submit Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitTest,
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: const Color.fromARGB(255, 22, 21, 21))
                        : Text('Add Test'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 160, 128, 173),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Validate the test value based on the selected test type
  String? _validateTestValue(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a test value';
    }
    switch (_selectedTestType) {
      case 'Blood Pressure':
        if (!RegExp(r'^\d{2,3}/\d{2,3}$').hasMatch(value)) {
          return 'Enter a valid blood pressure (e.g., 120/80)';
        }
        break;
      case 'Respiratory Rate':
        if (!RegExp(r'^\d{1,2}$').hasMatch(value)) {
          return 'Enter a valid respiratory rate (e.g., 16)';
        }
        break;
      case 'Blood Oxygen Level':
        if (!RegExp(r'^\d{2,3}$').hasMatch(value)) {
          return 'Enter a valid blood oxygen level (e.g., 98)';
        }
        break;
      case 'Heartbeat Rate':
        if (!RegExp(r'^\d{2,3}$').hasMatch(value)) {
          return 'Enter a valid heartbeat rate (e.g., 72)';
        }
        break;
    }
    return null;
  }

  // Submit the test to the API
  void _submitTest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await ApiService.addTestForPatient(
          widget.patientId,
          {
            'type': _selectedTestType,
            'value': _valueController.text,
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Test added successfully')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding test: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }
}
