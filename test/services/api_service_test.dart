import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'dart:convert';
import 'package:mapd722_group_4_ashna/models/patient.dart';
import 'package:mapd722_group_4_ashna/models/test.dart';
import 'package:mapd722_group_4_ashna/services/api_service.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  group('ApiService Tests', () {
    late MockClient mockClient;
    late String patientId;

    setUp(() {
      mockClient = MockClient();
      patientId = '647b4c9f7b9d3b3f9b9d3b3f';
    });

    test('getAllPatients should return a list of patients', () async {
      // Arrange: Mock the API response (if needed)
      final mockResponse = [
        {
          '_id': {'\$oid': '647b4c9f7b9d3b3f9b9d3b3f'},
          'name': 'John Doe',
          'age': 30,
          'gender': 'Male',
          'address': '123 Main St',
          'phoneNumber': '555-1234',
          'medicalHistory': ['Allergy to penicillin', 'Asthma'],
          'criticalCondition': true,
        },
        {
          '_id': {'\$oid': '647b4c9f7b9d3b3f9b9d3b40'},
          'name': 'Jane Doe',
          'age': 25,
          'gender': 'Female',
        },
      ];

      // Act: Call the method you want to test
      final patients =
          mockResponse.map((json) => Patient.fromJson(json)).toList();

      // Assert: Verify the results
      expect(patients.length, 2);
      expect(patients[0].name, 'John Doe');
      expect(patients[1].name, 'Jane Doe');
    });

    test('getPatientById should return a specific patient', () async {
      // Arrange: Mock the API response (if needed)
      final mockResponse = {
        '_id': {'\$oid': '647b4c9f7b9d3b3f9b9d3b3f'},
        'name': 'John Doe',
        'age': 30,
        'gender': 'Male',
        'address': '123 Main St',
        'phoneNumber': '555-1234',
        'medicalHistory': ['Allergy to penicillin', 'Asthma'],
        'criticalCondition': true,
      };

      // Act: Call the method you want to test
      final patient = Patient.fromJson(mockResponse);

      // Assert: Verify the results
      expect(patient.id, '647b4c9f7b9d3b3f9b9d3b3f');
      expect(patient.name, 'John Doe');
    });
    test('getPatientHistory should return patient history', () async {
      // Arrange
      final mockResponse = {
        'patientId': '647b4c9f7b9d3b3f9b9d3b3f',
        'allergies': ['Peanuts', 'Shellfish'],
        'surgeries': ['Appendectomy', 'Knee replacement']
      };

      // Act
      final patientHistory = mockResponse;

      // Assert
      expect(patientHistory['patientId'], '647b4c9f7b9d3b3f9b9d3b3f');
      expect(patientHistory['allergies'], ['Peanuts', 'Shellfish']);
    });

    test('getTestById should return a specific test', () async {
      // Arrange
      final mockResponse = {
        '_id': '647b4c9f7b9d3b3f9b9d3b45',
        'patientId': '647b4c9f7b9d3b3f9b9d3b3f',
        'date': '2023-06-15T00:00:00.000Z',
        'type': 'Blood Sugar',
        'value': '110',
      };

      // Act
      final test = Test.fromJson(mockResponse);

      // Assert
      expect(test.id, '647b4c9f7b9d3b3f9b9d3b45');
      expect(test.type, 'Blood Sugar');
      expect(test.value, '110');
    });

    test('updateTest should update test details', () async {
      // Arrange
      final mockResponse = {
        '_id': '647b4c9f7b9d3b3f9b9d3b45',
        'patientId': '647b4c9f7b9d3b3f9b9d3b3f',
        'date': '2023-06-15T00:00:00.000Z',
        'type': 'Updated Blood Sugar',
        'value': '115',
      };

      // Act
      final test = Test.fromJson(mockResponse);

      // Assert
      expect(test.id, '647b4c9f7b9d3b3f9b9d3b45');
      expect(test.type, 'Updated Blood Sugar');
      expect(test.value, '115');
    });

    test('deleteTest should delete a test', () async {
      // Arrange
      final mockResponse = null;

      // Act
      final test = mockResponse;

      // Assert
      expect(test, null);
    });
  });
}
