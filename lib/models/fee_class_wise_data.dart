class FeeClassWiseData {
  final String? sid;
  final String? name;
  final String? frequencyName;
  final String? amount;
  final String? paid;
  final String? paymentDate;
  final String? balance;
  final String? status;
  final String? className;
  final String? studentId;
  final String? firstName;
  final String? studentRegisterNumber;
  final String? credit;
  final String? discount;
  final String? debit;
  final String? frequencyId;

  FeeClassWiseData({
    this.sid,
    this.name,
    this.frequencyName,
    this.amount,
    this.paid,
    this.paymentDate,
    this.balance,
    this.status,
    this.className,
    this.studentId,
    this.firstName,
    this.studentRegisterNumber,
    this.credit,
    this.discount,
    this.debit,
    this.frequencyId,
  });

  factory FeeClassWiseData.fromJson(Map<String, dynamic> json) {
    return FeeClassWiseData(
      sid: json['SID']?.toString(),
      name: json['NAME']?.toString(),
      frequencyName: json['FREQUENCY_NAME']?.toString(),
      amount: json['AMOUNT']?.toString(),
      paid: json['PAID']?.toString(),
      paymentDate: json['PAYMENT_DATE']?.toString(),
      balance: json['BALANCE']?.toString(),
      status: json['STATUS']?.toString(),
      className: json['CLASS_NAME']?.toString(),
      studentId: json['STUDENT_ID']?.toString(),
      firstName: json['FIRST_NAME']?.toString(),
      studentRegisterNumber: json['STUDENT_REGISTER_NUMBER']?.toString(),
      credit: json['CREDIT']?.toString(),
      discount: json['DISCOUNT']?.toString(),
      debit: json['DEBIT']?.toString(),
      frequencyId: json['FREQUENCY_ID']?.toString(),
    );
  }
}
