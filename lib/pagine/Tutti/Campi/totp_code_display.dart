import 'dart:async';
import 'package:flutter/material.dart';
import 'package:otp/otp.dart';

class TotpCodeDisplay extends StatefulWidget {
  final String secret;
  final int length;
  final int interval;

  const TotpCodeDisplay(
    this.secret, {
    this.length = 6,
    this.interval = 30,
    super.key,
  });

  @override
  TotpCodeDisplayState createState() => TotpCodeDisplayState();
}

class TotpCodeDisplayState extends State<TotpCodeDisplay> {
  String code = '';
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _updateCode();
    timer = Timer.periodic(Duration(seconds: 1), (_) => _updateCode());
  }

  void _updateCode() {
    final newCode = OTP.generateTOTPCodeString(
      widget.secret,
      DateTime.now().millisecondsSinceEpoch,
      length: widget.length,
      interval: widget.interval,
    );
    if (newCode != code) {
      setState(() {
        code = newCode;
      });
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      code,
      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    );
  }
}
