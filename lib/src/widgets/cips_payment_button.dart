import 'dart:developer';

import 'package:connect_ips_flutter/connect_ips_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

const _cipsLogo = '''
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 20010904//EN"
 "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">
<svg version="1.0" xmlns="http://www.w3.org/2000/svg"
 width="512.000000pt" height="512.000000pt" viewBox="0 0 512.000000 512.000000"
 preserveAspectRatio="xMidYMid meet">

<g transform="translate(0.000000,512.000000) scale(0.100000,-0.100000)"
fill="#000000" stroke="none">
<path d="M2200 5029 c-435 -56 -837 -273 -1063 -575 -159 -211 -249 -441 -277
-707 -6 -56 -13 -109 -16 -118 -2 -9 -28 -32 -57 -52 -373 -251 -586 -738
-547 -1251 30 -400 134 -720 313 -963 70 -95 228 -248 317 -307 205 -137 398
-196 643 -196 156 0 146 6 210 -121 178 -355 477 -584 867 -666 123 -26 332
-23 470 6 203 43 443 140 600 241 222 144 404 362 511 611 63 146 109 348 109
480 0 65 7 77 77 129 121 91 243 222 320 345 77 121 157 323 187 470 43 210
43 384 1 645 -64 387 -199 674 -425 900 -160 159 -337 264 -535 316 -80 21
-132 27 -260 31 -88 3 -167 9 -175 13 -8 5 -39 56 -69 114 -191 372 -534 614
-931 656 -109 11 -178 11 -270 -1z m545 -494 c181 -39 350 -163 452 -333 29
-49 23 -64 -35 -83 -20 -6 -75 -29 -121 -50 -352 -162 -600 -490 -696 -919
-11 -49 -18 -144 -22 -272 -3 -123 -10 -203 -17 -212 -6 -8 -65 -26 -134 -40
-161 -34 -367 -36 -488 -6 -204 52 -358 176 -458 370 -83 163 -146 394 -115
425 19 19 151 62 229 74 141 23 371 4 409 -33 12 -13 10 -19 -13 -47 -28 -33
-29 -48 -5 -60 20 -11 563 -53 583 -46 9 4 16 16 16 28 0 12 -32 137 -71 278
-39 141 -77 276 -83 301 -10 37 -16 45 -36 45 -20 0 -36 -21 -94 -117 -100
-165 -86 -156 -198 -124 -186 53 -409 55 -603 6 -93 -24 -111 -25 -118 -5 -13
32 80 204 167 309 177 211 636 439 1031 511 98 18 334 18 420 0z m1015 -557
c307 -74 538 -405 650 -934 44 -208 60 -355 60 -542 0 -199 -17 -318 -64 -441
-51 -135 -121 -245 -153 -239 -9 2 -24 33 -37 78 -146 502 -477 843 -917 942
-87 19 -132 23 -279 23 -104 0 -190 -5 -212 -12 -61 -19 -68 0 -68 188 0 362
94 613 291 775 64 52 223 134 261 134 31 0 32 -4 49 -119 13 -93 7 -258 -11
-308 -15 -40 -28 -41 -133 -9 -68 22 -79 23 -92 10 -18 -18 -32 14 153 -331
100 -187 140 -253 153 -253 12 0 82 83 201 236 101 129 187 244 192 254 19 41
3 50 -96 50 -51 0 -98 4 -104 8 -7 4 -13 65 -17 167 -3 88 -12 198 -22 244
-13 69 -14 86 -3 93 15 10 131 2 198 -14z m-2850 -758 c41 -159 116 -326 207
-464 252 -378 676 -574 1137 -527 84 8 112 8 124 -1 12 -10 13 -45 9 -213 -4
-175 -8 -213 -31 -300 -63 -241 -190 -409 -379 -504 -104 -53 -151 -62 -166
-32 -27 50 -31 312 -6 393 13 39 27 39 103 -3 40 -22 77 -37 82 -34 6 3 10 18
9 33 0 44 -174 555 -192 566 -13 8 -48 -15 -179 -114 -90 -68 -196 -149 -236
-179 -60 -46 -72 -60 -70 -81 3 -23 11 -27 108 -48 58 -13 111 -29 117 -35 10
-10 10 -32 2 -102 -13 -103 -7 -231 18 -358 12 -65 14 -90 5 -99 -15 -15 -116
-11 -188 8 -326 84 -551 405 -663 945 -48 235 -64 398 -58 594 7 186 22 277
69 398 37 96 123 229 146 225 10 -2 22 -26 32 -68z m2585 -814 c197 -67 339
-196 434 -396 71 -150 119 -353 90 -377 -8 -6 -61 -25 -119 -43 -145 -45 -307
-52 -429 -21 -101 26 -155 51 -159 72 -2 11 22 35 67 68 53 40 68 56 64 71 -7
25 -5 25 -238 59 -110 17 -232 35 -272 42 -87 14 -103 9 -103 -31 0 -28 94
-562 106 -602 12 -39 48 -19 99 53 78 110 68 106 177 66 196 -73 431 -86 653
-37 136 30 139 30 143 -2 4 -33 -51 -154 -106 -234 -49 -72 -174 -194 -262
-256 -308 -216 -809 -376 -1112 -354 -107 7 -162 19 -248 53 -125 50 -247 150
-321 266 -65 100 -63 110 26 142 366 132 638 431 764 840 45 147 63 270 65
434 1 132 3 145 21 156 17 11 125 37 245 59 14 2 95 3 180 2 138 -3 164 -6
235 -30z"/>
</g>
</svg>

''';

