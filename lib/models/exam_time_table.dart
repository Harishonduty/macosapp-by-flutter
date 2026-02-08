class ExamTimeTable {
  final String examTimeTableId;
  final String date;
  final String day;
  final String subjectName;
  final String startTime;
  final String endTime;

  ExamTimeTable({
    required this.examTimeTableId,
    required this.date,
    required this.day,
    required this.subjectName,
    required this.startTime,
    required this.endTime,
  });

  factory ExamTimeTable.fromJson(Map<String, dynamic> json) {
    return ExamTimeTable(
      examTimeTableId: json['EXAM_TIME_TABLE_ID']?.toString() ?? '',
      date: json['EXAM_DATE']?.toString() ?? '',
      day: json['DAY']?.toString() ?? '',
      subjectName: json['SUBJECT_NAME']?.toString() ?? '',
      startTime: json['START_TIME']?.toString() ?? '',
      endTime: json['END_TIME']?.toString() ?? '',
    );
  }
}
