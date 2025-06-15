import 'package:flutter/material.dart';

class ApplicazioneCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const ApplicazioneCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Applicazione',
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.android),
      ),
    );
  }
}
