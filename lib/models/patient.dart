class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String? address;
  final String? phoneNumber;
  final List<String> medicalHistory;
  final bool criticalCondition;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    this.address,
    this.phoneNumber,
    this.medicalHistory = const [],
    this.criticalCondition = false,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['_id'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      medicalHistory: List<String>.from(json['medicalHistory'] ?? []),
      criticalCondition: json['criticalCondition'] ?? false,
    );
  }
}
