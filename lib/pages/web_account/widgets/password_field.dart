import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool passwordVisible;
  final double passwordStrength;
  final String passwordStrengthLabel;
  final String passwordCrackTime;
  final VoidCallback onToggleVisibility;
  final VoidCallback onGeneratePassword;
  final VoidCallback onDelete;

  const PasswordField({
    super.key,
    required this.controller,
    required this.passwordVisible,
    required this.passwordStrength,
    required this.passwordStrengthLabel,
    required this.passwordCrackTime,
    required this.onToggleVisibility,
    required this.onGeneratePassword,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          obscureText: !passwordVisible,
          decoration: InputDecoration(
            labelText: 'Password',
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: onToggleVisibility,
                ),
                IconButton(
                  icon: const Icon(Icons.vpn_key),
                  onPressed: onGeneratePassword,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _showDeleteDialog(context),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: passwordStrength,
                backgroundColor: Colors.grey[300],
                color: _getStrengthColor(passwordStrength),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Crack time: $passwordCrackTime',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStrengthColor(double strength) {
    if (strength < 0.5) return Colors.red;
    if (strength < 0.75) return Colors.orange;
    return Colors.green;
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Opzioni'),
          content: const Text('Scegli un\'azione'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete();
              },
              child: const Text('Elimina'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annulla'),
            ),
          ],
        );
      },
    );
  }
}
