class ClassAttendanceReportData {
  final String? className;
  final String? classId;
  final String? totalStudents;
  final String? presentCount;
  final String? absentCount;
  final String? absentNames;
  final String? date;
  final String? studentName;
  final String? attendanceStatus;

  ClassAttendanceReportData({
    this.className,
    this.classId,
    this.totalStudents,
    this.presentCount,
    this.absentCount,
    this.absentNames,
    this.date,
    this.studentName,
    this.attendanceStatus,
  });

  factory ClassAttendanceReportData.fromJson(Map<String, dynamic> json) {
    return ClassAttendanceReportData(
      className: json['CLASS']?.toString(),
      classId: json['CLASS_ID']?.toString(),
      totalStudents: json['TOTAL_STUDENTS']?.toString(),
      presentCount: json['PRESENT_COUNT']?.toString(),
      absentCount: json['ABSENT_COUNT']?.toString(),
      absentNames: json['ABSENTS_NAMES']?.toString(),
      date: json['DATE']?.toString(),
      studentName: json['STUDENT_NAME']?.toString(),
      attendanceStatus: json['ATTENDANCE_STATUS']?.toString(),
    );
  }
}
