class MedicalHistoryVO {
  final int id;
  final String historyType;
  final String description;
  final String? diagnosedAt;
  final int isCurrent;

  MedicalHistoryVO({
    required this.id,
    required this.historyType,
    required this.description,
    this.diagnosedAt,
    this.isCurrent = 0,
  });

  factory MedicalHistoryVO.fromJson(Map<String, dynamic> json) {
    return MedicalHistoryVO(
      id: json['id'] ?? 0,
      historyType: json['history_type'] ?? '',
      description: json['description'] ?? '',
      diagnosedAt: json['diagnosed_at'],
      isCurrent: json['is_current'] ?? 0,
    );
  }
}

class VaccinationVO {
  final int id;
  final String vaccineName;
  final String vaccinationDate;
  final String? nextDueDate;
  final String? hospitalName;
  final String? remark;

  VaccinationVO({
    required this.id,
    required this.vaccineName,
    required this.vaccinationDate,
    this.nextDueDate,
    this.hospitalName,
    this.remark,
  });

  factory VaccinationVO.fromJson(Map<String, dynamic> json) {
    return VaccinationVO(
      id: json['id'] ?? 0,
      vaccineName: json['vaccine_name'] ?? '',
      vaccinationDate: json['vaccination_date'] ?? '',
      nextDueDate: json['next_due_date'],
      hospitalName: json['hospital_name'],
      remark: json['remark'],
    );
  }
}

class AllergyVO {
  final int id;
  final String allergen;
  final String? symptomDescription;
  final int severityLevel;
  final String? remark;

  AllergyVO({
    required this.id,
    required this.allergen,
    this.symptomDescription,
    this.severityLevel = 1,
    this.remark,
  });

  factory AllergyVO.fromJson(Map<String, dynamic> json) {
    return AllergyVO(
      id: json['id'] ?? 0,
      allergen: json['allergen'] ?? '',
      symptomDescription: json['symptom_description'],
      severityLevel: json['severity_level'] ?? 1,
      remark: json['remark'],
    );
  }
}
