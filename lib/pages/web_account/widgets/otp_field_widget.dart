import 'dart:async';
import 'package:flutter/material.dart';
import '../../qr_scanner_page.dart';

class OtpFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String? otpSecret;
  final Function(String) onOtpSecretChanged;

  const OtpFieldWidget({
    super.key,
    required this.controller,
    required this.otpSecret,
    required this.onOtpSecretChanged,
  });

  @override
  OtpFieldWidgetState createState() => OtpFieldWidgetState();
}

class OtpFieldWidgetState extends State<OtpFieldWidget> {
  int _remainingSeconds = 30;
  late Timer _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final passed = secondsSinceEpoch % 30;
      setState(() {
        _remainingSeconds = 30 - passed;
        if (_remainingSeconds == 30) {
          _updateOTP();
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  void _updateOTP() {
    // OTP generation logic should be handled outside or passed in
    // Here we just keep the controller text updated if otpSecret changes
    // This method can be extended if needed
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                decoration: InputDecoration(
                  labelText: 'One-time password (2FA)',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () async {
                final res = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (_) => const QRScannerPage()),
                );
                if (res != null) {
                  widget.onOtpSecretChanged(res);
                  widget.controller.text = res;
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Expires in: \$_remainingSeconds sec",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
