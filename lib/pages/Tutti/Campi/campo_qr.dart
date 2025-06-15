import 'package:flutter/material.dart';
import 'campo_testo_custom.dart';

class PasswordMonousoCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const PasswordMonousoCampo({
    super.key,
    required this.controller,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Password Monouso',
      controller: controller,
      icon: Icons.qr_code,
      onRemove: onRemove ?? () {},
      obscureText: false,
    );
  }
}
