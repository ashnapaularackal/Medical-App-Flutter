class Test {
  final String id;
  final String patientId;
  final DateTime date;
  final String type;
  final String value;

  Test({
    required this.id,
    required this.patientId,
    required this.date,
    required this.type,
    required this.value,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['_id'] ?? '', // Provide a default value if null
      patientId: json['patientId'] ?? '', // Provide a default value if null
      date: DateTime.parse(json['date']),
      type: json['type'] ?? '', // Provide a default value if null
      value: json['value'] ?? '', // Provide a default value if null
    );
  }
}
