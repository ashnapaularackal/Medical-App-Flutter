import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/patient.dart';
import '../models/test.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  static Future<List<Patient>> getAllPatients() async {
    final response = await http.get(Uri.parse('$baseUrl/patients'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Patient.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load patients');
    }
  }

  static Future<Patient> addPatient(Map<String, dynamic> patientData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/patients'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(patientData),
    );
    if (response.statusCode == 201) {
      return Patient.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add patient');
    }
  }

  static Future<Patient> getPatientById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/patients/$id'));
    if (response.statusCode == 200) {
      return Patient.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load patient');
    }
  }

  static Future<List<Test>> getTestsForPatient(String patientId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/patients/$patientId/tests'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Test.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tests');
    }
  }

  static Future<Test> addTestForPatient(
      String patientId, Map<String, dynamic> testData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/patients/$patientId/tests'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(testData),
    );
    if (response.statusCode == 201) {
      return Test.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add test');
    }
  }

  static Future<List<Patient>> getCriticalPatients() async {
    final response = await http.get(Uri.parse('$baseUrl/patients/critical'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Patient.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load critical patients');
    }
  }

  static Future<void> updatePatient(
      String id, Map<String, dynamic> patientData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/patients/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(patientData),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update patient');
    }
  }

  static Future<void> deletePatient(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/patients/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete patient');
    }
  }

  static Future<void> updateTest(
      String testId, Map<String, dynamic> testData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tests/$testId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(testData),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update test');
    }
  }

  static Future<void> deleteTest(String testId) async {
    final response = await http.delete(Uri.parse('$baseUrl/tests/$testId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete test');
    }
  }
}
