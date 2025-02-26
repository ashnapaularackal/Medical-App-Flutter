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
      id: json['_id'],
      patientId: json['patientId'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      value: json['value'],
    );
  }
}
