class HomeWork {
  final String homeworkId;
  final String subjectName;
  final String description;
  final String className;
  final String homeworkDate;

  HomeWork({
    required this.homeworkId,
    required this.subjectName,
    required this.description,
    required this.className,
    required this.homeworkDate,
  });

  factory HomeWork.fromJson(Map<String, dynamic> json) {
    return HomeWork(
      homeworkId: json['HOMEWORK_ID']?.toString() ?? '',
      subjectName: json['SUBJECT_NAME']?.toString() ?? '',
      description: json['DESCRIPTION']?.toString() ?? '',
      className: json['CLASS_NAME']?.toString() ?? '',
      homeworkDate: json['HOMEWORK_DATE']?.toString() ?? '',
    );
  }
}
