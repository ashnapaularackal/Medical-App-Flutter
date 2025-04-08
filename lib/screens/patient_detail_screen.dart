import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/test.dart';
import '../services/api_service.dart';
import '../widgets/test_card.dart';
import 'add_test_screen.dart';
import 'update_patient_screen.dart';
import 'update_test_screen.dart';
import '../utils/dialog_utils.dart';

/// A screen that displays detailed information about a specific patient
/// including their personal information and medical tests.
///
/// This screen allows healthcare providers to view, add, update, and delete
/// medical tests for a patient as well as update or delete the patient record.
class PatientDetailScreen extends StatefulWidget {
  /// The patient whose details are being displayed
  final Patient patient;

  const PatientDetailScreen({Key? key, required this.patient})
      : super(key: key);

  @override
  _PatientDetailScreenState createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  // Store the current patient data which might be updated during the session
  late Patient currentPatient;

  // List to store medical tests for the patient
  List<Test> tests = [];

  // Loading state flags to manage UI feedback
  bool _loading = true;
  bool _refreshingPatient = false;

  @override
  void initState() {
    super.initState();
    // Initialize with the patient data passed from the previous screen
    currentPatient = widget.patient;
    // Load tests and refresh patient data when screen is first created
    _loadTests();
    _refreshPatientData();
  }

  /// Fetches all medical tests associated with the current patient from the API
  ///
  /// Updates the UI to show a loading indicator while fetching and handles errors
  Future<void> _loadTests() async {
    try {
      // Fetch tests for this patient from the API service
      final loadedTests =
          await ApiService.getTestsForPatient(currentPatient.id!);

      // Update state with the fetched tests and stop loading indicator
      setState(() {
        tests = loadedTests;
        _loading = false;
      });
    } catch (e) {
      // Log and handle any errors that occur during test loading
      print('Error loading tests: $e');
      setState(() {
        _loading = false;
      });
      _showErrorSnackBar('Failed to load tests. Please try again.');
    }
  }

  /// Refreshes the patient data to ensure the most current information is displayed
  ///
  /// This is important since the patient's condition might change based on test results
  Future<void> _refreshPatientData() async {
    // Validate patient ID before attempting to refresh
    if (currentPatient.id == null || currentPatient.id!.isEmpty) {
      print('Cannot refresh patient data: Invalid patient ID');
      return;
    }

    // Set flag to show refresh is in progress
    setState(() {
      _refreshingPatient = true;
    });

    try {
      // Fetch the latest patient data from the API
      final refreshedPatient =
          await ApiService.getPatientById(currentPatient.id!);

      // Update the UI with fresh patient data
      setState(() {
        currentPatient = refreshedPatient;
        _refreshingPatient = false;
      });
    } catch (e) {
      // Handle and log errors during patient data refresh
      print('Error refreshing patient data: $e');
      setState(() {
        _refreshingPatient = false;
      });
      _showErrorSnackBar('Failed to refresh patient data.');
    }
  }

