class RemarkType {
  final String remarkId;
  final String remarkType;

  RemarkType({
    required this.remarkId,
    required this.remarkType,
  });

  factory RemarkType.fromJson(Map<String, dynamic> json) {
    return RemarkType(
      remarkId: json['REMARK_ID']?.toString() ?? '',
      remarkType: json['REMARK_TYPE']?.toString() ?? '',
    );
  }
}
