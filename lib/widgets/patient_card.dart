import 'package:flutter/material.dart';
import '../models/patient.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;

  const PatientCard({Key? key, required this.patient, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: patient.criticalCondition ? Colors.red : Colors.blue,
          child: Text(
            patient.name[0].toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
        ),
        title:
            Text(patient.name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Age: ${patient.age}, Gender: ${patient.gender}'),
        trailing: patient.criticalCondition
            ? Chip(
                label: Text('Critical', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
              )
            : Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
