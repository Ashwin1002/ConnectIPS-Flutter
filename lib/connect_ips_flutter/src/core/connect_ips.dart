import 'dart:async';

import 'package:connect_ips_flutter/connect_ips_flutter/src/core/connect_ips_repository.dart';
import 'package:connect_ips_flutter/connect_ips_flutter/src/core/http_response.dart';
import 'package:connect_ips_flutter/connect_ips_flutter/src/model/cips_config.dart';
import 'package:connect_ips_flutter/connect_ips_flutter/src/model/payment_result.dart';
import 'package:connect_ips_flutter/connect_ips_flutter/src/widgets/cips_webview.dart';
import 'package:flutter/material.dart';

final repository = ConnectIpsRepository(client: HttpClient());

/// Events when connect IPS is initiated
enum PaymentEvent {
  /// When user cancels the payment, usually by pressing back or
  /// pressing `Return to Creditor Site` Button.
  paymentCancelled,

  /// When there is exception because of weak/no internet connection
  noInternetFailure,

  /// Event for when there's a HTTP failure when making a network call
  /// for verifying payment status.
  paymentLookupfailure,

  /// Default Event
  unKnown,
}

/// Callback for when a successful or failed payment result is obtained.
typedef OnPaymentResult = FutureOr<void> Function(
  PaymentResult paymentResult,
  ConnectIps connectIps,
);

/// Callback for when any exceptions occur.
typedef OnMessage = FutureOr<void> Function(
  ConnectIps connectIPS, {
  int? statusCode,
  Object? description,
  PaymentEvent? event,
  bool? needsPaymentConfirmation,
});

/// Callback for when user is redirected to `return_url`.
typedef OnReturn = FutureOr<void> Function([PaymentResult? payment]);

class ConnectIps {
  const ConnectIps._({
    required CIPSConfig config,
    required VerifyTransactionConfig? verifyConfig,
    required this.onMessage,
    required this.onPaymentResult,
    this.onReturn,
  })  : _payConfig = config,
        _verifyConfig = verifyConfig;

  final CIPSConfig _payConfig;

  final VerifyTransactionConfig? _verifyConfig;

  /// A callback which is to be triggered when any payment is made.
  final OnPaymentResult onPaymentResult;

  /// Callback for when any exceptions occur.
  final OnMessage onMessage;

  /// Callback for when user is redirected to `return_url`.
  final OnReturn? onReturn;

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

  /// Payment Config for initiating connect ips payment
  CIPSConfig get payConfig => _payConfig;

  /// Payment Config for initiating connect ips payment
  VerifyTransactionConfig? get verifyConfig => _verifyConfig;

  /// Helper boolean value to indicate if the webpage has been popped already to avoid multiple pops.
  ///
  /// Avoid using it outside of this library.
  static bool hasPopped = false;

  /// Method to load webview to be able to make payment.
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

  /// Helper method to close the webview.
  void close(BuildContext context) {
    if (!hasPopped) {
      hasPopped = true;
      Navigator.pop(context);
    }
  }

  Future<void> onPaymentVerification({
    required OnPaymentResult onPaymentResult,
    required OnMessage onMessage,
  }) async {
    if (verifyConfig == null) {
      return onMessage(
        this,
        description: 'Basic Authentication is not provided',
        event: PaymentEvent.paymentCancelled,
      );
    }
    try {
      final response = await repository.verifyTransaction(
        payConfig,
        verifyConfig!,
      );

      final result = PaymentResult.fromJson(
        response.data as Map<String, dynamic>,
      );

      await onReturn?.call(result);

      return onPaymentResult(result, this);
    } on ExceptionHttpResponse catch (e) {
      return onMessage(
        this,
        statusCode: e.statusCode,
        description: e.detail,
        event: PaymentEvent.noInternetFailure,
        needsPaymentConfirmation: true,
      );
    } on FailureHttpResponse catch (e) {
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
