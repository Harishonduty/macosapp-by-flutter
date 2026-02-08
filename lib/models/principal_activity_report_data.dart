class AssignmentReportData {
  final String? title;
  final String? path;
  final String? assignmentId;
  final String? classId;
  final String? fileType;
  final String? date;
  final String? staffName;
  final String? entryDate;

  AssignmentReportData({
    this.title,
    this.path,
    this.assignmentId,
    this.classId,
    this.fileType,
    this.date,
    this.staffName,
    this.entryDate,
  });

  factory AssignmentReportData.fromJson(Map<String, dynamic> json) {
    return AssignmentReportData(
      title: json['TITLE']?.toString(),
      path: json['PATH']?.toString(),
      assignmentId: json['ASSIGNMENT_ID']?.toString(),
      classId: json['CLASS_ID']?.toString(),
      fileType: json['File_Type']?.toString(),
      date: json['DATE']?.toString(),
      staffName: json['STAFF_NAME']?.toString(),
      entryDate: json['ENTRY_DATE']?.toString(),
    );
  }
}

class ProjectReportData {
  final String? title;
  final String? path;
  final String? projectId;
  final String? classId;
  final String? fileType;
  final String? date;
  final String? staffName;
  final String? entryDate;

  ProjectReportData({
    this.title,
    this.path,
    this.projectId,
    this.classId,
    this.fileType,
    this.date,
    this.staffName,
    this.entryDate,
  });

  factory ProjectReportData.fromJson(Map<String, dynamic> json) {
    return ProjectReportData(
      title: json['TITLE']?.toString(),
      path: json['PATH']?.toString(),
      projectId: json['PROJECT_ID']?.toString(),
      classId: json['CLASS_ID']?.toString(),
      fileType: json['File_Type']?.toString(),
      date: json['DATE']?.toString(),
      staffName: json['STAFF_NAME']?.toString(),
      entryDate: json['ENTRY_DATE']?.toString(),
    );
  }
}

class GalleryReportData {
  final String? title;
  final String? path;
  final String? galleryId;
  final String? classId;
  final String? fileType;
  final String? staffName;
  final String? entryDate;

  GalleryReportData({
    this.title,
    this.path,
    this.galleryId,
    this.classId,
    this.fileType,
    this.staffName,
    this.entryDate,
  });

  factory GalleryReportData.fromJson(Map<String, dynamic> json) {
    return GalleryReportData(
      title: json['GALLARY_TITLE']?.toString(),
      path: json['PATH']?.toString(),
      galleryId: json['GALLARY_ID']?.toString(),
      classId: json['CLASS_ID']?.toString(),
      fileType: json['File_Type']?.toString(),
      staffName: json['STAFF_NAME']?.toString(),
      entryDate: json['ENTRY_DATE']?.toString(),
    );
  }
}
