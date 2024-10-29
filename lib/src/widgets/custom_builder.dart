import 'package:flutter/material.dart';

/// Signature for a function that creates error widget shown while transaction.
/// Contains a `message` and `description`.
typedef ErrorWidgetBuilder = Widget Function(
  BuildContext context,
  String message,
  String description,
);

/// Class containing all custom builders for `ConnectIPSWebView`.
class CustomWidgetBuilder {
  /// Custom appbar for Connect IPS webview
  final PreferredSizeWidget? appBar;

  /// Custom Loading indicator
  final Widget? loadingIndicator;

  ///
  final ErrorWidgetBuilder? errorBuilder;

  /// Creates `CustomWidgetBuilder` for `ConnectIPSWebView` widget.
  const CustomWidgetBuilder({
    this.appBar,
    this.loadingIndicator,
    this.errorBuilder,
  });
}
