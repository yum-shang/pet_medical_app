class AppointmentType {
  static const int checkup = 1;
  static const int consultation = 2;

  static String label(int value) {
    switch (value) {
      case checkup:
        return '体检预约';
      case consultation:
        return '看病预约';
      default:
        return '未知';
    }
  }
}

class AppointmentStatus {
  static const int pending = 1;
  static const int completed = 2;
  static const int cancelled = 3;
  static const int expired = 4;

  static String label(int value) {
    switch (value) {
      case pending:
        return '待就诊';
      case completed:
        return '已完成';
      case cancelled:
        return '已取消';
      case expired:
        return '已过期';
      default:
        return '未知';
    }
  }
}

class MedicalRecordStatus {
  static const int created = 1;
  static const int completed = 2;
  static const int archived = 3;

  static String label(int value) {
    switch (value) {
      case created:
        return '已创建';
      case completed:
        return '已完成';
      case archived:
        return '已归档';
      default:
        return '未知';
    }
  }
}

class AiSessionStatus {
  static const int inProgress = 1;
  static const int ended = 2;
  static const int archived = 3;
}

class AiMessageSenderType {
  static const int user = 1;
  static const int ai = 2;
  static const int doctor = 3;
  static const int admin = 4;
}

class AnalysisType {
  static const int summary = 1;
  static const int symptom = 2;
  static const int risk = 3;
  static const int advice = 4;

  static String label(int value) {
    switch (value) {
      case summary:
        return '病历总结';
      case symptom:
        return '症状归纳';
      case risk:
        return '风险提示';
      case advice:
        return '健康建议';
      default:
        return '未知';
    }
  }
}

class RiskLevel {
  static const int low = 1;
  static const int medium = 2;
  static const int high = 3;

  static String label(int value) {
    switch (value) {
      case low:
        return '低';
      case medium:
        return '中';
      case high:
        return '高';
      default:
        return '未知';
    }
  }
}

class NotificationType {
  static const int appointment = 1;
  static const int system = 2;
  static const int aiAnalysis = 3;

  static String label(int value) {
    switch (value) {
      case appointment:
        return '预约提醒';
      case system:
        return '系统通知';
      case aiAnalysis:
        return 'AI分析提醒';
      default:
        return '未知';
    }
  }
}

class NotificationStatus {
  static const int pending = 0;
  static const int sent = 1;
  static const int failed = 2;
  static const int read = 3;
}
