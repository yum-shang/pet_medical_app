enum RecordStatus { open, closed }

class MedicalRecord {
  final String id;
  final String petId;
  final DateTime date;
  final String title;
  final String description;
  final String doctorName;
  final String hospital;
  final RecordStatus status;

  MedicalRecord({
    required this.id,
    required this.petId,
    required this.date,
    required this.title,
    required this.description,
    required this.doctorName,
    required this.hospital,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'date': date.toIso8601String(),
      'title': title,
      'description': description,
      'doctorName': doctorName,
      'hospital': hospital,
      'status': status.index,
    };
  }

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'],
      petId: json['petId'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      description: json['description'],
      doctorName: json['doctorName'],
      hospital: json['hospital'],
      status: RecordStatus.values[json['status']],
    );
  }
}
