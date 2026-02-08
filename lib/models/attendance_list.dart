class AttendanceList {
  final String sessionType;
  final String remarks;
  final String date;

  AttendanceList({
    required this.sessionType,
    required this.remarks,
    required this.date,
  });

  factory AttendanceList.fromJson(Map<String, dynamic> json) {
    return AttendanceList(
      sessionType: json['SESSION_TYPE']?.toString() ?? '',
      remarks: json['REMARKS']?.toString() ?? '',
      date: json['DATE']?.toString() ?? '',
    );
  }
}
