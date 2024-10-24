import 'dart:convert';
import 'dart:io';

import 'package:connect_ips_flutter/connect_ips_flutter/src/core/http_response.dart';
import 'package:connect_ips_flutter/connect_ips_flutter/src/model/cips_config.dart';
import 'package:connect_ips_flutter/connect_ips_flutter/src/utils/generate_token.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// Typedef for http.Client that is used internally.
typedef HttpClient = http.Client;

class ConnectIpsClient {
  /// The HTTP client used to make HTTP requests.
  ConnectIpsClient({
    HttpClient? client,
  }) : _client = client ?? HttpClient();

  final HttpClient _client;

  Future<HttpResponse> initiatePayment(
    CIPSConfig paymentConfig,
  ) {
    final txnDate = DateFormat('DD-MM-YYYY')
        .format(paymentConfig.transactionDate ?? DateTime.now().toUtc());
    final message = '''
        MERCHANTID=${paymentConfig.merchantID},APPID=${paymentConfig.appID},APPNAME=${paymentConfig.appName},TXNID=${paymentConfig.transactionID},TXNDATE=$txnDate,TXNCRNCY=${paymentConfig.transactionCurrency},TXNAMT=${paymentConfig.transactionAmount},REFERENCEID=${paymentConfig.refrerenceID},REMARKS=${paymentConfig.remarks},PARTICULARS=${paymentConfig.particulars},TOKEN=TOKEN
    ''';
    return _handleExceptions(
      () async {
        final uri = Uri.parse(
            'https://${paymentConfig.baseUrl}/connectipswebgw/loginpage');
        final response = await _client.post(
          uri,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'MERCHANTID': paymentConfig.merchantID,
            'APPID': paymentConfig.appID,
            'APPNAME': paymentConfig.appName,
            'TXNID': paymentConfig.transactionID,
            'TXNDATE': txnDate,
            'TXNCRNCY': paymentConfig.transactionCurrency,
            'TXNAMT': paymentConfig.transactionAmount,
            'REFERENCEID': paymentConfig.refrerenceID,
            'REMARKS': paymentConfig.remarks,
            'PARTICULARS': paymentConfig.particulars,
            'TOKEN': await getSignedToken(message, paymentConfig.creditorPath),
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

  Future<HttpResponse> verifyTransaction(
    CIPSConfig paymentConfig,
    VerifyTransactionConfig verifyConfig,
  ) {
    final message = '''
        MERCHANTID=${paymentConfig.merchantID},APPID=${paymentConfig.appID},REFERENCEID=${paymentConfig.transactionID},TXNAMT=${paymentConfig.transactionAmount}
    ''';

    String basicAuth =
        'Basic ${base64.encode(utf8.encode('${verifyConfig.username}:${verifyConfig.password}'))}';
    return _handleExceptions(
      () async {
        final uri = Uri.parse(
            'https://${paymentConfig.baseUrl}/connectipswebws/api/creditor/validatetxn');
        final response = await _client.post(
          uri,
          headers: {'Authorization': basicAuth},
          body: {
            'merchantId': paymentConfig.merchantID,
            'appId': paymentConfig.appID,
            'referenceId': paymentConfig.transactionID,
            'txnAmt': paymentConfig.transactionAmount,
            'token': await getSignedToken(message, paymentConfig.creditorPath),
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
