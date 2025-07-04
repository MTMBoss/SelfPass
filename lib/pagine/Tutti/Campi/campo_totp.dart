import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:otp/otp.dart';

class CampoTotpPage extends StatefulWidget {
  const CampoTotpPage({super.key});

  @override
  CampoTotpPageState createState() => CampoTotpPageState();
}

class CampoTotpPageState extends State<CampoTotpPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? otpSecret;
  String? currentCode;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (otpSecret != null) {
        final code = OTP.generateTOTPCodeString(
          otpSecret!,
          DateTime.now().millisecondsSinceEpoch,
          interval: 30,
          length: 6,
          algorithm: Algorithm.SHA1,
          isGoogle: true,
        );
        if (code != currentCode) {
          setState(() {
            currentCode = code;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    timer?.cancel();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      final uriString = scanData.code;
      if (uriString != null && uriString.startsWith('otpauth://')) {
        final secret = _parseSecretFromOtpAuthUri(uriString);
        if (secret != null) {
          final digits =
              int.tryParse(_parseDigitsFromOtpAuthUri(uriString) ?? '') ?? 6;
          final period =
              int.tryParse(_parsePeriodFromOtpAuthUri(uriString) ?? '') ?? 30;
          final code = OTP.generateTOTPCodeString(
            secret,
            DateTime.now().millisecondsSinceEpoch,
            length: digits,
            interval: period,
            algorithm: Algorithm.SHA1,
            isGoogle: true,
          );
          setState(() {
            otpSecret = secret;
            currentCode = code;
          });
          controller.pauseCamera();
          // Return the secret to caller instead of code
          Future.delayed(Duration.zero, () {
            if (!mounted) return;
            Navigator.of(context).pop(secret);
          });
        }
      }
    });
  }

  String? _parseDigitsFromOtpAuthUri(String uri) {
    try {
      final uriObj = Uri.parse(uri);
      return uriObj.queryParameters['digits'];
    } catch (e) {
      return null;
    }
  }

  String? _parsePeriodFromOtpAuthUri(String uri) {
    try {
      final uriObj = Uri.parse(uri);
      return uriObj.queryParameters['period'];
    } catch (e) {
      return null;
    }
  }

  String? _parseSecretFromOtpAuthUri(String uri) {
    try {
      final uriObj = Uri.parse(uri);
      return uriObj.queryParameters['secret'];
    } catch (e) {
      return null;
    }
  }

  void _reset() {
    setState(() {
      otpSecret = null;
      currentCode = null;
    });
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generatore TOTP')),
      body: Center(
        child:
            otpSecret == null
                ? SizedBox(
                  width: 300,
                  height: 300,
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                    overlay: QrScannerOverlayShape(
                      borderColor: Colors.blue,
                      borderRadius: 10,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: 250,
                    ),
                  ),
                )
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Codice TOTP:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentCode ?? 'Generazione in corso...',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _reset,
                      child: const Text('Scansiona un altro codice'),
                    ),
                  ],
                ),
      ),
    );
  }
}
