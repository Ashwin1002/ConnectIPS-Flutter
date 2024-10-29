import 'dart:async';

import 'package:connect_ips_flutter/connect_ips_flutter.dart';
import 'package:flutter/material.dart';

/// Creating an instance of [ConnectIPSRepository] to handle network requests.
final repository = ConnectIpsRepository(client: HttpClient());

/// Enum representing different payment events triggered during Connect IPS usage.
enum PaymentEvent {
  /// Event triggered when the user cancels the payment, typically by pressing back
  /// or by pressing the `Return to Creditor Site` button.
  paymentCancelled,

  /// Event triggered when there is a failure due to no or weak internet connection.
  noInternetFailure,

  /// Event triggered when there is an HTTP error during the verification of
  /// payment status.
  paymentLookupfailure,

  /// Default unknown event for any unspecified errors.
  unKnown,
}

/// Callback type for handling successful or failed payment results.
///
/// [paymentResult] provides details of the payment, and [connectIps] provides
/// the instance of the Connect IPS handler.
typedef OnPaymentResult = FutureOr<void> Function(
  PaymentResult paymentResult,
  ConnectIps connectIps,
);

/// Callback type for handling exceptions that occur during payment processing.
///
/// [statusCode] and [description] provide details of the error, [event] indicates
/// the type of failure, and [needsPaymentConfirmation] shows if confirmation is required.
typedef OnMessage = FutureOr<void> Function(
  ConnectIps connectIPS, {
  int? statusCode,
  Object? description,
  PaymentEvent? event,
  bool? needsPaymentConfirmation,
});

/// Callback for when the user is redirected to the `return_url`.
///
/// Optionally provides [payment] details if available.
typedef OnReturn = FutureOr<void> Function([PaymentResult? payment]);

/// Manages Connect IPS payment processing, including initiating payments,
/// handling exceptions, and closing the web view.
class ConnectIps {
  /// Private constructor for [ConnectIps].
  const ConnectIps._({
    required CIPSConfig config,
    required VerifyTransactionConfig? verifyConfig,
    required this.onMessage,
    required this.onPaymentResult,
    this.onReturn,
  })  : _payConfig = config,
        _verifyConfig = verifyConfig;

  /// Configuration for initiating Connect IPS payment.
  final CIPSConfig _payConfig;

  /// Optional configuration for payment verification.
  final VerifyTransactionConfig? _verifyConfig;

  /// Callback triggered upon completion of a payment (either successful or failed).
  final OnPaymentResult onPaymentResult;

  /// Callback for handling exceptions that occur during the payment process.
  final OnMessage onMessage;

  /// Optional callback for when the user is redirected to the specified `return_url`.
  final OnReturn? onReturn;

  /// Factory constructor for creating a [ConnectIps] instance.
  ///
  /// Requires [config] for payment setup, [onMessage] for handling exceptions,
  /// and [onPaymentResult] for payment result handling. Optionally accepts
  /// [verifyConfig] for verification and [onReturn] for handling redirection.
  factory ConnectIps({
    required CIPSConfig config,
    VerifyTransactionConfig? verifyConfig,
    required OnMessage onMessage,
    required OnPaymentResult onPaymentResult,
    OnReturn? onReturn,
  }) =>
      ConnectIps._(
        config: config,
        onMessage: onMessage,
        onReturn: onReturn,
        onPaymentResult: onPaymentResult,
        verifyConfig: verifyConfig,
      );

  /// Retrieves the payment configuration for initiating Connect IPS payment.
  CIPSConfig get payConfig => _payConfig;

  /// Retrieves the verification configuration for verifying Connect IPS payment.
  VerifyTransactionConfig? get verifyConfig => _verifyConfig;

  /// Boolean indicator to show if the web view has already been closed.
  ///
  /// Prevents multiple pop events, helping to avoid redundancy in closing the web view.
  static bool hasPopped = false;

  /// Opens the web view to initiate payment with Connect IPS.
  ///
  /// Accepts [context] from Flutter to handle navigation to the web view.
  void open(BuildContext context) {
    hasPopped = false;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ConnectIPSWebView(
            connectIPS: this,
          );
        },
      ),
    );
  }

  /// Closes the web view if it has not been closed already.
  ///
  /// [context] is used to handle navigation back from the web view.
  void close(BuildContext context) {
    if (!hasPopped) {
      hasPopped = true;
      Navigator.pop(context);
    }
  }

  /// Initiates payment verification and handles results or exceptions.
  ///
  /// [onPaymentResult] is called upon successful or failed verification.
  /// [onMessage] is triggered for handling any exceptions during the process.
  Future<void> onPaymentVerification({
    required OnPaymentResult onPaymentResult,
    required OnMessage onMessage,
  }) async {
    // Check if verification configuration is provided
    if (verifyConfig == null) {
      return onMessage(
        this,
        description: 'Basic Authentication is not provided',
        event: PaymentEvent.paymentCancelled,
      );
    }
    try {
      // Attempt to verify the transaction
      final response = await repository.verifyTransaction(
        payConfig,
        verifyConfig!,
      );

      // Parse the result from the response
      final result = PaymentResult.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Trigger the optional return callback with the result
      await onReturn?.call(result);

      // Trigger the payment result callback with the parsed result
      return onPaymentResult(result, this);
    } on ExceptionHttpResponse catch (e) {
      // Handle HTTP exceptions by invoking the onMessage callback
      return onMessage(
        this,
        statusCode: e.statusCode,
        description: e.detail,
        event: PaymentEvent.noInternetFailure,
        needsPaymentConfirmation: true,
      );
    } on FailureHttpResponse catch (e) {
      // Handle failure responses by invoking the onMessage callback
      return onMessage(
        this,
        statusCode: e.statusCode,
        description: e.data,
        event: PaymentEvent.paymentLookupfailure,
        needsPaymentConfirmation: false,
      );
    }
  }
}
