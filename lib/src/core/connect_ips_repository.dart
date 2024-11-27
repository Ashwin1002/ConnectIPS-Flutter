import 'dart:convert';
import 'dart:io';

import 'package:connect_ips_flutter/connect_ips_flutter.dart';

import 'package:http/http.dart' as http;

/// Typedef for the http client used internally.
typedef HttpClient = http.Client;

/// Repository for handling Connect IPS API requests, such as transaction
/// verification and fetching transaction details.
class ConnectIpsRepository {
  /// Creates an instance of [ConnectIpsRepository].
  ///
  /// [client] is an optional parameter to provide a custom [HttpClient].
  ConnectIpsRepository({
    HttpClient? client,
  }) : _client = client ?? HttpClient();

  /// The HTTP client used to make HTTP requests.
  final HttpClient _client;

  /// HTTP header for JSON content-type.
  Map<String, String> get applicationJsonHeader =>
      {'Content-Type': 'application/json'};

  /// HTTP header for x-www-Form-urlcoded content-type.
  Map<String, String> get xformUrlEncodedHeader =>
      {'Content-Type': 'application/x-www-form-urlencoded'};

  /// Constructs the Basic Authentication header using [VerifyTransactionConfig].
  ///
  /// This header is used for authentication in requests that require Basic
  /// Authentication, encoding the username and password in base64.
  ///
  /// Returns a [Map] with the `Authorization` header.
  Map<String, String> _getBasicAuthHeader(VerifyTransactionConfig config) {
    return {
      'Authorization':
          'Basic ${base64.encode(utf8.encode('${config.username}:${config.password}'))}'
    };
  }

  /// Retrieves transaction details from Connect IPS.
  ///
  /// Accepts [paymentConfig] and [verifyConfig] to configure the transaction
  /// request and authorization headers.
  ///
  /// Returns a [Future] of [HttpResponse], which may contain success or failure
  /// information based on the transaction outcome.
  Future<HttpResponse> getTransactionDetail(
    CIPSConfig paymentConfig,
    VerifyTransactionConfig verifyConfig,
  ) {
    // Construct the message for signing
    final message =
        'MERCHANTID=${paymentConfig.merchantID},APPID=${paymentConfig.appID},REFERENCEID=${paymentConfig.transactionID},TXNAMT=${paymentConfig.transactionAmount}';

    return _handleExceptions(
      () async {
        // Set up the URI for the transaction detail endpoint
        final uri = Uri.parse(
          'https://${paymentConfig.baseUrl}/connectipswebws/api/creditor/gettxndetail',
        );

        // Construct the request body
        var body = {
          "merchantId": paymentConfig.merchantID,
          "appId": paymentConfig.appID,
          "referenceId": paymentConfig.transactionID,
          "txnAmt": paymentConfig.transactionAmount,
          'TOKEN': await getSignedToken(message, paymentConfig.creditorKey),
        };

        // Make the POST request
        final response = await _client.post(
          uri,
          headers: {
            ...applicationJsonHeader,
            ..._getBasicAuthHeader(verifyConfig),
          },
          body: body,
        );

        // Parse and evaluate response
        final statusCode = response.statusCode;
        final responseData = jsonDecode(response.body);

        if (_isStatusValid(statusCode)) {
          return HttpResponse.success(
            data: responseData,
            statusCode: statusCode,
          );
        }
        return HttpResponse.failure(
          data: responseData,
          statusCode: statusCode,
        );
      },
    );
  }

  /// Verifies the transaction status using Connect IPS.
  ///
  /// Accepts [paymentConfig] and [verifyConfig] to set up the transaction
  /// request and authorization headers.
  ///
  /// Returns a [Future] of [HttpResponse], containing success or failure data.
  Future<HttpResponse> verifyTransaction(
    CIPSConfig paymentConfig,
    VerifyTransactionConfig verifyConfig,
  ) {
    // Create the message for signing
    final message = '''
        MERCHANTID=${paymentConfig.merchantID},APPID=${paymentConfig.appID},REFERENCEID=${paymentConfig.transactionID},TXNAMT=${paymentConfig.transactionAmount}
    ''';

    return _handleExceptions(
      () async {
        // Configure the URI for transaction validation endpoint
        final uri = Uri.parse(
            'https://${paymentConfig.baseUrl}/connectipswebws/api/creditor/validatetxn');

        // Make the POST request
        final response = await _client.post(
          uri,
          headers: {
            ...applicationJsonHeader,
            ..._getBasicAuthHeader(verifyConfig),
          },
          body: {
            'merchantId': paymentConfig.merchantID,
            'appId': paymentConfig.appID,
            'referenceId': paymentConfig.transactionID,
            'txnAmt': paymentConfig.transactionAmount,
            'token':
                await getSignedToken(message.trim(), paymentConfig.creditorKey),
          },
        );

        // Parse and evaluate response
        final statusCode = response.statusCode;
        final responseData = jsonDecode(response.body);

        if (_isStatusValid(statusCode)) {
          return HttpResponse.success(
            data: responseData,
            statusCode: statusCode,
          );
        }
        return HttpResponse.failure(
          data: responseData,
          statusCode: statusCode,
        );
      },
    );
  }

  /// Checks if the status code is within the successful range.
  ///
  /// Returns `true` if the [statusCode] is between 200 and 299.
  bool _isStatusValid(int statusCode) => statusCode >= 200 && statusCode < 300;

  /// Handles exceptions and returns a [HttpResponse] in case of errors.
  ///
  /// Wraps [caller] function execution in a try-catch to capture various
  /// exceptions that may occur during HTTP requests, converting them into
  /// appropriate [HttpResponse] failures.
  Future<HttpResponse> _handleExceptions(
    Future<HttpResponse> Function() caller,
  ) async {
    try {
      return await caller();
    } on HttpException catch (e, s) {
      return HttpResponse.exception(
        message: e.message,
        code: 0,
        stackTrace: s,
        detail: e.uri,
      );
    } on http.ClientException catch (e, s) {
      return HttpResponse.exception(
        message: e.message,
        code: 0,
        stackTrace: s,
        detail: e.uri,
      );
    } on SocketException catch (e, s) {
      return HttpResponse.exception(
        message: e.message,
        code: e.osError?.errorCode ?? 0,
        stackTrace: s,
        detail: e.osError?.message,
        isSocketException: true,
      );
    } on FormatException catch (e, s) {
      return HttpResponse.exception(
        message: e.message,
        code: 0,
        stackTrace: s,
        detail: e.source,
      );
    } catch (e, s) {
      return HttpResponse.exception(
        message: e.toString(),
        code: 0,
        stackTrace: s,
      );
    }
  }
}
