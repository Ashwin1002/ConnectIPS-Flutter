import 'dart:developer';

import 'package:connect_ips_flutter/connect_ips_flutter/src/constants/app_texts.dart';
import 'package:connect_ips_flutter/connect_ips_flutter/src/core/connect_ips.dart';
import 'package:connect_ips_flutter/connect_ips_flutter/src/model/cips_config.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connect IPS Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.redAccent,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Connect IPS demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ConnectIps connectIps;

  @override
  void initState() {
    super.initState();
    connectIps = ConnectIps(
      config: const CIPSConfig.stag(
        creditorPath: 'private_key.pem', // path of the .pem file
        merchantID: 007, // merchant ID provided by NCHL
        appID: 'MER-550-APP-1', // app ID provided by NCHL
        appName: 'APPNAME', // app name provided by NCHL
        transactionID: 'earthier_0015', // unique transaction ID for every transaction
        successUrl: 'https://dev.earthier.net/transaction/success', // your success url set for connect IPS after successful transaction
        failureUrl: 'https://dev.earthier.net/transaction/failure', // your failure url set by connect IPS afetr failure
        transactionAmount: 1000, // transaction amount in paisa
      ),
      onMessage: (
        connectIPS, {
        description,
        event,
        needsPaymentConfirmation,
        statusCode,
      }) {
        log(
          'Description: $description, Status Code: $statusCode, Event: $event, NeedsPaymentConfirmation: $needsPaymentConfirmation',
        );
        connectIPS.close(context);
      },
      onPaymentResult: (paymentResult, connectIps) {
        log('result => $paymentResult');
        connectIps.close(context);
      },
      onReturn: ([payment]) {
        log('redirection after payment completion : $payment');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => connectIps.open(context),
          child: const Text(kPayWithCIPS),
        ),
      ),
    );
  }
}
