import 'dart:async';
import 'package:flutter/material.dart';
import 'package:otp/otp.dart';
import 'campo_testo_custom.dart';
import 'campo_totp.dart';

class PasswordMonousoCampo extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const PasswordMonousoCampo({
    super.key,
    required this.controller,
    this.onRemove,
  });

  @override
  State<PasswordMonousoCampo> createState() => _PasswordMonousoCampoState();
}

class _PasswordMonousoCampoState extends State<PasswordMonousoCampo> {
  String? _secret;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTotpTimer() {
    _timer?.cancel();
    if (_secret != null) {
      final initialCode = OTP.generateTOTPCodeString(
        _secret!,
        DateTime.now().millisecondsSinceEpoch,
        length: 6,
        interval: 30,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
      );
      widget.controller.value = widget.controller.value.copyWith(
        text: initialCode,
        selection: TextSelection.collapsed(offset: initialCode.length),
        composing: TextRange.empty,
      );
    }
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_secret != null) {
        final code = OTP.generateTOTPCodeString(
          _secret!,
          DateTime.now().millisecondsSinceEpoch,
          length: 6,
          interval: 30,
          algorithm: Algorithm.SHA1,
          isGoogle: true,
        );
        widget.controller.value = widget.controller.value.copyWith(
          text: code,
          selection: TextSelection.collapsed(offset: code.length),
          composing: TextRange.empty,
        );
      }
    });
  }

  void _showQrOptions(BuildContext context) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Scegli un\'opzione'),
            content: const Text(
              'Seleziona come vuoi procedere con il codice QR',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final scannedSecret = await Navigator.of(
                    context,
                  ).push<String?>(
                    MaterialPageRoute(builder: (_) => const CampoTotpPage()),
                  );
                  if (scannedSecret != null && scannedSecret.isNotEmpty) {
                    setState(() {
                      _secret = scannedSecret;
                    });
                    _startTotpTimer();
                  }
                },
                child: const Text('Scansiona codice QR e genera TOTP'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // You can add another option here if needed
                },
                child: const Text('Annulla'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Password Monouso',
      controller: widget.controller,
      icon: Icons.qr_code,
      onIconPressed: () => _showQrOptions(context),
      onRemove: widget.onRemove ?? () {},
      obscureText: false,
    );
  }
}
