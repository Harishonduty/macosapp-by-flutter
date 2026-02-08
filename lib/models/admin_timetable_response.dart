class AdminTimetableResponse {
  final bool status;
  final String message;
  final TimetableResult? result;

  AdminTimetableResponse({
    required this.status,
    required this.message,
    this.result,
  });

  factory AdminTimetableResponse.fromJson(Map<String, dynamic> json) {
    return AdminTimetableResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      result: json['result'] != null ? TimetableResult.fromJson(json['result']) : null,
    );
  }
}

class TimetableResult {
  final String path;

  TimetableResult({required this.path});

  factory TimetableResult.fromJson(Map<String, dynamic> json) {
    return TimetableResult(
      path: json['PATH']?.toString() ?? '',
    );
  }
}