/// Define a custom payment button widget for ConnectIPS, allowing configuration and optional callbacks.
class ConnectIPSPaymentButton extends StatefulWidget {
  /// Public Constructor for `ConnectIPSPaymentButton`
  const ConnectIPSPaymentButton({
    super.key,
    required this.config, // Payment configuration
    this.onMessage, // Callback for messages
    this.onPaymentResult, // Callback for payment results
    this.onReturn, // Callback when returning after payment completion
    this.customBuilder, // Optional custom button builder
  });

  /// Configurations for ConnectIPS. It has two named constructors:
  /// `stag` and `live`
  final CIPSConfig config;

  /// Callback type for handling exceptions that occur during payment processing.
  final OnMessage? onMessage;

  /// Callback type for handling successful or failed payment results.
  final OnPaymentResult? onPaymentResult;

  /// Callback for when the user is redirected to the `return_url`.
  final OnReturn? onReturn;

  /// Custom builder for decorating the payment button
  final CustomWidgetBuilder? customBuilder;

  @override
  State<ConnectIPSPaymentButton> createState() =>
      _ConnectIPSPaymentButtonState();
}

class _ConnectIPSPaymentButtonState extends State<ConnectIPSPaymentButton> {
  // ConnectIPS instance for managing the payment flow.
  late ConnectIps connectIps;

  @override
  void initState() {
    super.initState();
    // Initialize the ConnectIps instance with the configuration and callbacks.
    connectIps = ConnectIps(
      config: widget.config, // Use provided config for payment
      onMessage: (
        connectIPS, {
        description, // Message description
        event, // Event type
        needsPaymentConfirmation, // Whether payment confirmation is needed
        statusCode, // HTTP status code (if any)
      }) {
        // Log the message and optional details.
        log(
          'Description: $description, Status Code: $statusCode, Event: $event, NeedsPaymentConfirmation: $needsPaymentConfirmation',
        );
        // Invoke optional user-provided message callback.
        widget.onMessage?.call(
          connectIPS,
          description: description,
          event: event,
          needsPaymentConfirmation: needsPaymentConfirmation,
          statusCode: statusCode,
        );
        // Close ConnectIPS dialog after message handling.
        connectIPS.close(context);
      },
      // Handle the payment result by logging it and invoking optional callback.
      onPaymentResult: (paymentResult, connectIps) {
        log('result => $paymentResult');
        widget.onPaymentResult?.call(paymentResult, connectIps);
        connectIps.close(context);
      },
      // Handle return after payment, logging the redirection and calling optional callback.
      onReturn: ([payment]) {
        widget.onReturn?.call(payment);
        log('redirection after payment completion : $payment');
      },
    );
  }

  // Private helper function to build the ConnectIPS logo, allowing optional sizing.
  Widget _buildLogo([Size? size]) {
    return _ConnectIPSLogo(
      key: const Key('connect_ips_logo'), // Set unique key for the logo
      size: size, // Optional custom size
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build custom button if customBuilder is provided; otherwise, use default button design.
    return widget.customBuilder?.buttonBuilder?.call(
          context,
          _buildLogo(widget
              .customBuilder?.logoSize), // Pass in custom logo size if provided
          kPayWithCIPS, // Button text
        ) ??
        // Default button appearance if no custom builder is provided.
        ElevatedButton(
          style: widget.customBuilder?.buttonStyle,
          onPressed: () => connectIps.open(context),
          child: Row(
            children: [
              _buildLogo(widget.customBuilder?.logoSize),
              const SizedBox(width: 10.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  kPayWithCIPS,
                  style: widget.customBuilder?.buttonTextStyle,
                ),
              ),
            ],
          ),
        );
  }
}

// Define a widget to display the ConnectIPS logo, allowing size customization.
class _ConnectIPSLogo extends StatelessWidget {
  const _ConnectIPSLogo({
    super.key,
    this.size,
  });

  final Size? size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _cipsLogo,
      height: size?.height ?? 24.0,
      width: size?.width ?? 24.0,
      colorFilter: const ColorFilter.mode(
        Colors.red,
        BlendMode.srcIn,
      ),
    );
  }
}
