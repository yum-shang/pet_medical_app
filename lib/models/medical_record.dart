class MedicalRecordVO {
  final int id;
  final int? appointmentId;
  final int petId;
  final int? userId;
  final int? doctorId;
  final String? doctorName;
  final String? chiefComplaint;
  final String? presentHistory;
  final String? physicalExamination;
  final String? preliminaryDiagnosis;
  final String? treatmentPlan;
  final String? prescription;
  final String? doctorAdvice;
  final String? visitTime;
  final int status;

  MedicalRecordVO({
    required this.id,
    this.appointmentId,
    required this.petId,
    this.userId,
    this.doctorId,
    this.doctorName,
    this.chiefComplaint,
    this.presentHistory,
    this.physicalExamination,
    this.preliminaryDiagnosis,
    this.treatmentPlan,
    this.prescription,
    this.doctorAdvice,
    this.visitTime,
    this.status = 1,
  });

  factory MedicalRecordVO.fromJson(Map<String, dynamic> json) {
    return MedicalRecordVO(
      id: json['id'] ?? 0,
      appointmentId: json['appointment_id'],
      petId: json['pet_id'] ?? 0,
      userId: json['user_id'],
      doctorId: json['doctor_id'],
      doctorName: json['doctor_name'],
      chiefComplaint: json['chief_complaint'],
      presentHistory: json['present_history'],
      physicalExamination: json['physical_examination'],
      preliminaryDiagnosis: json['preliminary_diagnosis'],
      treatmentPlan: json['treatment_plan'],
      prescription: json['prescription'],
      doctorAdvice: json['doctor_advice'],
      visitTime: json['visit_time'],
      status: json['status'] ?? 1,
    );
  }
}

class ReportVO {
  final int id;
  final String? reportTitle;
  final String? reportType;
  final String? fileUrl;
  final String? reportContent;
  final String? uploadedAt;

  ReportVO({
    required this.id,
    this.reportTitle,
    this.reportType,
    this.fileUrl,
    this.reportContent,
    this.uploadedAt,
  });

  factory ReportVO.fromJson(Map<String, dynamic> json) {
    return ReportVO(
      id: json['id'] ?? 0,
      reportTitle: json['report_title'],
      reportType: json['report_type'],
      fileUrl: json['file_url'],
      reportContent: json['report_content'],
      uploadedAt: json['uploaded_at'],
    );
  }
}
