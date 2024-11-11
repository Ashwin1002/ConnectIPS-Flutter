# ConnectIPS Flutter

ConnectIPS flutter is an implementation of Connect IPS payment gateway in flutter. It ease the process of integrating ConnectIPS in your mobile/web app with the help of the official ConnectIPS documentation. You can visit the official documentation using this link:
https:npidoc.connectips.com/docs/connectIPS-Gateway/introduction

## Getting Started with Connect IPS payment gateway integration

In order to use the payment gateway, first you need to set up your merchant account. Merchant first needs to enroll their application for connectIPS through its bank by providing necessary supporting documents/ information. For more info, look into the documentation via above link.
After enrollment, you would be provided with following information:

MERCHANTID: Type Integer: Length 20: Merchant ID is and unique identifier to identify merchant in the system. 

APPID: Type String: Length 20: Unique identification, which will be used to identify the accountdetails of the merchant’s application.

APPNAME: Type String: Length 30: Application name to identify merchant as well as originating application.

CREDITOR.pfx file for signing token for testing.

You also need to provide the success & failure url which needs to set by the NCHL for redirection after successful or failed transaction.

## Generating the token

For each request like opening login page, or getting transaction detail or verifying the transaction, you need to generate a signed token. Steps to produce a signed token:
i. Generate message digest of the token string using SHA256 hashing algorithm.

ii. Sign the message digest using the digital certificate private key (pfx file/keystore). The digital signature algorithm will be the SHA256withRSA. Private key file will be CREDITOR.pfx for testing purpose.

iii. Convert the signed token above in step ii to base64 encoding. iv. Pass this signature string from step iii to the “token” field of the request message.

Since dart doesn't read Certificate file of type .pfx, it is necessary to convert the .pfx certificate into .pem certificate using OPENSSL. To extract the pfx file use the following command:
 ```openssl pkcs12 -in your_certificate.pfx -nocerts -nodes -out private_key.pem```

 Replace `your_certificate.pfx` name with the CREDITOR.pfx file provided by NCHL. It will generate a `prvate_key.pem` file which would be used to sign the message digest.

## Usuage:

1. Add `connect_ips_flutter` as a dependency in your pubspec.yaml file:
   ```
   dependencies:
     connect_ips_flutter: any
   ```

2. Import the package in your Dart code:
   ```
   import 'package:connect_ips_flutter/connect_ips_flutter.dart';
   ```

3. You can use `CIPSConfig.stag` config for testing and `CIPSConfig.live` config for production.

  ```
    final config = const CIPSConfig.stag(
      creditorPath: '<----path to the generated .pem file---->',
      merchantID: '<----merchant id provided by NCHL----->',
      appID: '<----app id resgistered in NCHL---->',
      appName: '<----app id resgistered in NCHL---->',
      transactionID: '<----Unique transaction ID for each request---->,
      successUrl: 'https:example.com/success',  your success url after payment success
      failureUrl: 'https:example.com/transaction/failure',  your failure url after payment failure or when clicking `Return to Creditor Site` button.
      transactionAmount: 1000,  transaction amount in paisa
  );
  ```

4. You can use either ConnectIPS pay button or create your own using `ConnectIps` instance.

4.1. Using Payment Button:
     Create payment button widget as below:
      ```
      ConnectIPSPaymentButton(
          config: config,
          onMessage: (
            connectIPS, {
            description,
            event,
            needsPaymentConfirmation,
            statusCode,
          }) {
            log('message: $description, event: $event, statusCode: $statusCode ');
          },
          onPaymentResult: (paymentResult, connectIps) {
            log('payment result => $paymentResult');
          },
        ```

4.2. Creating your own instance:

Create a ConnectIPS instance by:

```
   late ConnectIps connectIps;

  @override
   void initState() {
     super.initState();
     connectIps = ConnectIps(
       config: CIPSConfig.stag(...),
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

```

Now, open the ConnectIPS payment page via:
```
connectIps.open(context);
```

Plus, you can also verify the transaction. Verification is done using Basic Authentication which requires a `username` and a `password`. The `VerifyTransactionConfig` hold two parameters, a `username` and a `password`.

In your `ConnectIPSPaymentButton` button or `ConnectIps` instance, add the verification conig:
```
final vConfig = VerificationConfig
  username: //username provided by NCHL
  password: // password provided by NCHL
);
```

You are now all setup. Please test using the information provided by NCHL.

## Contributions
Contributions are welcome! To make this project better, Feel free to open an issue or submit a pull request on Github.

