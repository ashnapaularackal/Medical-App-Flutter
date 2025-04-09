import 'package:flutter/material.dart';
import '../services/api_service.dart'; // API service for network requests
import '../models/patient.dart'; // Patient data model
import '../utils/dialog_utils.dart'; // Utility functions for showing dialogs

/// UpdatePatientScreen allows medical staff to modify existing patient information
///
/// This screen presents a form with the patient's current data pre-populated
/// and enables users to edit and submit updated information to the database.
/// It includes form validation and error handling to ensure data integrity.
class UpdatePatientScreen extends StatefulWidget {
  final Patient patient; // The patient whose details will be updated

  const UpdatePatientScreen({Key? key, required this.patient})
      : super(key: key);

  @override
  _UpdatePatientScreenState createState() => _UpdatePatientScreenState();
}

class _UpdatePatientScreenState extends State<UpdatePatientScreen> {
  final _formKey = GlobalKey<FormState>(); // Used for form validation

  // Text controllers to manage form input fields
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;

  // State variables
  String _gender = 'male'; // Default gender selection
  bool _isLoading = false; // Tracks when API requests are in progress
  bool _hasChanges = false; // Tracks if any form values have changed

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing patient data
    _nameController = TextEditingController(text: widget.patient.name);
    _ageController =
        TextEditingController(text: widget.patient.age?.toString() ?? '');
    _addressController =
        TextEditingController(text: widget.patient.address ?? '');
    _phoneController =
        TextEditingController(text: widget.patient.phoneNumber ?? '');
    _gender = widget.patient.gender ?? 'male';

    // Add listeners to detect when form values change
    _nameController.addListener(_onFormChanged);
    _ageController.addListener(_onFormChanged);
    _addressController.addListener(_onFormChanged);
    _phoneController.addListener(_onFormChanged);
  }

  /// Updates the _hasChanges flag when form values are modified
  void _onFormChanged() {
    final hasNameChanged = _nameController.text != widget.patient.name;
    final hasAgeChanged = _ageController.text != widget.patient.age?.toString();
    final hasAddressChanged = _addressController.text != widget.patient.address;
    final hasPhoneChanged = _phoneController.text != widget.patient.phoneNumber;
    final hasGenderChanged = _gender != widget.patient.gender;

    final formChanged = hasNameChanged ||
        hasAgeChanged ||
        hasAddressChanged ||
        hasPhoneChanged ||
        hasGenderChanged;

    if (formChanged != _hasChanges) {
      setState(() {
        _hasChanges = formChanged;
      });
    }
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _nameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Shows a confirmation dialog when the user attempts to leave with unsaved changes
  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    // Show confirmation dialog if there are unsaved changes
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
            'You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('STAY'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DISCARD'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Validates and processes the form data to update the patient record
  ///
  /// This method performs the following steps:
  /// 1. Validates all form inputs
  /// 2. Shows a loading indicator
  /// 3. Attempts to update the patient data via API
  /// 4. Displays success/error messages
  /// 5. Returns to previous screen on success
  Future<void> _updatePatient() async {
    // Validate form before proceeding
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading state
      });

      try {
        // Construct updated patient data from form inputs
        final updatedData = {
          'name': _nameController.text.trim(),
          'age': int.parse(_ageController.text),
          'gender': _gender,
          'address': _addressController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
        };

        // Send update request to the API
        await ApiService.updatePatient(widget.patient.id!, updatedData);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Patient information updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return with success result
        }
      } catch (e) {
        // Handle errors and show appropriate message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Update failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        // Hide loading indicator if the widget is still mounted
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Update Patient Information'),
          actions: [
            // Help icon that could show information about this screen
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                // Show help dialog or tooltip
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Help'),
                    content: const Text(
                        'Update the patient information by modifying the form fields. '
                        'Fields marked with * are required.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Patient ID display (non-editable)
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: Colors.blue),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Patient ID',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  widget.patient.id ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Patient name field with validation
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                      helperText: 'Enter patient\'s full legal name',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Age input with validation
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age *',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                      helperText: 'Enter patient\'s current age',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Age is required';
                      }

                      final age = int.tryParse(value);
                      if (age == null) {
                        return 'Please enter a valid number';
                      }

                      if (age < 0 || age > 120) {
                        return 'Please enter a valid age (0-120)';
                      }

                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Gender selection with improved UI
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Gender *',
                      prefixIcon: Icon(Icons.people_outline),
                      border: OutlineInputBorder(),
                      helperText: 'Select patient\'s gender identity',
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _gender,
                        isExpanded: true,
                        items: ['male', 'female', 'other'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value.substring(0, 1).toUpperCase() +
                                  value.substring(1),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _gender = value;
                              _onFormChanged();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Address input field
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.home_outlined),
                      border: OutlineInputBorder(),
                      helperText:
                          'Enter patient\'s current residential address',
                    ),
                    maxLines: 2,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Phone number input with formatting
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                      helperText: 'Enter patient\'s contact number',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        // Simple pattern check for phone number format
                        if (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Action buttons row
                  Row(
                    children: [
                      // Cancel button
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('CANCEL'),
                          onPressed: () => _onWillPop().then(
                            (canPop) {
                              if (canPop) Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Update button with loading state
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(_isLoading ? 'SAVING' : 'UPDATE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: (_isLoading || !_hasChanges)
                              ? null
                              : _updatePatient,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
