class Patient {
  final String? id;
  final String? name;
  final int? age;
  final String? gender;
  final String? address;
  final String? phoneNumber;
  final List<String>? medicalHistory;
  final bool? criticalCondition;

  Patient({
    this.id = '',
    required this.name,
    required this.age,
    required this.gender,
    this.address,
    this.phoneNumber,
    this.medicalHistory = const [],
    this.criticalCondition = false,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    // Convert MongoDB's ObjectId to string if needed
    var id = '';
    if (json.containsKey('_id')) {
      if (json['_id'] is Map && json['_id'].containsKey('\$oid')) {
        // Handle MongoDB extended JSON format
        id = json['_id']['\$oid'];
      } else {
        // Handle regular string ID
        id = json['_id'].toString();
      }
    } else if (json.containsKey('id')) {
      id = json['id'].toString();
    }

    return Patient(
      id: id,
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      medicalHistory: List<String>.from(json['medicalHistory'] ?? []),
      criticalCondition: json['criticalCondition'] ?? false,
    );
  }
}
