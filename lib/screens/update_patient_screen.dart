import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Importing API service for making network calls
import '../models/patient.dart'; // Importing the Patient model
import '../utils/dialog_utils.dart'; // Importing utility functions for dialogs (if needed)

/// Screen for updating patient details.
/// This screen allows users to edit and update patient information.
class UpdatePatientScreen extends StatefulWidget {
  final Patient patient; // The patient object to be updated.

  const UpdatePatientScreen({Key? key, required this.patient})
      : super(key: key);

  @override
  _UpdatePatientScreenState createState() => _UpdatePatientScreenState();
}

class _UpdatePatientScreenState extends State<UpdatePatientScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  late TextEditingController _nameController; // Controller for name input field
  late TextEditingController _ageController; // Controller for age input field
  late TextEditingController
      _addressController; // Controller for address input field
  late TextEditingController
      _phoneController; // Controller for phone number input field
  String _gender = 'male'; // Default gender value
  bool _isLoading = false; // Loading state to show progress indicator

  @override
  void initState() {
    super.initState();
    // Initialize text controllers with the existing patient data.
    _nameController = TextEditingController(text: widget.patient.name);
    _ageController =
        TextEditingController(text: widget.patient.age?.toString());
    _addressController = TextEditingController(text: widget.patient.address);
    _phoneController = TextEditingController(text: widget.patient.phoneNumber);
    _gender = widget.patient.gender ?? 'male'; // Set default gender if null
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources when the screen is closed.
    _nameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Function to handle patient update logic.
  /// Validates form inputs and sends a request to update the patient data.
  Future<void> _updatePatient() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator while processing
      });

      try {
        // Prepare updated data from form inputs
        final updatedData = {
          'name': _nameController.text,
          'age': int.parse(_ageController.text),
          'gender': _gender,
          'address': _addressController.text,
          'phoneNumber': _phoneController.text,
        };

        // Call API service to update the patient data
        await ApiService.updatePatient(widget.patient.id!, updatedData);

        // Show success message and navigate back with a success result
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient updated successfully')),
        );
        Navigator.pop(context, true); // Pass true to indicate success
      } catch (e) {
        // Handle errors and show failure message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update patient: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator after processing
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Patient')), // App bar title
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the form
        child: Form(
          key: _formKey, // Attach form key for validation
          child: ListView(
            children: [
              // Name input field with validation
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16), // Spacing between fields

              // Age input field with validation for numeric values
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty || int.tryParse(value) == null
                        ? 'Valid age is required'
                        : null,
              ),
              const SizedBox(height: 16),

              // Gender dropdown field with predefined options
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: ['male', 'female', 'other'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _gender = value!),
              ),
              const SizedBox(height: 16),

              // Address input field without validation (optional)
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 16),

              // Phone number input field without validation (optional)
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // Submit button with loading indicator during processing
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _updatePatient, // Disable button if loading
                child: _isLoading
                    ? const CircularProgressIndicator() // Show progress indicator if loading
                    : const Text(
                        'Update Patient'), // Button text when not loading
              ),
            ],
          ),
        ),
      ),
    );
  }
}
