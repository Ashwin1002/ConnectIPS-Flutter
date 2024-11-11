# ![cips_logo](https://github.com/user-attachments/assets/8affc63a-a450-4570-877c-a4e245962c8d) ConnectIPS Flutter

ConnectIPS Flutter is a Flutter package that simplifies the integration of the Connect IPS payment gateway into your mobile or web applications. It leverages the official [Connect IPS documentation](https://npidoc.connectips.com/docs/category/2-connectips-gateway) for a seamless integration experience.

## Features
- Easy integration with Connect IPS payment gateway.
- Supports both staging and live environments.
- Provides widgets and methods to customize payment flows.
- Token-based transaction authentication.
- Supports transaction verification using Basic Authentication.

## Getting Started

### Prerequisites

1. Merchant Enrollment
Before integrating ConnectIPS, ensure you have a merchant account. Merchants must enroll their applications through their respective banks by providing the necessary documentation. After successful enrollment, you will receive the following:

- MERCHANTID: Unique integer ID to identify the merchant.
- APPID: Unique string ID for the merchant's application.
- APPNAME: Application name identifying the merchant and its application.
- CREDITOR.pfx: Digital certificate file for signing tokens.

2. URLs for Redirection
You must provide the following URLs for transaction redirection:

- Success URL: Redirected upon successful payment.
- Failure URL: Redirected upon failed payment or manual return.

### Setting Up
1. Certificate Conversion
Since Dart doesn't directly support .pfx files, convert the provided .pfx certificate to a .pem file using OpenSSL in your project terminal:

```
openssl pkcs12 -in CREDITOR.pfx -nocerts -nodes -out private_key.pem
```

The private_key.pem file will be used to sign the token. Add the asset path in the `pubspec.yaml` file.

```
assets:
 - private_key.pem // path of the generated .pem file
```

2. Add Dependency
Add `connect_ips_flutter` to your pubspec.yaml:

```
dependencies:
  connect_ips_flutter: any
```

4. Import the Package

```import 'package:connect_ips_flutter/connect_ips_flutter.dart';```

## Usage

### Configuration
Set up your configuration using `CIPSConfig`:

```
final config = const CIPSConfig.stag(
  creditorPath: '<path_to_private_key.pem>',
  merchantID: '<merchant_id>',
  appID: '<app_id>',
  appName: '<app_name>',
  transactionID: '<unique_transaction_id>',
  successUrl: 'https://example.com/success',
  failureUrl: 'https://example.com/failure',
  transactionAmount: 1000, // Amount in paisa
);
```

You can create a unique transaction id by also using a utiltiy function `generateTransactionID([int length = 20])`. This helper function will generate a unique transaction id of given `length`. Optional param `length` default to `20`. 

Note: Transaction ID can be only maximum of 20 characters. For more info and other related character information, visit [Merchant Interface](https://npidoc.connectips.com/docs/connectIPS-Gateway/merchant-interface) docs.

For production, use `CIPSConfig.live`.

### Payment Integration

1. Using Payment Button

```
ConnectIPSPaymentButton(
  config: config,
  onMessage: (connectIPS, {description, event, needsPaymentConfirmation, statusCode}) {
    log('Message: $description, Event: $event, Status Code: $statusCode');
  },
  onPaymentResult: (paymentResult, connectIps) {
    log('Payment Result: $paymentResult');
  },
);
```

2. Using Custom Instance

```
late ConnectIps connectIps;

@override
void initState() {
  super.initState();
  connectIps = ConnectIps(
    config: CIPSConfig.stag(...),
    onMessage: (connectIPS, {description, event, needsPaymentConfirmation, statusCode}) {
      log('Description: $description, Status Code: $statusCode');
      connectIPS.close(context);
    },
    onPaymentResult: (paymentResult, connectIps) {
      log('Result: $paymentResult');
      connectIps.close(context);
    },
    onReturn: ([payment]) {
      log('Redirection after payment: $payment');
    },
  );
}

void initiatePayment() {
  connectIps.open(context);
}

```

### Transaction Verification
Verification is done via Basic Authentication using a username and password provided by NCHL:

```
final vConfig = VerificationConfig(
  username: '<username>',
  password: '<password>',
);
```

Add this to your payment button or custom instance for transaction verification.

## Testing
To create a test credentials for payment, use the following [link](https://uat.connectips.com:7443/) for registering a test account. After creating a test account, consult with NCHL team to link a test bank account.

## Contributions
Contributions are welcome!
Feel free to report issues or submit pull requests to improve this [project](https://github.com/Ashwin1002/ConnectIPS-Flutter/issues).

## Stay Connected
For further details, refer to the official [documentation](https://npidoc.connectips.com/docs/category/2-connectips-gateway).
