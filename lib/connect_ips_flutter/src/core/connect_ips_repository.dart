import 'dart:convert';
import 'dart:io';

import 'package:connect_ips_flutter/connect_ips_flutter/src/core/http_response.dart';
import 'package:connect_ips_flutter/connect_ips_flutter/src/model/cips_config.dart';
import 'package:connect_ips_flutter/connect_ips_flutter/src/utils/generate_token.dart';
import 'package:http/http.dart' as http;

/// Typedef for http.Client that is used internally.
typedef HttpClient = http.Client;

class ConnectIpsRepository {
  /// The HTTP client used to make HTTP requests.
  ConnectIpsRepository({
    HttpClient? client,
  }) : _client = client ?? HttpClient();

  final HttpClient _client;

  Map<String, String> get applicationJsonHeader =>
      {'Content-Type': 'application/json'};

  /// get basic auth header for request
  Map<String, String> _getBasicAuthHeader(VerifyTransactionConfig config) {
    return {
      'Authorization':
          'Basic ${base64.encode(utf8.encode('${config.username}:${config.password}'))}'
    };
  }

  Future<HttpResponse> getTransactionDetail(
    CIPSConfig paymentConfig,
    VerifyTransactionConfig verifyConfig,
  ) {
    final message =
        'MERCHANTID=${paymentConfig.merchantID},APPID=${paymentConfig.appID},REFERENCEID=${paymentConfig.transactionID},TXNAMT=${paymentConfig.transactionAmount}';

    return _handleExceptions(
      () async {
        final uri = Uri.parse(
          'https://${paymentConfig.baseUrl}/connectipswebws/api/creditor/gettxndetail',
        );

        var body = {
          "merchantId": paymentConfig.merchantID,
          "appId": paymentConfig.appID,
          "referenceId": paymentConfig.transactionID,
          "txnAmt": paymentConfig.transactionAmount,
          'TOKEN': await getSignedToken(message, paymentConfig.creditorPath),
        };
        final response = await _client.post(
          uri,
          headers: {
            ...applicationJsonHeader,
            ..._getBasicAuthHeader(verifyConfig),
          },
          body: body,
        );

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

  Future<HttpResponse> verifyTransaction(
    CIPSConfig paymentConfig,
    VerifyTransactionConfig verifyConfig,
  ) {
    final message = '''
        MERCHANTID=${paymentConfig.merchantID},APPID=${paymentConfig.appID},REFERENCEID=${paymentConfig.transactionID},TXNAMT=${paymentConfig.transactionAmount}
    ''';

    return _handleExceptions(
      () async {
        final uri = Uri.parse(
            'https://${paymentConfig.baseUrl}/connectipswebws/api/creditor/validatetxn');
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
            'token': await getSignedToken(
                message.trim(), paymentConfig.creditorPath),
          },
        );

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

  bool _isStatusValid(int statusCode) => statusCode >= 200 && statusCode < 300;

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
