class FeeReceipt {
  final String name;
  final String frequencyName;
  final String amount;
  final String paid;
  final String paymentDate;
  final String balance;
  final String status;
  final String className;

  FeeReceipt({
    required this.name,
    required this.frequencyName,
    required this.amount,
    required this.paid,
    required this.paymentDate,
    required this.balance,
    required this.status,
    required this.className,
  });

  factory FeeReceipt.fromJson(Map<String, dynamic> json) {
    return FeeReceipt(
      name: json['NAME']?.toString() ?? '',
      frequencyName: json['FREQUENCY_NAM']?.toString() ?? '',
      amount: json['AMOUNT']?.toString() ?? '',
      paid: json['PAID']?.toString() ?? '',
      paymentDate: json['PAYMENT_DATE']?.toString() ?? '',
      balance: json['BALANCE']?.toString() ?? '',
      status: json['STATUS']?.toString() ?? '',
      className: json['CLASS_NAME']?.toString() ?? '',
    );
  }
}
