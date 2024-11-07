import 'package:flutter/material.dart';

/// Signature for a function that creates error widget shown while transaction.
/// Contains a `message` and `description`.
typedef ErrorWidgetBuilder = Widget Function(
  BuildContext context,
  String message,
  String description,
);

// ignore: public_member_api_docs
typedef ButtonBuilder = Widget Function(
  BuildContext context,
  Widget logo,
  String text,
);

/// Class containing all custom builders for `ConnectIPSWebView`.
class CustomWidgetBuilder {
  /// Custom appbar for Connect IPS webview
  final PreferredSizeWidget? appBar;

  /// Custom Loading indicator
  final Widget? loadingIndicator;

  /// Custom Error widget builder for webview
  final ErrorWidgetBuilder? errorBuilder;

  /// Custom Button builder
  final ButtonBuilder? buttonBuilder;

  /// Textstyle for payment button
  final TextStyle? buttonTextStyle;

  /// Button Style for payment button
  final ButtonStyle? buttonStyle;

  /// Optional Size for connect ips logo
  final Size? logoSize;

  /// Creates `CustomWidgetBuilder` for `ConnectIPSWebView` widget and `ConnectIPSPaymentButton`.
  const CustomWidgetBuilder({
    this.appBar,
    this.loadingIndicator,
    this.errorBuilder,
    this.buttonBuilder,
    this.buttonTextStyle,
    this.buttonStyle,
    this.logoSize,
  });
}
