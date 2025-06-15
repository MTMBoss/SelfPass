import 'package:flutter/material.dart';
import 'campo_testo_custom.dart';

class LoginCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const LoginCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Login',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: false,
    );
  }
}

class EmailCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const EmailCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Email',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: false,
    );
  }
}
