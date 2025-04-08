import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/patient.dart';
import '../models/test.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    // Add authentication headers if needed
    // 'Authorization': 'Bearer your_token',
  };

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

  static Future<Patient> getPatientById(String id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/patients/$id'), headers: headers);
    if (response.statusCode == 200) {
      return Patient.fromJson(json.decode(response.body));
    } else {
      throw _handleError(response);
    }
  }

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

  // Add these methods to your ApiService class

// Update test
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

// Delete test
  static Future<void> deleteTest({
    required String patientId,
    required String testId,
  }) async {
    final Uri url = Uri.parse('${baseUrl}/patients/$patientId/tests/$testId');

    try {
      final response = await http.delete(url);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete test: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete test: $e');
    }
  }

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
