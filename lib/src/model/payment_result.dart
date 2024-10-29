/// Represents the result of a payment transaction processed through Connect IPS.
///
/// This class encapsulates the transaction details,
/// including merchant and app IDs,
/// transaction reference, amount, status, and a
/// descriptive status message.
/// It also provides utility methods for JSON serialization
/// and to convert the transaction amount from paisa to rupees.
class PaymentResult {
  /// Unique identifier for the merchant involved in the transaction.
  final int merchantID;

  /// Identifier for the application processing the transaction.
  final String appID;

  /// Unique identifier for the transaction, provided by Connect IPS.
  final String referenceID;

  /// Transaction amount in paisa (smallest currency unit).
  final int txnAmount;

  /// Encrypted token using SHA-256 with RSA
  final String? token;

  /// Status of the transaction, e.g., "success" or "failure".
  final String status;

  /// Description of the transaction status, providing more details.
  final String statusDesc;

  /// Constructor for creating a [PaymentResult] instance.
  ///
  /// Requires [merchantID], [appID], [referenceID], [txnAmount], [status], and [statusDesc].
  /// The [token] is optional.
  const PaymentResult({
    required this.merchantID,
    required this.appID,
    required this.referenceID,
    required this.txnAmount,
    this.token,
    required this.status,
    required this.statusDesc,
  });

  /// Creates a [PaymentResult] instance from a JSON map.
  ///
  /// This factory constructor expects a JSON map with keys matching the class properties.
  /// If a key is missing, default values are provided.
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

  /// Converts the [PaymentResult] instance to a JSON map.
  ///
  /// This method serializes the instance properties into a JSON-compatible map,
  /// making it suitable for network transmission or data storage.
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

  /// Helper getter to convert the transaction amount from paisa to rupees.
  ///
  /// Since `txnAmount` is stored in paisa, this getter returns the amount
  /// in rupees by dividing by 100.
  double get txnAmountInRupees => txnAmount / 100;
}
