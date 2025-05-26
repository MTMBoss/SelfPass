import 'package:flutter/material.dart';
import '../helpers/password_strength_helper.dart';

typedef PasswordGeneratedCallback =
    void Function(String password, int length, String type);

class PasswordGeneratorDialog extends StatefulWidget {
  final int initialLength;
  final String initialType;
  final String initialPassword;
  final PasswordGeneratedCallback onPasswordGenerated;

  const PasswordGeneratorDialog({
    super.key,
    required this.initialLength,
    required this.initialType,
    required this.initialPassword,
    required this.onPasswordGenerated,
  });

  @override
  PasswordGeneratorDialogState createState() => PasswordGeneratorDialogState();
}

class PasswordGeneratorDialogState extends State<PasswordGeneratorDialog> {
  late int _length;
  late String _type;
  late String _password;
  late TextEditingController _passwordController;
  double _passwordStrength = 0;
  String _crackTime = '';

  Color _getStrengthColor(double strength) {
    if (strength < 0.5) return Colors.red;
    if (strength < 0.75) return Colors.orange;
    return Colors.green;
  }

  @override
  void initState() {
    super.initState();
    _length = widget.initialLength;
    _type = widget.initialType;
    _password = widget.initialPassword;
    _passwordController = TextEditingController(text: _password);
    _generatePassword();
    _updatePasswordStrength();
  }

  void _generatePassword() {
    const letters = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()-_=+[]{}|;:,.<>?';

    String chars = '';
    switch (_type) {
      case 'Memorizable':
        chars = 'aeioulnrst';
        break;
      case 'Numbers':
        chars = numbers;
        break;
      case 'Random':
        chars = letters + letters.toUpperCase() + numbers + symbols;
        break;
      case 'Letters+Numbers':
        chars = letters + letters.toUpperCase() + numbers;
        break;
      default:
        chars = letters + letters.toUpperCase() + numbers + symbols;
    }

    final rand =
        List.generate(_length, (index) {
          final idx =
              (DateTime.now().millisecondsSinceEpoch + index) % chars.length;
          return chars[idx];
        }).join();

    setState(() {
      _password = rand;
      _passwordController.text = _password;
      _updatePasswordStrength();
    });
  }

  void _updatePasswordStrength() {
    setState(() {
      _passwordStrength = PasswordStrengthHelper.calculatePasswordStrength(
        _password,
      );
      _crackTime = PasswordStrengthHelper.estimateCrackTime(_password);
    });
  }

  void _onGeneratePressed() {
    _generatePassword();
  }

  void _onOkPressed() {
    widget.onPasswordGenerated(_password, _length, _type);
    Navigator.of(context).pop();
  }

  void _onCancelPressed() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Password Generator',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Password display with refresh icon
            TextField(
              controller: _passwordController,
              readOnly: true,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                hintText: 'Generated password will appear here',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _onGeneratePressed,
                ),
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 8),

            // Password strength indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: _passwordStrength,
                    backgroundColor: Colors.grey[300],
                    color: _getStrengthColor(_passwordStrength),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Crack time: $_crackTime',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Length display and slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Length: $_length',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Slider(
              value: _length.toDouble(),
              min: 8,
              max: 64,
              divisions: 56,
              label: _length.toString(),
              onChanged: (value) {
                setState(() {
                  _length = value.toInt();
                  _generatePassword();
                });
              },
            ),

            const SizedBox(height: 16),

            // Password type dropdown
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButton<String>(
                value: _type,
                isExpanded: true,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(
                    value: 'Memorizable',
                    child: Text('Memorizable'),
                  ),
                  DropdownMenuItem(value: 'Numbers', child: Text('Numbers')),
                  DropdownMenuItem(value: 'Random', child: Text('Random')),
                  DropdownMenuItem(
                    value: 'Letters+Numbers',
                    child: Text('Letters+Numbers'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _type = value;
                      _generatePassword();
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _onCancelPressed,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _onOkPressed,
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