  /// Displays an error message to the user via a SnackBar
  ///
  /// @param message The error message to display
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Navigates to the test update screen and refreshes data if test was updated
  ///
  /// @param test The test to be updated
  Future<void> _handleTestUpdate(Test test) async {
    // Navigate to the test update screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateTestScreen(
          test: test,
          patientId: currentPatient.id!,
        ),
      ),
    );

    // If test was successfully updated (result == true)
    if (result == true) {
      // Refresh both tests and patient data
      await _loadTests();
      await _refreshPatientData(); // Also refresh patient data in case critical condition changed
    }
  }

  /// Handles test deletion after confirmation from the user
  ///
  /// @param test The test to be deleted
  Future<void> _handleTestDelete(Test test) async {
    // Show confirmation dialog before deleting
    final confirm = await showDeleteConfirmationDialog(context);
    if (!confirm) return; // Cancel if user didn't confirm

    try {
      // Delete the test through the API service
      await ApiService.deleteTest(
          patientId: currentPatient.id!, testId: test.id!);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test deleted successfully')),
      );

      // Refresh both tests and patient data
      await _loadTests();
      await _refreshPatientData();
    } catch (e) {
      // Handle and display any errors during deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete test: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Handles patient deletion after confirmation
  ///
  /// This will delete the entire patient record including all their tests
  Future<void> _handlePatientDelete() async {
    // Show confirmation dialog before proceeding
    final confirm = await showDeleteConfirmationDialog(context);
    if (!confirm) return; // Cancel if user didn't confirm

    try {
      // Delete the patient record through the API service
      await ApiService.deletePatient(currentPatient.id!);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Return to the previous screen with a refresh signal
      Navigator.pop(context, true); // Return refresh signal to patient list
    } catch (e) {
      // Handle and display any errors during patient deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Make content go behind app bar for a more seamless gradient effect
      extendBodyBehindAppBar: true,

      // Transparent app bar that overlays the gradient background
      appBar: AppBar(
        title: Text(currentPatient.name ?? 'Patient Details',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Refresh button to manually update patient and test data
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshingPatient
                ? null // Disable button while refreshing
                : () {
                    _refreshPatientData();
                    _loadTests();
                  },
            tooltip: 'Refresh',
          ),
          // Edit button to navigate to patient update screen
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UpdatePatientScreen(patient: currentPatient),
                ),
              );
              if (result == true) {
                // Refresh data after successful update
                await _refreshPatientData();
              }
            },
            tooltip: 'Edit',
          ),
          // Delete button for removing the patient record
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _handlePatientDelete,
            tooltip: 'Delete Patient',
          ),
        ],
      ),
      // Main body with gradient background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[100]!, Colors.purple[100]!],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            // Pull-to-refresh functionality for the entire screen
            onRefresh: () async {
              await _refreshPatientData();
              await _loadTests();
            },
            child: SingleChildScrollView(
              // Always allow scrolling even if content doesn't fill screen
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show loading indicator when refreshing patient data
                  if (_refreshingPatient)
                    const Center(child: CircularProgressIndicator()),

                  // Card containing all patient details
                  _buildPatientDetailsCard(),
                  const SizedBox(height: 20),

                  // Medical Tests section header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Medical Tests',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.purple[700],
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),

                  // Tests list with loading, empty state, and list views
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : tests.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('No tests found.'),
                              ),
                            )
                          : ListView.builder(
                              // Use shrinkWrap and disable scrolling since this is inside SingleChildScrollView
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: tests.length,
                              itemBuilder: (context, index) {
                                final test = tests[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: TestCard(
                                    test: test,
                                    onUpdate: _handleTestUpdate,
                                    onDelete: _handleTestDelete,
                                  ),
                                );
                              },
                            ),
                  // Add padding at the bottom to prevent FAB from blocking content
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
      // Floating action button to add new tests
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddTestScreen(patientId: currentPatient.id!),
            ),
          );
          if (result == true) {
            // Refresh data when a new test is added
            _loadTests();
            _refreshPatientData(); // This will update critical status if needed
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Test',
        backgroundColor: Colors.purple[700],
      ),
    );
  }

  /// Builds the card showing patient details at the top of the screen
  ///
  /// Displays all relevant patient information and highlights critical patients
  Widget _buildPatientDetailsCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card title
            Text(
              'Patient Details',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700]),
            ),
            const SizedBox(height: 10),

            // Patient information fields
            _buildDetailRow('Name', currentPatient.name ?? 'N/A'),
            _buildDetailRow('Age', currentPatient.age.toString()),
            _buildDetailRow('Gender', currentPatient.gender ?? 'N/A'),
            _buildDetailRow('Address', currentPatient.address ?? 'N/A'),
            _buildDetailRow('Phone', currentPatient.phoneNumber ?? 'N/A'),
            _buildDetailRow(
                'Medical History',
                currentPatient.medicalHistory != null
                    ? currentPatient.medicalHistory!.join(', ')
                    : 'N/A'),
            const SizedBox(height: 10),

            // Warning badge for patients in critical condition
            if (currentPatient.criticalCondition == true)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 8),
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

  /// Helper method to build individual detail rows in the patient details card
  ///
  /// @param label The label for the data field (e.g., "Name", "Age")
  /// @param value The actual value for the field
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
