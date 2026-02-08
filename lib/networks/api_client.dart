import 'package:dio/dio.dart';

class ApiClient {
  static const String baseUrl = 'https://infoschoolplus.com/';
  
  final Dio dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  Future<Response> login(String username, String password) async {
    try {
      final response = await dio.post(
        'api/Auth/SignIn',
        data: {
          'USERNAME': username,
          'PASSWORD': password,
        },
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStaffInfo(String token) async {
    try {
      final response = await dio.get(
        'api/Profiles/FetchStaffProfile',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStudentDetails(String token) async {
    try {
      final response = await dio.get(
        'api/PushNotification/getStudentDetails',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getViewStatus(String token) async {
    try {
      final response = await dio.get(
        'api/Admin/FetchViewsStatus',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> deletePushToken(String token, String fcmToken) async {
    try {
      final response = await dio.post(
        'api/PushNotification/deletePushToken',
        data: {'token': fcmToken},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStudentTimeTable(String token) async {
    try {
      final response = await dio.get(
        'api/PushNotification/getTimeTable',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStudentExamDetailsList(String token) async {
    try {
      final response = await dio.get(
        'api/admin/FetchExam',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getExamTimeTable(String token, String examId, String studentId) async {
    try {
      final response = await dio.get(
        'api/PushNotification/getExamTimeTable',
        queryParameters: {
          'sExamId': examId,
          'sStudentId': studentId,
        },
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getHomeWorks(String token, String? date, String? classId) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (date != null && date.isNotEmpty) queryParams['sDate'] = date;
      if (classId != null && classId.isNotEmpty) queryParams['sClassId'] = classId;

      final response = await dio.get(
        'api/PushNotification/getHomeWork',
        queryParameters: queryParams,
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> updateHomeworkViewStatus(String token) async {
    try {
      final response = await dio.get(
        'api/Admin/UpdateHomeWorkViewStatus',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStudentAttendance(String token, String studentId) async {
    try {
      final response = await dio.get(
        'api/PushNotification/getStudentAttendance',
        queryParameters: {'sStudentId': studentId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStudentLeaveRequests(String token, String studentId) async {
    try {
      final response = await dio.get(
        'api/PushNotification/getLeaveRequest',
        queryParameters: {'sStudentId': studentId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getNotificationDetails(String token, String? studentId) async {
    try {
      final response = await dio.get(
        'api/PushNotification/getNotificaitonDetails',
        queryParameters: studentId != null ? {'id': studentId} : {},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> updateNotificationViewStatus(String token) async {
    try {
      final response = await dio.get(
        'api/Admin/UpdateNotificationViewStatus',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getExamMarks(String token, String studentId, String examId) async {
    try {
      final response = await dio.get(
        'api/PushNotification/getExamMark',
        queryParameters: {
          'sStudentId': studentId,
          'sExamId': examId,
        },
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getFeeReceipt(String token, String studentId) async {
    try {
      final response = await dio.get(
        'api/PushNotification/getFeeReceipt',
        queryParameters: {'sStudentId': studentId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getGalleryByStudentId(String token, String studentId) async {
    try {
      final response = await dio.get(
        'api/Gallery/getGalleryByStudentId',
        queryParameters: {'sStudentId': studentId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStudentAssignment(String token, String studentId) async {
    try {
      final response = await dio.get(
        'api/Gallery/getStudentAssignment',
        queryParameters: {'sStudentId': studentId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> updateGalleryViewStatus(String token) async {
    try {
      final response = await dio.get(
        'api/Admin/UpdateGallaryViewStatus',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStudentProject(String token, String classId) async {
    try {
      final response = await dio.get(
        'api/Gallery/FetchProject',
        queryParameters: {'sClassId': classId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> updateProjectViewStatus(String token) async {
    try {
      final response = await dio.get(
        'api/Admin/UpdateProjectViewStatus',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> updateAssignmentViewStatus(String token) async {
    try {
      final response = await dio.get(
        'api/Admin/UpdateAssignmentViewStatus',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStudentAssignmentReport(String token, String classId) async {
    try {
      final response = await dio.get(
        'api/Gallery/FetchAssignmentReportNew',
        queryParameters: {'sClassId': classId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getTransportAnnouncement(String token, String studentId) async {
    try {
      final response = await dio.post(
        'api/admin/FetchTransportAnnouncementForStudent',
        data: {'STUDENT_ID': studentId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> updateAnnouncementViewStatus(String token) async {
    try {
      final response = await dio.get(
        'api/Admin/UpdateAnnouncementViewStatus',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStudentRemarks(String token, String studentId) async {
    try {
      final response = await dio.get(
        'api/Homework/FetchStuRemarks',
        queryParameters: {'sStudentId': studentId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStudentLessonQa(String token, String classId) async {
    try {
      final response = await dio.get(
        'api/Gallery/FetchAssignment',
        queryParameters: {'sClassId': classId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getTransportDetails(String token) async {
    try {
      final response = await dio.get(
        'api/PushNotification/getTransPortDetails',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getVanInfoByStudentId(String token, String studentId) async {
    try {
      final response = await dio.get(
        'api/Admin/FetchVanInfoByStudentId',
        queryParameters: {'sStudentId': studentId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getAnnouncement(String token, String studentId) async {
    try {
      final response = await dio.get(
        'api/Homework/FetchAnnouncement',
        queryParameters: {'sStudentId': studentId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStudentClasses(String token) async {
    try {
      final response = await dio.get(
        'api/Attendance/FetchClass',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getClassWiseStudentAttendance(String token, String date, String classId) async {
    try {
      final response = await dio.get(
        'api/Attendance/FetchClassWiseAttendance',
        queryParameters: {'sDate': date, 'sClassId': classId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> insertStudentAttendance(String token, List<Map<String, dynamic>> attendanceList) async {
    try {
      final response = await dio.post(
        'api/attendance/SaveAbsentClassWise',
        data: attendanceList,
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStaffHomeworks(String token, String date) async {
    try {
      final response = await dio.get(
        'api/PushNotification/getHomeWork', // Based on StaffHomeworkActivity using StudentViewModel.getHomeWorks
        queryParameters: {'sDate': date, 'sStudentId': ''}, // sStudentId is empty for staff in Java code logic
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getClassWiseSubjects(String token, String classId) async {
    try {
      final response = await dio.get(
        'api/Homework/FetchSubjectForClass',
        queryParameters: {'sClassId': classId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> insertClassWiseHomework(String token, Map<String, dynamic> homeworkData) async {
    try {
      final response = await dio.post(
        'api/Homework/SaveHomeWork',
        data: homeworkData,
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }




  Future<Response> getStaffAnnouncements(String token) async {
    try {
      final response = await dio.get(
        'api/Homework/FetchAnnouncement',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStaffCirculars(String token) async {
    try {
      final response = await dio.get(
        'api/Attendance/FetchCircular',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStaffTimetable(String token) async {
    try {
      final response = await dio.get(
        'api/Gallery/FetchStaffTimeTable',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStudentLeaveRequestsForApproval(String token) async {
    try {
      final response = await dio.get(
        'api/Leave/FetchStuLeaveRequestForApproval',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> updateStudentLeaveStatus(String token, Map<String, dynamic> statusData) async {
    try {
      final response = await dio.post(
        'api/Leave/UpdateStuLeaveApproval',
        data: statusData,
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getExamTypes(String token) async {
    try {
      final response = await dio.get(
        'api/Exam/FetchExam',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getExamSubjects(String token, String examId, String classId) async {
    try {
      final response = await dio.get(
        'api/Exam/FetchExamSubjectByClsByExamType',
        queryParameters: {'sExamId': examId, 'sExmClsId': classId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getExamComponents(String token, String classId, String subjectId, String examId) async {
    try {
      final response = await dio.get(
        'api/Exam/FetchExamCompent',
        queryParameters: {
          'sClassId': classId,
          'sSubjectId': subjectId,
          'sExamId': examId,
        },
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStaffStudentMarks(String token, Map<String, dynamic> params) async {
    try {
      final response = await dio.post(
        'api/Exam/FetchStudentMarkByStudentWise',
        data: params,
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getClassWiseStudentAttendanceByDate(String date, String classId, String token) async {
    try {
      final response = await dio.get(
        'api/Attendance/FetchClassWiseStudentAttendanceByDate',
        queryParameters: {'sDate': date, 'sClassId': classId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> insertExamMarks(String token, Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        'api/Exam/InsertStudentSubjectMark',
        data: data,
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> changePassword(String token, String oldPassword, String newPassword) async {
    try {
      final response = await dio.post(
        'api/Auth/ChagnePassword',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'eid': '0',
        },
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getGallery(String token, String classId) async {
    try {
      final response = await dio.get(
        'api/Gallery/FetchGallaryByStudentId',
        queryParameters: {'sClassId': classId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStaffRemarks(String token) async {
    try {
      final response = await dio.get(
        'api/Homework/FetchStaffRemarks',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getRemarksTypes(String token) async {
    try {
      final response = await dio.get(
        'api/Homework/FetchRemarkTypes',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> insertStudentRemarks(String token, List<Map<String, dynamic>> remarks) async {
    try {
      final response = await dio.post(
        'api/Homework/SaveStuRemarks',
        data: remarks,
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> insertAnnouncement(String token, Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        'api/Admin/SaveOrUpdateAnForAdmin',
        data: data,
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getClassAttendanceReport(String token, String date, String classId) async {
    try {
      final response = await dio.get(
        'api/admin/FetchAttendanceReport',
        queryParameters: {'sDate': date, 'sClass': classId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStrengthReport(String token, String classId, String genderId) async {
    try {
      final response = await dio.get(
        'api/Admin/FetchStrengthReport',
        queryParameters: {'sClassId': classId, 'sGenderId': genderId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getGalleryReport(String token, String classId, String fromDate, String toDate) async {
    try {
      final response = await dio.get(
        'api/Admin/FetchGalleryReport',
        queryParameters: {'sClassId': classId, 'sFromDate': fromDate, 'sToDate': toDate},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getAssignmentReport(String token, String classId, String fromDate, String toDate) async {
    try {
      final response = await dio.get(
        'api/Admin/FetchAssignmentReport',
        queryParameters: {'sClassId': classId, 'sFromDate': fromDate, 'sToDate': toDate},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getProjectReport(String token, String classId, String fromDate, String toDate) async {
    try {
      final response = await dio.get(
        'api/Admin/FetchProjectReport',
        queryParameters: {'sClassId': classId, 'sFromDate': fromDate, 'sToDate': toDate},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getAdminClassWiseStudent(String token, String classId) async {
    try {
      final response = await dio.get(
        'api/Admin/FetchClasswiseStudents', // Corrected Endpoint
        queryParameters: {'sClassId': classId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getAdminStudentById(String token, String studentId) async {
    try {
      final response = await dio.get(
        'api/Admin/FetchAdminStudentById',
        queryParameters: {'sStudentId': studentId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getExamType(String token) async {
    try {
      final response = await dio.get(
        'api/Admin/FetchExamEntry',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getExamSubjectsByClassIdByExamType(String token, String examId, String classId) async {
    try {
      final response = await dio.get(
        'api/Admin/FetchExmSubjectByClassForddl',
        queryParameters: {'sExamId': examId, 'sExmClsId': classId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> insertExamMark(String token, Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        'api/Admin/SaveExamCompWiseMark',
        data: data,
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getAdminAnnouncement(String token, String fromDate, String toDate, String classId) async {
    try {
      final response = await dio.get(
        'api/Admin/FetchAnnouncementForAdmin',
        queryParameters: {'sFromDate': fromDate, 'sToDate': toDate, 'sClassId': classId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> insertAdminAnnouncement(String token, Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        'api/Admin/SaveOrUpdateAnForAdmin',
        data: data,
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> insertStaffRemarks(String token, List<Map<String, dynamic>> remarks) async {
    try {
      final response = await dio.post(
        'api/Homework/SaveStaffRemarks',
        data: remarks,
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> insertCircular(String token, List<Map<String, dynamic>> circulars) async {
    try {
      final response = await dio.post(
        'api/Attendance/SaveCircular',
        data: circulars,
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> insertAdminGallery(String token, {
    required String title,
    required String classIds,
    required String fileType, // 1: Image, 2: Video, 3: YouTube URL
    String? filePath,
    String? youtubeUrl,
  }) async {
    try {
      FormData formData = FormData();
      
      if (fileType == '1' || fileType == '2') {
        if (filePath != null) {
          formData.files.add(MapEntry(
            'gn',
            await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
          ));
        }
      }
      
      formData.fields.addAll([
        MapEntry('sID', '0'),
        MapEntry('sURL', youtubeUrl ?? ''),
        MapEntry('sTitle', title),
        MapEntry('sClassId', classIds),
        MapEntry('sFileType', fileType),
      ]);

      final response = await dio.post(
        'api/Admin/PostGallery',
        data: formData,
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> insertAdminProject(String token, {
    required String title,
    required String classIds,
    required String fileType,
    String? filePath,
    String? youtubeUrl,
  }) async {
    try {
      FormData formData = FormData();
      
      if (fileType == '1' || fileType == '2') {
        if (filePath != null) {
          formData.files.add(MapEntry(
            'gn',
            await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
          ));
        }
      }
      
      formData.fields.addAll([
        MapEntry('sID', '0'),
        MapEntry('sURL', youtubeUrl ?? ''),
        MapEntry('sTitle', title),
        MapEntry('sClassId', classIds),
        MapEntry('sFileType', fileType),
      ]);

      final response = await dio.post(
        'api/Admin/PostProject',
        data: formData,
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> insertAdminAssignment(String token, {
    required String title,
    required String classIds,
    required String fileType,
    String? filePath,
    String? youtubeUrl,
  }) async {
    try {
      FormData formData = FormData();
      
      if (fileType == '1' || fileType == '2') {
        if (filePath != null) {
          formData.files.add(MapEntry(
            'gn',
            await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
          ));
        }
      }
      
      formData.fields.addAll([
        MapEntry('sID', '0'),
        MapEntry('sURL', youtubeUrl ?? ''),
        MapEntry('sTitle', title),
        MapEntry('sClassId', classIds),
        MapEntry('sFileType', fileType),
      ]);

      final response = await dio.post(
        'api/Admin/PostAssignment',
        data: formData,
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> requestStaffLeave(String token, Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        'api/PushNotification/postLeaveRequest',
        data: data,
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStaffLeaveRequests(String token) async {
    try {
      final response = await dio.get(
        'api/Leave/FetchStaffLeaveRequests',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> updateStaffLeaveStatus(String token, Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        'api/Leave/UpdateStaffLeaveStatus',
        data: data,
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getPrincipalStaffProfile(String token) async {
    try {
      final response = await dio.get(
        'api/Profiles/FetchStaffProfile',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getAdminClassTimetable(String token, String classId) async {
    try {
      final response = await dio.get(
        'api/Gallery/FetchClassTimeTable',
        queryParameters: {'sClassId': classId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getAdminStaffTimetable(String token, String staffId) async {
    try {
      final response = await dio.get(
        'api/Gallery/FetchStaffTimeTable',
        queryParameters: {'sStaffId': staffId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getPrincipalClasses(String token) async {
    try {
      final response = await dio.get(
        'api/Attendance/FetchClass',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getTrips(String token) async {
    try {
      final response = await dio.get(
        'api/Admin/FetchTrip',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getVanInfo(String token, String tripId) async {
    try {
      final response = await dio.get(
        'api/Admin/FetchVanInfo',
        queryParameters: {'sTripId': tripId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getBoardingPlaces(String token, String vanId) async {
    try {
      final response = await dio.get(
        'api/Admin/FetchBoardingPlaceByVanID',
        queryParameters: {'sVanId': vanId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStudentListByBoardingPlace(String token, String placeId) async {
    try {
      final response = await dio.get(
        'api/Admin/FetchStudentListByBoardingPlace',
        queryParameters: {'sPalceId': placeId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getAdminTransportAnnouncement(String token, Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        'api/Admin/FetchTransportAnnouncement',
        data: data,
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> addTransportAnnouncement(String token, Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        'api/Admin/SaveorUpdateTranAnnouncement',
        data: data,
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStudentExamDetails(String token) async {
    try {
      final response = await dio.get(
        'api/Student/FetchExamDetails',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStudentMarksByStudentWise(String token, Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        'api/Admin/FetchStuSubMark',
        data: data,
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getAdminExamType(String token) async {
    try {
      final response = await dio.get(
        'api/Admin/FetchExmType',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getAdminExamComponents(String token, String classId, String subjectId, String examId) async {
    try {
      final response = await dio.get(
        'api/Admin/FetchExamComp',
        queryParameters: {'sClassId': classId, 'sSubjectId': subjectId, 'sExamId': examId},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getClassWiseFee(String token, String frequencyId, String className) async {
    try {
      final response = await dio.get(
        'api/Admin/FetchClasswiseFeePaid',
        queryParameters: {
          'FREQUENCY_ID': frequencyId,
          'CLASS_NAME': className,
        },
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStudentWiseFee(String token, String frequencyId, String className, String studentIds) async {
    try {
      final response = await dio.get(
        'api/Admin/FetchClasswiseFeePaid',
        queryParameters: {
          'FREQUENCY_ID': frequencyId,
          'CLASS_NAME': className,
          'sStudentIds': studentIds,
        },
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getAdminStudentAssignment(String token, String classIds) async {
    try {
      final response = await dio.get(
        'api/Gallery/FetchAssignmentNew',
        queryParameters: {'sClassId': classIds},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getAdminStudentProject(String token, String classIds) async {
    try {
      final response = await dio.get(
        'api/Gallery/FetchProject',
        queryParameters: {'sClassId': classIds},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getAdminStudentLessonQa(String token, String classIds) async {
    try {
      final response = await dio.get(
        'api/Gallery/FetchAssignment',
        queryParameters: {'sClassId': classIds},
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStaffBirthdays(String token) async {
    try {
      final response = await dio.get(
        'api/Profiles/FetchStaffBirthdays',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getStudentBirthdays(String token) async {
    try {
      final response = await dio.get(
        'api/Profiles/FetchStudentBirthdays',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getAdminStaffList(String token) async {
    try {
      final response = await dio.get(
        'api/Profiles/FetchStaffProfile',
        options: Options(headers: {'ISP': token}),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }
}
