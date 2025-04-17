import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/patient.dart';
import '../models/test.dart';

/// Service class that handles all API communications with the backend server.
/// Provides methods for CRUD operations on patients and their medical tests.
class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  /// Default headers used in all HTTP requests.
  /// Sets the content type to JSON for proper data formatting.
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  /// Fetches all patients from the server.
  ///
  /// Returns a list of [Patient] objects.
  /// Throws an exception if the request fails.
  static Future<List<Patient>> getAllPatients() async {
    final response =
        await http.get(Uri.parse('$baseUrl/patients'), headers: headers);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Patient.fromJson(json)).toList();
    } else {
      throw _handleError(response);
    }
  }

  /// Creates a new patient record on the server.
  ///
  /// [patientData] - Map containing the patient information.
  /// Returns the newly created [Patient] object with server-generated ID.
  /// Throws an exception if the request fails.
  static Future<Patient> addPatient(Map<String, dynamic> patientData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/patients'),
        headers: headers,
        body: json.encode(patientData),
      );
      if (response.statusCode == 201) {
        return Patient.fromJson(json.decode(response.body));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw Exception('Failed to add patient: ${e.toString()}');
    }
  }

  /// Retrieves a specific patient by ID.
  ///
  /// [id] - The unique identifier of the patient.
  /// Returns a [Patient] object.
  /// Throws an exception if the patient is not found or another error occurs.
  static Future<Patient> getPatientById(String id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/patients/$id'), headers: headers);
    if (response.statusCode == 200) {
      return Patient.fromJson(json.decode(response.body));
    } else {
      throw _handleError(response);
    }
  }

  /// Fetches all medical tests associated with a specific patient.
  ///
  /// [patientId] - The unique identifier of the patient.
  /// Returns a list of [Test] objects.
  /// Throws an exception if the request fails.
  static Future<List<Test>> getTestsForPatient(String patientId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/patients/$patientId/tests'), headers: headers);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Test.fromJson(json)).toList();
    } else {
      throw _handleError(response);
    }
  }

  /// Adds a new medical test for a specific patient.
  ///
  /// [patientId] - The unique identifier of the patient.
  /// [testData] - Map containing the test information.
  /// Returns the newly created [Test] object with server-generated ID.
  /// Throws an exception if the request fails.
  static Future<Test> addTestForPatient(
      String patientId, Map<String, dynamic> testData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/patients/$patientId/tests'),
        headers: headers,
        body: json.encode(testData),
      );
      if (response.statusCode == 201) {
        return Test.fromJson(json.decode(response.body));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw Exception('Failed to add test: ${e.toString()}');
    }
  }

  /// Fetches all patients marked as critical.
  ///
  /// Returns a list of [Patient] objects in critical condition.
  /// Throws an exception if the request fails.
  static Future<List<Patient>> getCriticalPatients() async {
    final response = await http.get(Uri.parse('$baseUrl/patients/critical'),
        headers: headers);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Patient.fromJson(json)).toList();
    } else {
      throw _handleError(response);
    }
  }

  /// Updates an existing patient's information.
  ///
  /// [id] - The unique identifier of the patient to update.
  /// [patientData] - Map containing the updated patient information.
  /// Throws an exception if the update fails.
  static Future<void> updatePatient(
      String id, Map<String, dynamic> patientData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/patients/$id'),
        headers: headers,
        body: json.encode(patientData),
      );
      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      throw Exception('Failed to update patient: ${e.toString()}');
    }
  }

  /// Deletes a patient record from the system.
  ///
  /// [id] - The unique identifier of the patient to delete.
  /// Throws an exception if the deletion fails.
  static Future<void> deletePatient(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/patients/$id'),
          headers: headers);
      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      throw Exception('Failed to delete patient: ${e.toString()}');
    }
  }

  /// Updates an existing medical test.
  ///
  /// [patientId] - The unique identifier of the patient.
  /// [testId] - The unique identifier of the test to update.
  /// [testData] - Map containing the updated test information.
  /// Returns the updated [Test] object.
  /// Throws an exception if the update fails.
  static Future<Test> updateTest({
    required String patientId,
    required String testId,
    required Map<String, dynamic> testData,
  }) async {
    final Uri url = Uri.parse('${baseUrl}/patients/$patientId/tests/$testId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(testData),
      );

      if (response.statusCode == 200) {
        return Test.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update test: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update test: $e');
    }
  }

  /// Deletes a medical test from the system.
  ///
  /// [patientId] - The unique identifier of the patient.
  /// [testId] - The unique identifier of the test to delete.
  /// Throws an exception if the deletion fails.
  static Future<void> deleteTest({
    required String patientId,
    required String testId,
  }) async {
    final Uri url = Uri.parse('${baseUrl}/patients/$patientId/tests/$testId');

    try {
      final response = await http.delete(url);

      // Accept both 200 (OK) and 204 (No Content) as successful responses
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete test: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete test: $e');
    }
  }

  /// Retrieves a specific test by its ID for a patient.
  ///
  /// [patientId] - The unique identifier of the patient.
  /// [testId] - The unique identifier of the test.
  /// Returns a [Test] object.
  /// Throws an exception if the test is not found or another error occurs.
  static Future<Test> getTestById(String patientId, String testId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/patients/$patientId/tests/$testId'),
        headers: headers);
    if (response.statusCode == 200) {
      return Test.fromJson(json.decode(response.body));
    } else {
      throw _handleError(response);
    }
  }

  /// Fetches a patient's medical history.
  ///
  /// [patientId] - The unique identifier of the patient.
  /// Returns a map containing the patient's medical history data.
  /// Throws an exception if the request fails.
  static Future<Map<String, dynamic>> getPatientHistory(
      String patientId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/patients/$patientId/history'),
        headers: headers);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw _handleError(response);
    }
  }

  /// Helper method that converts HTTP error responses into meaningful exceptions.
  ///
  /// [response] - The HTTP response to process.
  /// Returns an appropriate Exception based on the status code.
  static Exception _handleError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        return Exception('Bad request: ${response.body}');
      case 401:
        return Exception('Unauthorized: Check authentication');
      case 404:
        return Exception('Resource not found');
      case 500:
        return Exception('Server error: ${response.body}');
      default:
        return Exception('Request failed: ${response.statusCode}');
    }
  }
}
