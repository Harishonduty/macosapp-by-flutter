class UpdateLeaveStatus {
  final String requestId;
  final String name;
  final String className;
  final String dateFrom;
  final String dateTo;
  final String classId;
  final String statusId;
  final String status;

  UpdateLeaveStatus({
    required this.requestId,
    required this.name,
    required this.className,
    required this.dateFrom,
    required this.dateTo,
    required this.classId,
    required this.statusId,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'REQUEST_ID': requestId,
      'NAME': name,
      'CLASS_NAME': className,
      'DATE_FROM': dateFrom,
      'DATE_TO': dateTo,
      'CLASS_ID': classId,
      'STATUS_ID': statusId,
      'STATUS': status,
    };
  }
}
