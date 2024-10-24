class PaymentResult {
  final int merchantID;
  final String appID;

  /// transaction ID
  final String referenceID;

  /// transaction amount in paisa
  final int txnAmount;
  final String? token;
  final String status;
  final String statusDesc;

  const PaymentResult({
    required this.merchantID,
    required this.appID,
    required this.referenceID,
    required this.txnAmount,
    this.token,
    required this.status,
    required this.statusDesc,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      merchantID: json['merchantId'] ?? 0,
      appID: json['appId'] ?? '',
      referenceID: json['referenceId'] ?? '',
      txnAmount: json['txnAmt'] ?? 0,
      token: json['token'],
      status: json['status'] ?? '',
      statusDesc: json['statusDesc'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchantId': merchantID,
      'appId': appID,
      'referenceId': referenceID,
      'txnAmt': txnAmount,
      'token': token,
      'status': status,
      'statusDesc': statusDesc,
    };
  }

  /// helper getter to get txn amount in rupees
  double get txnAmountInRupees => txnAmount * 100;
}
