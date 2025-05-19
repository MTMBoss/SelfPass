import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _length = widget.initialLength;
    _type = widget.initialType;
    _password = widget.initialPassword;
    _passwordController = TextEditingController(text: _password);
    _generatePassword();
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _passwordController,
                    readOnly: false,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      hintText: 'Generated password will appear here',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFFd4b87a)),
                  onPressed: _onGeneratePressed,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Password length slider
            Row(
              children: [
                const Text('Length:'),
                Expanded(
                  child: Slider(
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
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Password type dropdown
            DropdownButton<String>(
              value: _type,
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

            const SizedBox(height: 16),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _onGeneratePressed,
                  child: const Text('Generate'),
                ),
                ElevatedButton(
                  onPressed: _onOkPressed,
                  child: const Text('OK'),
                ),
                ElevatedButton(
                  onPressed: _onCancelPressed,
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
