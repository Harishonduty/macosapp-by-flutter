class StudentLeaveRequest {
  final String requestId;
  final String name;
  final String className;
  final String dateFrom;
  final String dateTo;
  final String classId;
  final String statusId;
  final String status;
  final String reason;

  StudentLeaveRequest({
    required this.requestId,
    required this.name,
    required this.className,
    required this.dateFrom,
    required this.dateTo,
    required this.classId,
    required this.statusId,
    required this.status,
    required this.reason,
  });

  factory StudentLeaveRequest.fromJson(Map<String, dynamic> json) {
    return StudentLeaveRequest(
      requestId: json['REQUEST_ID']?.toString() ?? '',
      name: json['NAME']?.toString() ?? '',
      className: json['CLASS_NAME']?.toString() ?? '',
      dateFrom: json['DATE_FROM']?.toString() ?? '',
      dateTo: json['DATE_TO']?.toString() ?? '',
      classId: json['CLASS_ID']?.toString() ?? '',
      statusId: json['STATUS_ID']?.toString() ?? '',
      status: json['STATUS']?.toString() ?? '',
      reason: json['REASON']?.toString() ?? '',
    );
  }
}
