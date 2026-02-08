class LeaveRequest {
  final String name;
  final String className;
  final String dateFrom;
  final String dateTo;
  final String approvalStatus;

  LeaveRequest({
    required this.name,
    required this.className,
    required this.dateFrom,
    required this.dateTo,
    required this.approvalStatus,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      name: json['NAME']?.toString() ?? '',
      className: json['CLASS_NAME']?.toString() ?? '',
      dateFrom: json['DATE_FROM']?.toString() ?? '',
      dateTo: json['DATE_TO']?.toString() ?? '',
      approvalStatus: json['APPROVAL_STATUS']?.toString() ?? '',
    );
  }
}
