class StudentAttendanceData {
  final String studentId;
  final String name;
  final String admissionNo;
  String absentType;
  String session;
  final String attendanceId;
  final String classId;
  bool isSelected;

  StudentAttendanceData({
    required this.studentId,
    required this.name,
    required this.admissionNo,
    required this.absentType,
    required this.session,
    required this.attendanceId,
    required this.classId,
    this.isSelected = false,
  });

  factory StudentAttendanceData.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceData(
      studentId: json['STUDENT_ID']?.toString() ?? json['student_id']?.toString() ?? '',
      name: json['STUDENT_NAME']?.toString() ?? json['student_name']?.toString() ?? json['NAME']?.toString() ?? '',
      admissionNo: json['ADMISSION_NO']?.toString() ?? json['admission_no']?.toString() ?? '',
      absentType: json['ABSENT_TYPE']?.toString() ?? json['absent_type']?.toString() ?? '',
      session: json['SESSION']?.toString() ?? json['session']?.toString() ?? '',
      attendanceId: json['ATTENDANCE_ID']?.toString() ?? json['attendance_id']?.toString() ?? '',
      classId: json['CLASS_ID']?.toString() ?? json['class_id']?.toString() ?? '',
      isSelected: json['selected'] ?? false,
    );
  }
}
