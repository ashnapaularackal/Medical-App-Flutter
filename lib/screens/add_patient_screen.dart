/// Add Patient Screen
///
/// Created by: Ashna Paul - 301479554
/// Date: February 25, 2025
///
/// This screen allows users to add a new patient to the system.
/// It includes form fields for patient details and performs validation
/// before submitting the data to the API.

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddPatientScreen extends StatefulWidget {
  @override
  _AddPatientScreenState createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  // Default gender selection
  String _gender = 'male';

  // Loading state
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Add New Patient', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        // Gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[300]!, Colors.purple[300]!],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Name field
                  _buildTextField(
                    controller: _nameController,
                    label: 'Name',
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a name' : null,
                  ),
                  SizedBox(height: 16),
                  // Age field
                  _buildTextField(
                    controller: _ageController,
                    label: 'Age',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter an age';
                      if (int.tryParse(value) == null)
                        return 'Please enter a valid number';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Gender dropdown
                  _buildDropdownField(),
                  SizedBox(height: 16),
                  // Address field
                  _buildTextField(
                    controller: _addressController,
                    label: 'Address',
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter an address' : null,
                  ),
                  SizedBox(height: 16),
                  // Phone number field
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter a phone number';
                      if (!RegExp(r'^\d{10}$').hasMatch(value))
                        return 'Please enter a valid 10-digit phone number';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Medical history field
                  _buildTextField(
                    controller: _medicalHistoryController,
                    label: 'Medical History',
                    maxLines: 3,
                  ),
                  SizedBox(height: 24),
                  // Submit button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: const Color.fromARGB(255, 251, 250, 250))
                        : Text('Add Patient'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 81, 22, 104),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
    );
  }

  // Helper method to build the gender dropdown
  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: InputDecoration(
        labelText: 'Gender',
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: ['male', 'female', 'other'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _gender = value!;
        });
      },
    );
  }

  // Method to handle form submission
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Inside _submitForm() in AddPatientScreen
      try {
        final patientData = {
          'name': _nameController.text,
          'age': int.parse(_ageController.text),
          'gender': _gender,
          'address': _addressController.text,
          'phoneNumber': _phoneController.text,
          'medicalHistory': [_medicalHistoryController.text],
        };

        final newPatient = await ApiService.addPatient(patientData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Patient added successfully')),
        );
        // Return true instead of the patient object
        Navigator.pop(context, true);
      } catch (e) {
        // Rest of your code remains the same
        print('Error adding patient: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add patient. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
