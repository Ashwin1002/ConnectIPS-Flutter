import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:connect_ips_flutter/src/constants/app_texts.dart';
import 'package:connect_ips_flutter/src/core/connect_ips.dart';
import 'package:connect_ips_flutter/src/model/payment_result.dart';
import 'package:connect_ips_flutter/src/utils/connection_checker.dart';
import 'package:connect_ips_flutter/src/utils/generate_token.dart';
import 'package:connect_ips_flutter/src/widgets/pop_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart';

/// A widget for displaying the Connect IPS payment web view.
///
/// This widget opens a web view for initiating a payment process with Connect IPS.
/// It also handles various states like internet connectivity, payment success or failure,
/// and displays appropriate messages to the user.
class ConnectIPSWebView extends StatefulWidget {
  /// Default constructor of Connect IPS webview
  ///
  /// Params:
  ///
  /// [ConnectIps] instance of connect ips service
  const ConnectIPSWebView({
    super.key,
    required this.connectIPS,
  });

  /// Instance of [ConnectIps] containing payment configuration.
  final ConnectIps connectIPS;

  @override
  State<ConnectIPSWebView> createState() => _ConnectIPSWebViewState();
}

class _ConnectIPSWebViewState extends State<ConnectIPSWebView> {
  /// Completer for controlling the web view instance.
  final controllerCompleter = Completer<InAppWebViewController>();

  /// Controls the visibility of the progress indicator.
  final showLinearProgressIndicator = ValueNotifier<bool>(true);

  /// Byte data of the HTTP body to be sent in the payment request.
  late Uint8List bodyBytes;

  @override
  void initState() {
    super.initState();
    _getBodyBytes();
  }

  /// Asynchronously retrieves and encodes the HTTP body for the payment request.
  Future<void> _getBodyBytes() async {
    final paymentConfig = widget.connectIPS.payConfig;

    final txnDate = DateFormat('dd-MM-yyyy')
        .format(paymentConfig.transactionDate ?? DateTime.now().toUtc());

    final message = '''
        MERCHANTID=${paymentConfig.merchantID},APPID=${paymentConfig.appID},APPNAME=${paymentConfig.appName},TXNID=${paymentConfig.transactionID},TXNDATE=$txnDate,TXNCRNCY=${paymentConfig.transactionCurrency},TXNAMT=${paymentConfig.transactionAmount},REFERENCEID=${paymentConfig.refrerenceID},REMARKS=${paymentConfig.remarks},PARTICULARS=${paymentConfig.particulars},TOKEN=TOKEN
    ''';

    final body = {
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
      'TOKEN': await getSignedToken(message.trim(), paymentConfig.creditorPath),
    };

    log('message initial => $message');
    log('body => $body');

    bodyBytes = await convertBodyToUint8List(body);
  }

