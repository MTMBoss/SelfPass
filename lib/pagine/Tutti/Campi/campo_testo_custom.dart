import 'package:flutter/material.dart';
import 'campi_chiave.dart';

typedef RemoveCallback = void Function();

class CampoTestoCustom extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final VoidCallback? onIconPressed;
  final RemoveCallback? onRemove;
  final bool obscureText;
  final bool passwordGenerator;

  const CampoTestoCustom({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.onIconPressed,
    this.onRemove,
    this.obscureText = false,
    this.passwordGenerator = false,
  });

  Future<void> _showPasswordGeneratorDialog(BuildContext context) async {
    final generated = await showDialog<String>(
      context: context,
      builder: (context) => const PasswordGeneratorDialog(),
    );
    if (generated != null) {
      controller.text = generated;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(fontWeight: FontWeight.normal),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              border: const OutlineInputBorder(),
              suffixIcon:
                  passwordGenerator
                      ? IconButton(
                        icon: const Icon(Icons.vpn_key, size: 20),
                        onPressed: () => _showPasswordGeneratorDialog(context),
                        tooltip: 'Genera password',
                      )
                      : (icon != null
                          ? (onIconPressed != null
                              ? IconButton(
                                icon: Icon(icon, size: 20),
                                onPressed: onIconPressed,
                                tooltip: 'Genera password',
                              )
                              : Icon(icon, size: 20))
                          : null),
            ),
          ),
        ),
        if (onRemove != null)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onRemove,
            tooltip: 'Rimuovi campo',
          ),
      ],
    );
  }
}
