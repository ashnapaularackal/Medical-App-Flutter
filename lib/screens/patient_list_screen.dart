import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../widgets/patient_card.dart';
import '../services/api_service.dart';
import 'patient_detail_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({Key? key}) : super(key: key);

  @override
  PatientListScreenState createState() => PatientListScreenState();
}

class PatientListScreenState extends State<PatientListScreen>
    with AutomaticKeepAliveClientMixin {
  List<Patient> patients = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadPatients();
  }

  Future<void> loadPatients() async {
    try {
      final loadedPatients = await ApiService.getAllPatients();
      setState(() {
        patients = loadedPatients;
        _loading = false;
      });
    } catch (e) {
      print('Error loading patients: $e');
      setState(() {
        _loading = false;
      });
      _showErrorSnackBar('Failed to load patients. Please try again.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Patient List', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[100]!, Colors.purple[100]!],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? Center(child: CircularProgressIndicator())
              : patients.isEmpty
                  ? Center(child: Text('No patients found.'))
                  : ListView.builder(
                      itemCount: patients.length,
                      itemBuilder: (context, index) {
                        final patient = patients[index];
                        return PatientCard(
                          patient: patient,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/patient_details',
                              arguments: patient,
                            );
                          },
                        );
                      },
                    ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
