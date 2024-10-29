/// Configuration class for verifying Connect IPS transactions.
///
/// This class holds the necessary credentials for Basic Authentication,
/// which includes a [username] and [password]. These credentials are required
/// for securely verifying transactions with Connect IPS.
class VerifyTransactionConfig {
  /// Creates an instance of [VerifyTransactionConfig].
  ///
  /// Requires [username] and [password] for Basic Authentication, enabling
  /// secure transaction verification through Connect IPS.
  const VerifyTransactionConfig(
    this.username,
    this.password,
  );

  /// The username used for Basic Authentication in transaction verification.
  final String username;

  /// The password used for Basic Authentication in transaction verification.
  final String password;
}
