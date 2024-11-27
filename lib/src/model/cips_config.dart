import 'dart:async';

/// Configuration class for initiating a payment through Connect IPS (CIPS).
///
/// This class holds all the necessary information required for setting up
/// and initiating a payment transaction either in Live or Staging mode.
class CIPSConfig {
  /// Constructor for configuring the payment settings in **Live Mode**.
  ///
  /// Parameters:
  /// - [baseUrl]: Base URL for the live environment.
  /// - [creditorKey]: the digital certificate used for signing token.
  /// - [merchantID]: Unique identifier for the merchant, provided by NCHL.
  /// - [appID]: Application ID provided by NCHL after registration.
  /// - [appName]: Name of the merchant's application.
  /// - [transactionID]: Unique ID for the transaction.
  /// - [transactionDate]: Date of the transaction in the format "DD-MM-YYYY".
  /// - [transactionCurrency]: Currency for the transaction (default: "NPR").
  /// - [transactionAmount]: Amount for the transaction in paisa.
  /// - [refrerenceID]: Optional reference ID for additional transaction info.
  /// - [remarks]: Optional remarks related to the transaction.
  /// - [particulars]: Optional additional remarks about the transaction.
  const CIPSConfig.live({
    required this.baseUrl,
    required this.creditorKey,
    required this.merchantID,
    required this.appID,
    required this.appName,
    required this.transactionID,
    required this.successUrl,
    required this.failureUrl,
    this.transactionDate,
    this.transactionCurrency = 'NPR',
    required this.transactionAmount,
    this.refrerenceID = 'REF-001',
    this.remarks = 'REM-001',
    this.particulars = 'PAR-001',
  });

  /// Constructor for configuring the payment settings in **Staging Mode**.
  ///
  /// This sets up a default `baseUrl` for the staging environment.
  /// - [creditorKey]: the digital certificate used for signing token.
  /// - [merchantID]: Unique identifier for the merchant, provided by NCHL.
  /// - [appID]: Application ID provided by NCHL after registration.
  /// - [appName]: Name of the merchant's application.
  /// - [transactionID]: Unique ID for the transaction.
  /// - [transactionDate]: Date of the transaction in the format "DD-MM-YYYY".
  /// - [transactionCurrency]: Currency for the transaction (default: "NPR").
  /// - [transactionAmount]: Amount for the transaction in paisa.
  /// - [refrerenceID]: Optional reference ID for additional transaction info.
  /// - [remarks]: Optional remarks related to the transaction.
  /// - [particulars]: Optional additional remarks about the transaction.
  const CIPSConfig.stag({
    required this.creditorKey,
    required this.merchantID,
    required this.appID,
    required this.appName,
    required this.transactionID,
    required this.successUrl,
    required this.failureUrl,
    this.transactionDate,
    this.transactionCurrency = 'NPR',
    required this.transactionAmount,
    this.refrerenceID = 'REF-001',
    this.remarks = 'REM-001',
    this.particulars = 'PAR-001',
  }) : baseUrl = 'uat.connectips.com';

  /// Base URL for initiating payment.
  /// For live mode, this should be the production URL provided by NCHL.
  /// For staging mode, it defaults to 'uat.connectips.com'.
  final String baseUrl;

  /// Creditor key usually requested from backend/cloud storage
  ///  This certificate is used to sign the transaction request.
  final FutureOr<String> Function() creditorKey;

  /// The success url set which is redirected after transaction success
  final String successUrl;

  /// The failure url set which is redirected after transaction failure
  final String failureUrl;

  /// Unique merchant identifier provided by NCHL upon registration.
  /// This ID should be up to 20 characters.
  final int merchantID;

  /// Application ID assigned by NCHL for identifying the merchant's application.
  /// This ID should be up to 20 characters.
  final String appID;

  /// Name of the application used for identifying the merchant.
  /// This name should be up to 30 characters.
  final String appName;

  /// Unique identifier for each transaction.
  /// It must be unique for each payment request.
  /// This ID should be up to 20 characters.
  final String transactionID;

  /// Date when the transaction originates, in "DD-MM-YYYY" format.
  final DateTime? transactionDate;

  /// Currency code for the transaction.
  /// Default is "NPR" (Nepalese Rupee).
  final String transactionCurrency;

  /// Amount of the transaction, in paisa.
  /// Example: For NPR 100, the value should be `10000`.
  final int transactionAmount;

  /// Optional reference ID for the transaction.
  /// This can hold additional information about the transaction.
  /// Default value is 'REF-001' and it should be up to 20 characters.
  final String refrerenceID;

  /// Optional remarks related to the transaction.
  /// Default value is 'REM-001' and it should be up to 50 characters.
  final String remarks;

  /// Optional additional remarks for the transaction.
  /// This can hold up to 100 characters.
  final String particulars;

  /// Equality operator to compare two [CIPSConfig] instances.
  /// Returns `true` if all properties match.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CIPSConfig &&
        other.baseUrl == baseUrl &&
        other.creditorKey == creditorKey &&
        other.successUrl == successUrl &&
        other.failureUrl == failureUrl &&
        other.merchantID == merchantID &&
        other.appID == appID &&
        other.appName == appName &&
        other.transactionID == transactionID &&
        other.transactionDate == transactionDate &&
        other.transactionCurrency == transactionCurrency &&
        other.transactionAmount == transactionAmount &&
        other.refrerenceID == refrerenceID &&
        other.remarks == remarks &&
        other.particulars == particulars;
  }

  /// Generates a hash code for the [CIPSConfig] instance.
  /// Used for optimizing comparisons and storing in collections.
  @override
  int get hashCode {
    return baseUrl.hashCode ^
        creditorKey.hashCode ^
        successUrl.hashCode ^
        failureUrl.hashCode ^
        merchantID.hashCode ^
        appID.hashCode ^
        appName.hashCode ^
        transactionID.hashCode ^
        transactionDate.hashCode ^
        transactionCurrency.hashCode ^
        transactionAmount.hashCode ^
        refrerenceID.hashCode ^
        remarks.hashCode ^
        particulars.hashCode;
  }
}
