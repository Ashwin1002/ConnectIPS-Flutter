import 'dart:math';

/// Generates transaction id from random characters of length 20
String generateTransactionID([int length = 20]) {
  const String chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  Random random = Random();

  return List.generate(
    length,
    (index) => chars[random.nextInt(
      chars.length,
    )],
  ).join();
}
