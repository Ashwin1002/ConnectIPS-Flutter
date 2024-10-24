import 'dart:convert';

import 'package:asn1lib/asn1lib.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/export.dart';

/// Get the signed token from message using `SHA256withRSA` algorithm.
///
/// Steps to generate a signed token:
///
/// i. Generate message digest of the token string using SHA256 hashing algorithm.
///
/// ii. Sign the message digest using the digital certificate private key
/// (pfx file/keystore). The digital signature algorithm will be the SHA256withRSA.
///  Private key file will be [CREDITOR.pfx] for testing purpose.
///
/// iii. Convert the signed token above in step ii to base64 encoding
///
/// Parameters:
/// - [message]: Message required for encryption.
/// - [path]: Path of the digital certificate private key (pfx file/keystore)

Future<String> getSignedToken(String message, String path) async {
// Load the private key from PEM file
  final privateKey = await _loadPrivateKeyFromPem(path);

  // Sign the message
  final signature = _signMessage(message, privateKey);

  // Output the base64-encoded signature
  final token = base64Encode(signature);

  return token;
}

/// Get the private key from [.pem] file
String? _getPemString(String key) {
  // Regular expression to extract content between the BEGIN and END lines
  RegExp regExp = RegExp(
    r'-----BEGIN PRIVATE KEY-----(.*?)-----END PRIVATE KEY-----',
    dotAll: true,
  );

  // Extract the private key content
  Match? match = regExp.firstMatch(key);
  if (match != null) {
    return match.group(1)!.replaceAll(RegExp(r'\s+'), '');
  }
  return null;
}

/// Function to load the private key from PEM file in assets
Future<RSAPrivateKey> _loadPrivateKeyFromPem(String path) async {
  final pemString =
      await rootBundle.loadString(path); // Load PEM file from assets
  return _parsePrivateKeyFromPem(pemString); // Function to parse PEM file
}

/// Function to parse the PEM file and get the RSA private key
RSAPrivateKey _parsePrivateKeyFromPem(String pemString) {
  final keyBase64 = _getPemString(pemString) ?? '';

  final bytes = Uint8List.fromList(base64Decode(keyBase64));

  var asn1Parser = ASN1Parser(bytes);
  var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
  //ASN1Object version = topLevelSeq.elements[0];
  //ASN1Object algorithm = topLevelSeq.elements[1];
  var privateKey = topLevelSeq.elements[2];

  asn1Parser = ASN1Parser(privateKey.valueBytes());

  ASN1Integer modulus, privateExponent, p, q;
  // Depending on the number of elements, we will either use PKCS1 or PKCS8
  if (topLevelSeq.elements.length == 3) {
    var privateKey = topLevelSeq.elements[2];

    asn1Parser = ASN1Parser(privateKey.contentBytes());
    var pkSeq = asn1Parser.nextObject() as ASN1Sequence;

    modulus = pkSeq.elements[1] as ASN1Integer;
    privateExponent = pkSeq.elements[3] as ASN1Integer;
    p = pkSeq.elements[4] as ASN1Integer;
    q = pkSeq.elements[5] as ASN1Integer;
  } else {
    modulus = topLevelSeq.elements[1] as ASN1Integer;
    privateExponent = topLevelSeq.elements[3] as ASN1Integer;
    p = topLevelSeq.elements[4] as ASN1Integer;
    q = topLevelSeq.elements[5] as ASN1Integer;
  }

  var rsaPrivateKey = RSAPrivateKey(
      modulus.valueAsBigInteger,
      privateExponent.valueAsBigInteger,
      p.valueAsBigInteger,
      q.valueAsBigInteger);

  return rsaPrivateKey;
}

/////////////////// PRIVATE METHODS /////////////////
Uint8List _createUint8ListFromString(String s) {
  var codec = const Utf8Codec(allowMalformed: true);
  return Uint8List.fromList(codec.encode(s));
}

/// Function to sign a message using the private key and SHA256withRSA
Uint8List _signMessage(String message, RSAPrivateKey privateKey) {
  // Set up RSA signer with SHA256/RSA
  final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
  signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));

  // Sign the message digest and return the signature
  final signature =
      signer.generateSignature(_createUint8ListFromString(message));

  // Return the signature in bytes
  return signature.bytes;
}
