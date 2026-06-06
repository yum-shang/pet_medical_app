class NotificationVO {
  final int id;
  final int notificationType;
  final String? title;
  final String? content;
  final int? appointmentId;
  final String? sendTime;
  final int status;
  final String? createdAt;

  NotificationVO({
    required this.id,
    required this.notificationType,
    this.title,
    this.content,
    this.appointmentId,
    this.sendTime,
    this.status = 1,
    this.createdAt,
  });

  factory NotificationVO.fromJson(Map<String, dynamic> json) {
    return NotificationVO(
      id: json['id'] ?? 0,
      notificationType: json['notification_type'] ?? 1,
      title: json['title'],
      content: json['content'],
      appointmentId: json['appointment_id'],
      sendTime: json['send_time'],
      status: json['status'] ?? 1,
      createdAt: json['created_at'],
    );
  }
}
