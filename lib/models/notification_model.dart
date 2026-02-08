class NotificationModel {
  final String dateTime;
  final String userId;
  final String message;
  final String messageType;
  final String isView;

  NotificationModel({
    required this.dateTime,
    required this.userId,
    required this.message,
    required this.messageType,
    required this.isView,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      dateTime: json['DATE_TIME']?.toString() ?? '',
      userId: json['USER_ID']?.toString() ?? '',
      message: json['MESSAGE']?.toString() ?? '',
      messageType: json['MESSAGE_TYPE']?.toString() ?? '',
      isView: json['ISVIEW']?.toString() ?? '',
    );
  }
}
