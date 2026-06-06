class AppointmentVO {
  final int id;
  final String? appointmentNo;
  final int? userId;
  final String? userNickname;
  final int? petId;
  final String? petName;
  final int? hospitalId;
  final String? hospitalName;
  final int? doctorId;
  final String? doctorName;
  final int appointmentType;
  final String? symptomDescription;
  final String? appointmentTime;
  final String? reminderTime;
  final int status;
  final int? source;
  final String? createdAt;
  final String? updatedAt;

  AppointmentVO({
    required this.id,
    this.appointmentNo,
    this.userId,
    this.userNickname,
    this.petId,
    this.petName,
    this.hospitalId,
    this.hospitalName,
    this.doctorId,
    this.doctorName,
    this.appointmentType = 1,
    this.symptomDescription,
    this.appointmentTime,
    this.reminderTime,
    this.status = 1,
    this.source,
    this.createdAt,
    this.updatedAt,
  });

  factory AppointmentVO.fromJson(Map<String, dynamic> json) {
    return AppointmentVO(
      id: json['id'] ?? 0,
      appointmentNo: json['appointment_no'],
      userId: json['user_id'],
      userNickname: json['user_nickname'],
      petId: json['pet_id'],
      petName: json['pet_name'],
      hospitalId: json['hospital_id'],
      hospitalName: json['hospital_name'],
      doctorId: json['doctor_id'],
      doctorName: json['doctor_name'],
      appointmentType: json['appointment_type'] ?? 1,
      symptomDescription: json['symptom_description'],
      appointmentTime: json['appointment_time'],
      reminderTime: json['reminder_time'],
      status: json['status'] ?? 1,
      source: json['source'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'pet_id': petId,
        'hospital_id': hospitalId,
        'doctor_id': doctorId,
        'appointment_type': appointmentType,
        'symptom_description': symptomDescription,
        'appointment_time': appointmentTime,
      };
}