  @override
  Widget build(BuildContext context) {
    final customBuilder = widget.connectIPS.customBuilder;
    return Scaffold(
      appBar: customBuilder?.appBar ??
          AppBar(
            title: const Text(kPayWithCIPS),
            actions: [
              IconButton(
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
              )
            ],
          ),
      body: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: showLinearProgressIndicator,
            builder: (_, showLoader, __) {
              return showLoader
                  ? customBuilder?.loadingIndicator ??
                      const LinearProgressIndicator()
                  : const SizedBox.shrink();
            },
          ),
          Expanded(
            child: SafeArea(
              child: StreamBuilder<InternetStatus>(
                stream: connectivityUtil.internetConnectionListenableStatus,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  final connectionStatus = snapshot.data!;

                  switch (connectionStatus) {
                    case InternetStatus.connected:
                      return _ConnectIPSWebViewClient(
                        showLinearProgressIndicator:
                            showLinearProgressIndicator,
                        webViewControllerCompleter: controllerCompleter,
                        body: bodyBytes,
                      );
                    case InternetStatus.disconnected:
                      Future.microtask(
                        () => showLinearProgressIndicator.value = false,
                      );
                      return customBuilder?.errorBuilder?.call(
                            context,
                            kNoInternetConnection,
                            kNoInternetConnectionMessage,
                          ) ??
                          const _CIPSErrorView(
                            icon: Icon(
                              Icons
                                  .signal_wifi_statusbar_connected_no_internet_4,
                            ),
                            errorMessage: kNoInternetConnection,
                            errorDescription: kNoInternetConnectionMessage,
                          );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Reloads the web view content if the controller is available.
  Future<void> _reload() async {
    if (controllerCompleter.isCompleted) {
      final webViewController = await controllerCompleter.future;
      webViewController.loadUrl(
        urlRequest: URLRequest(
          url: WebUri('javascript:window.location.reload(true)'),
        ),
      );
    }
  }

  /// Converts the HTTP body map into a URL-encoded Uint8List byte format.
  Future<Uint8List> convertBodyToUint8List(Map<String, dynamic> body) async {
    String encodedBody = body.entries
        .map((entry) =>
            '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value.toString())}')
        .join('&');

    Uint8List bodyBytes = Uint8List.fromList(utf8.encode(encodedBody));
    return bodyBytes;
  }
}

/// A widget for managing the Connect IPS web view client and handling payment-related events.
class _ConnectIPSWebViewClient extends StatelessWidget {
  const _ConnectIPSWebViewClient({
    required this.showLinearProgressIndicator,
    required this.webViewControllerCompleter,
    required this.body,
  });

  final ValueNotifier<bool> showLinearProgressIndicator;
  final Completer<InAppWebViewController?> webViewControllerCompleter;
  final Uint8List body;

  @override
  Widget build(BuildContext context) {
    final connectIPS =
        context.findAncestorWidgetOfExactType<ConnectIPSWebView>()!.connectIPS;
    return GlobalPopScope(
      onPopInvoked: (_) {
        ConnectIps.hasPopped = true;
        return connectIPS.onMessage(
          event: PaymentEvent.paymentCancelled,
          description: kPaymentCancelled,
          needsPaymentConfirmation: true,
          connectIPS,
        );
      },
      child: InAppWebView(
        onLoadStop: (controller, webUri) async {
          showLinearProgressIndicator.value = false;
          if (webUri != null) {
            if (connectIPS.verifyConfig == null) {
              final payconfig = connectIPS.payConfig;

              bool isSuccess = payconfig.successUrl.trim().isNotEmpty &&
                  webUri.toString().contains(payconfig.successUrl);
              bool isFailure = payconfig.failureUrl.trim().isNotEmpty &&
                  webUri.toString().contains(payconfig.failureUrl);

              if (isFailure) {
                await connectIPS.onReturn?.call();

                return connectIPS.onMessage(
                  connectIPS,
                  description: 'Transaction is cancelled or failed',
                  needsPaymentConfirmation: false,
                  event: PaymentEvent.unKnown,
                );
              }
              if (isSuccess) {
                var message =
                    'MERCHANTID=${payconfig.merchantID},APPID=${payconfig.appID},REFERENCEID=${payconfig.transactionID},TXNAMT=${payconfig.transactionAmount}';
                final result = PaymentResult(
                  merchantID: payconfig.merchantID,
                  appID: payconfig.appID,
                  referenceID: payconfig.transactionID,
                  txnAmount: payconfig.transactionAmount,
                  status: 'Payment Success',
                  statusDesc: 'Verification required',
                  token: await getSignedToken(
                    message,
                    payconfig.creditorPath,
                  ),
                );
                await connectIPS.onReturn?.call(result);
                return connectIPS.onPaymentResult(
                  result,
                  connectIPS,
                );
              }
            } else {
              return connectIPS.onPaymentVerification(
                onPaymentResult: connectIPS.onPaymentResult,
                onMessage: connectIPS.onMessage,
              );
            }
          }
        },
        onReceivedError: (_, webResourceRequest, error) async {
          showLinearProgressIndicator.value = false;
          return connectIPS.onMessage(
            description: error.description,
            event: PaymentEvent.paymentCancelled,
            needsPaymentConfirmation: true,
            connectIPS,
          );
        },
        onReceivedHttpError: (_, webResourceRequest, response) async {
          showLinearProgressIndicator.value = false;
          return connectIPS.onMessage(
            statusCode: response.statusCode,
            event: PaymentEvent.paymentCancelled,
            needsPaymentConfirmation: true,
            connectIPS,
          );
        },
        onWebViewCreated: webViewControllerCompleter.complete,
        initialSettings: InAppWebViewSettings(
          useOnLoadResource: true,
          useHybridComposition: true,
          clearCache: true,
          cacheEnabled: false,
          cacheMode: CacheMode.LOAD_NO_CACHE,
        ),
        initialUrlRequest: URLRequest(
          url: WebUri.uri(
            Uri.parse(
              kDefaultBaseLoginUrl.replaceAll(
                'base_url',
                connectIPS.payConfig.baseUrl,
              ),
            ),
          ),
          method: 'POST',
          body: body,
        ),
        onProgressChanged: (_, progress) {
          if (progress == 100) showLinearProgressIndicator.value = false;
        },
      ),
    );
  }
}

/// A widget that is displayed when there is no internet connection.
class _CIPSErrorView extends StatelessWidget {
  /// Constructor for [_CIPSErrorView].
  ///
  /// A widget that is displayed when there is no internet connection.
  const _CIPSErrorView({
    this.icon,
    this.errorMessage,
    this.errorDescription,
  });

  final Icon? icon;
  final String? errorMessage;
  final String? errorDescription;

  @override
  Widget build(BuildContext context) {
    return icon != null && errorMessage != null
        ? Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon!,
                  const SizedBox(height: 10),
                  Text(
                    errorMessage!,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (errorDescription != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Text(errorDescription ?? ''),
                    ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
