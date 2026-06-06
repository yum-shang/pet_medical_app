class AiSessionVO {
  final int id;
  final String? sessionNo;
  final int petId;
  final int? sourceType;
  final String? modelType;
  final String? modelName;
  final String? sessionSummary;
  final int status;
  final String? createdAt;
  final String? updatedAt;

  AiSessionVO({
    required this.id,
    this.sessionNo,
    required this.petId,
    this.sourceType,
    this.modelType,
    this.modelName,
    this.sessionSummary,
    this.status = 1,
    this.createdAt,
    this.updatedAt,
  });

  factory AiSessionVO.fromJson(Map<String, dynamic> json) {
    return AiSessionVO(
      id: json['id'] ?? 0,
      sessionNo: json['session_no'],
      petId: json['pet_id'] ?? 0,
      sourceType: json['source_type'],
      modelType: json['model_type'],
      modelName: json['model_name'],
      sessionSummary: json['session_summary'],
      status: json['status'] ?? 1,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class AiMessageVO {
  final int id;
  final int senderType;
  final int? senderId;
  final String messageContent;
  final int? messageType;
  final String? createdAt;

  AiMessageVO({
    required this.id,
    required this.senderType,
    this.senderId,
    required this.messageContent,
    this.messageType,
    this.createdAt,
  });

  bool get isUser => senderType == 1;
  bool get isAi => senderType == 2;

  factory AiMessageVO.fromJson(Map<String, dynamic> json) {
    return AiMessageVO(
      id: json['id'] ?? 0,
      senderType: json['sender_type'] ?? 1,
      senderId: json['sender_id'],
      messageContent: json['message_content'] ?? '',
      messageType: json['message_type'],
      createdAt: json['created_at'],
    );
  }
}

class AiAnalysisVO {
  final int id;
  final int analysisType;
  final int? inputSource;
  final String? analysisResult;
  final String? ruleBasedResult;
  final String? llmBasedResult;
  final int? riskLevel;
  final int? reviewedByDoctor;
  final String? createdAt;

  AiAnalysisVO({
    required this.id,
    required this.analysisType,
    this.inputSource,
    this.analysisResult,
    this.ruleBasedResult,
    this.llmBasedResult,
    this.riskLevel,
    this.reviewedByDoctor,
    this.createdAt,
  });

  factory AiAnalysisVO.fromJson(Map<String, dynamic> json) {
    return AiAnalysisVO(
      id: json['id'] ?? 0,
      analysisType: json['analysis_type'] ?? 1,
      inputSource: json['input_source'],
      analysisResult: json['analysis_result'],
      ruleBasedResult: json['rule_based_result'],
      llmBasedResult: json['llm_based_result'],
      riskLevel: json['risk_level'],
      reviewedByDoctor: json['reviewed_by_doctor'],
      createdAt: json['created_at'],
    );
  }
}
