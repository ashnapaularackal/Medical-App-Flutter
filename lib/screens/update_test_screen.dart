import 'package:flutter/material.dart';
import '../models/test.dart';
import '../services/api_service.dart';

/// UpdateTestScreen allows editing of an existing medical test for a patient.
///
/// This screen provides form fields to modify test type and value while
/// preserving the original test date. It handles API communication,
/// form validation, and provides user feedback through loading indicators
/// and snackbar messages.
class UpdateTestScreen extends StatefulWidget {
  /// The test object to be updated
  final Test test;

  /// ID of the patient this test belongs to
  final String patientId;

  const UpdateTestScreen({
    Key? key,
    required this.test,
    required this.patientId,
  }) : super(key: key);

  @override
  UpdateTestScreenState createState() => UpdateTestScreenState();
}

class UpdateTestScreenState extends State<UpdateTestScreen> {
  /// Global key for accessing and validating the form
  final _formKey = GlobalKey<FormState>();

  /// Controller for the test type input field
  late TextEditingController _typeController;

  /// Controller for the test value input field
  late TextEditingController _valueController;

  /// Loading state to disable UI interactions during API operations
  bool _isLoading = false;

  /// Flag to track if any changes were made to the form
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the current test data
    _typeController = TextEditingController(text: widget.test.type);
    _valueController = TextEditingController(text: widget.test.value);

    // Add listeners to track changes in form fields
    _typeController.addListener(_onFormChanged);
    _valueController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _typeController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  /// Track changes in the form to enable/disable submit button
  void _onFormChanged() {
    final hasChanges = _typeController.text != widget.test.type ||
        _valueController.text != widget.test.value;

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  /// Shows a confirmation dialog when trying to leave with unsaved changes
  Future<bool> _onWillPop() async {
    if (!_hasChanges) {
      return true;
    }

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
            child: const Text('CANCEL'),
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

  /// Updates the test data via API and handles success/error states
  Future<void> _updateTest() async {
    // Validate form before submission
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Prepare updated test data
        final updatedData = {
          'type': _typeController.text.trim(),
          'value': _valueController.text.trim(),
          'date': widget.test.date.toIso8601String(),
        };

        // Send update request to API
        await ApiService.updateTest(
          patientId: widget.patientId,
          testId: widget.test.id!,
          testData: updatedData,
        );

        // Show success message
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Return to previous screen with success indicator
        Navigator.pop(context, true);
      } catch (e) {
        // Handle error case
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update test: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        // Reset loading state if operation fails and we stay on this screen
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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            'Update Test',
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
                        // Information about the current test
                        _buildTestHeader(),
                        const Divider(height: 32),

                        // Test type input field
                        TextFormField(
                          controller: _typeController,
                          decoration: InputDecoration(
                            labelText: 'Test Type',
                            hintText: 'E.g., Blood Sugar, Blood Pressure',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.science),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.purple[700]!, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Test type is required';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),

                        // Test value input field
                        TextFormField(
                          controller: _valueController,
                          decoration: InputDecoration(
                            labelText: 'Test Value',
                            hintText: 'E.g., 120mg/dL, 120/80 mmHg',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.assessment),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.purple[700]!, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Test value is required';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _updateTest(),
                        ),
                        const SizedBox(height: 32),

                        // Update button
                        ElevatedButton(
                          onPressed:
                              (_isLoading || !_hasChanges) ? null : _updateTest,
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
                              : const Text('UPDATE TEST'),
                        ),
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
      ),
    );
  }

  /// Builds the header section displaying test information
  Widget _buildTestHeader() {
    // Format the test date for display
    final dateStr = _formatDate(widget.test.date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Edit Test Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              'Test Date: $dateStr',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              'Test ID: ${_truncateId(widget.test.id)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Formats a DateTime object to a readable string
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Truncates a long ID for display purposes
  String _truncateId(String? id) {
    if (id == null || id.isEmpty) return 'N/A';
    if (id.length <= 8) return id;
    return '${id.substring(0, 4)}...${id.substring(id.length - 4)}';
  }
}
