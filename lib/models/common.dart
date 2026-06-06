class HospitalOptionVO {
  final int id;
  final String hospitalName;

  HospitalOptionVO({required this.id, required this.hospitalName});

  factory HospitalOptionVO.fromJson(Map<String, dynamic> json) {
    return HospitalOptionVO(
      id: json['id'] ?? 0,
      hospitalName: json['hospital_name'] ?? '',
    );
  }
}

class DoctorOptionVO {
  final int id;
  final String doctorName;
  final String? title;

  DoctorOptionVO({
    required this.id,
    required this.doctorName,
    this.title,
  });

  factory DoctorOptionVO.fromJson(Map<String, dynamic> json) {
    return DoctorOptionVO(
      id: json['id'] ?? 0,
      doctorName: json['doctor_name'] ?? '',
      title: json['title'],
    );
  }
}

class FileUploadResult {
  final String fileUrl;
  final String fileName;

  FileUploadResult({required this.fileUrl, required this.fileName});

  factory FileUploadResult.fromJson(Map<String, dynamic> json) {
    return FileUploadResult(
      fileUrl: json['file_url'] ?? '',
      fileName: json['file_name'] ?? '',
    );
  }
}

class DoctorDetailVO {
  final int id;
  final int? hospitalId;
  final String? hospitalName;
  final String username;
  final String doctorName;
  final int gender;
  final String? phone;
  final String? email;
  final String? title;
  final String? specialty;
  final String? avatarUrl;
  final String? intro;
  final int status;
  final String? createdAt;
  final String? updatedAt;

  DoctorDetailVO({
    required this.id,
    this.hospitalId,
    this.hospitalName,
    required this.username,
    required this.doctorName,
    this.gender = 1,
    this.phone,
    this.email,
    this.title,
    this.specialty,
    this.avatarUrl,
    this.intro,
    this.status = 1,
    this.createdAt,
    this.updatedAt,
  });

  factory DoctorDetailVO.fromJson(Map<String, dynamic> json) {
    return DoctorDetailVO(
      id: json['id'] ?? 0,
      hospitalId: json['hospital_id'],
      hospitalName: json['hospital_name'],
      username: json['username'] ?? '',
      doctorName: json['doctor_name'] ?? '',
      gender: json['gender'] ?? 1,
      phone: json['phone'],
      email: json['email'],
      title: json['title'],
      specialty: json['specialty'],
      avatarUrl: json['avatar_url'],
      intro: json['intro'],
      status: json['status'] ?? 1,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
