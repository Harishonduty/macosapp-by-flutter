class PostAttendance {
  final String studentId;
  final String studentName;
  final String absentType;
  final String session;
  final String absentDate;
  final String attendanceId;
  final String classId;

  PostAttendance({
    required this.studentId,
    required this.studentName,
    required this.absentType,
    required this.session,
    required this.absentDate,
    required this.attendanceId,
    required this.classId,
  });

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'absent_type': absentType,
      'session': session,
      'absent_date': absentDate,
      'attendance_id': attendanceId,
      'class_id': classId,
    };
  }
}
