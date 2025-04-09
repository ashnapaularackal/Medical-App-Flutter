/// Add Patient Screen
///
/// Created by: Ashna Paul - 301479554
/// Date: February 25, 2025
///
/// This screen allows users to add a new patient to the system.
/// It includes form fields for patient details and performs validation
/// before submitting the data to the API.
///
/// Features:
/// - Form validation for all required fields
/// - Real-time input validation
/// - Loading state management
/// - Success/error feedback via SnackBar
/// - Responsive design with gradient background

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/patient.dart';

class AddPatientScreen extends StatefulWidget {
  /// Creates an Add Patient Screen widget
  const AddPatientScreen({Key? key}) : super(key: key);

  @override
  AddPatientScreenState createState() => AddPatientScreenState();
}

class AddPatientScreenState extends State<AddPatientScreen> {
  /// Global form key for validation control
  final _formKey = GlobalKey<FormState>();

  /// Text controllers for all form fields
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  /// Selected gender value (default: 'male')
  String _gender = 'male';

  /// Flag for critical condition checkbox
  bool _isCritical = false;

  /// Loading state to control UI during API operations
  bool _isLoading = false;

  /// List of available gender options
  final List<String> _genderOptions = ['male', 'female', 'other'];

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _nameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Add New Patient',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        // Enhanced gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[300]!,
              Colors.blue[200]!,
              Colors.purple[200]!,
              Colors.purple[300]!,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Form heading
                      _buildFormHeader(),
                      const SizedBox(height: 24),

                      // Patient basic information section
                      _buildSectionHeader('Basic Information'),
                      const SizedBox(height: 16),

                      // Name field
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Age field
                      _buildTextField(
                        controller: _ageController,
                        label: 'Age',
                        prefixIcon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an age';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          final age = int.parse(value);
                          if (age < 0 || age > 120) {
                            return 'Please enter a valid age (0-120)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Gender dropdown
                      _buildDropdownField(),
                      const SizedBox(height: 24),

                      // Contact information section
                      _buildSectionHeader('Contact Information'),
                      const SizedBox(height: 16),

                      // Address field
                      _buildTextField(
                        controller: _addressController,
                        label: 'Address',
                        prefixIcon: Icons.home,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone number field
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          // Validate phone number format (10 digits)
                          if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                            return 'Please enter a valid 10-digit phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Medical information section
                      _buildSectionHeader('Medical Information'),
                      const SizedBox(height: 16),

                      // Medical history field
                      _buildTextField(
                        controller: _medicalHistoryController,
                        label: 'Medical History',
                        prefixIcon: Icons.medical_services,
                        maxLines: 3,
                        helperText:
                            'Enter any relevant medical history, allergies, or conditions',
                      ),
                      const SizedBox(height: 16),

                      // Critical condition checkbox
                      _buildCriticalCheckbox(),
                      const SizedBox(height: 32),

                      // Submit button
                      _buildSubmitButton(),
                      const SizedBox(height: 16),

                      // Cancel button
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: Colors.grey[700],
                        ),
                        child: const Text('CANCEL'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the form header with icon and title
  Widget _buildFormHeader() {
    return Column(
      children: [
        Icon(
          Icons.person_add,
          size: 48,
          color: Colors.purple[700],
        ),
        const SizedBox(height: 8),
        const Text(
          'Patient Registration',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter patient details below',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// Builds section headers for better form organization
  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.purple[700],
          ),
        ),
        const SizedBox(height: 4),
        Divider(color: Colors.grey[300]),
      ],
    );
  }

  /// Helper method to build consistent text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLines = 1,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple[700]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        helperText: helperText,
        helperMaxLines: 2,
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      textInputAction:
          maxLines == 1 ? TextInputAction.next : TextInputAction.done,
    );
  }

  /// Helper method to build the gender dropdown
  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: InputDecoration(
        labelText: 'Gender',
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.people),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple[700]!, width: 2),
        ),
      ),
      items: _genderOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value.substring(0, 1).toUpperCase() + value.substring(1)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _gender = value;
          });
        }
      },
    );
  }

  /// Builds the critical condition checkbox
  Widget _buildCriticalCheckbox() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _isCritical ? Colors.red : Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: _isCritical ? Colors.red.withOpacity(0.1) : Colors.white,
      ),
      child: CheckboxListTile(
        title: const Text('Critical Condition'),
        subtitle: const Text('Mark if patient requires immediate attention'),
        value: _isCritical,
        onChanged: (value) {
          setState(() {
            _isCritical = value ?? false;
          });
        },
        activeColor: Colors.red,
        checkColor: Colors.white,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  /// Builds the submit button with loading state
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        disabledBackgroundColor: Colors.grey[400],
      ),
      child: _isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
          : const Text('ADD PATIENT'),
    );
  }

  /// Method to handle form submission
  /// Validates input, calls API service, and handles success/error states
  Future<void> _submitForm() async {
    // Validate form before submission
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Prepare patient data from form inputs
        final patientData = {
          'name': _nameController.text.trim(),
          'age': int.parse(_ageController.text),
          'gender': _gender,
          'address': _addressController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'medicalHistory': _medicalHistoryController.text.trim().isNotEmpty
              ? [_medicalHistoryController.text.trim()]
              : [],
          'criticalCondition': _isCritical,
        };

        // Call API service to add the patient
        await ApiService.addPatient(patientData);

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient added successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(8.0),
          ),
        );

        // Return to previous screen with success indicator
        Navigator.pop(context, true);
      } catch (e) {
        // Log the error for debugging
        print('Error adding patient: $e');

        if (!mounted) return;

        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add patient: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8.0),
          ),
        );

        // Reset loading state
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
