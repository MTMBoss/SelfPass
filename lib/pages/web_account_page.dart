import 'package:flutter/material.dart';
import '../helpers/password_strength_helper.dart';
import '../widgets/password_generator_dialog.dart';

class WebAccountPage extends StatefulWidget {
  const WebAccountPage({super.key});

  @override
  WebAccountPageState createState() => WebAccountPageState();
}

class WebAccountPageState extends State<WebAccountPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _passwordVisible = false;
  double _passwordStrength = 0;
  String _passwordStrengthLabel = '';
  String _passwordCrackTime = '';

  // Password generator state
  bool _showPasswordGenerator = false;
  int _generatedPasswordLength = 12;
  String _generatedPasswordType =
      'Random'; // Options: Memorizable, Numbers, Random, Letters+Numbers
  String _generatedPassword = '';
  final TextEditingController _generatedPasswordController =
      TextEditingController();

  // Additional fields
  List<Widget> additionalFields = [];

  // Saved logins example (in real app, load from storage)
  List<String> savedLogins = ['user@example.com', 'admin@site.com', 'testuser'];

  // Icon selection mode
  String _iconSelectionMode =
      'Website Icon'; // Other options: Symbol, Color, Custom Icon

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _websiteController.dispose();
    _otpController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    final strength = PasswordStrengthHelper.calculatePasswordStrength(password);
    final label = PasswordStrengthHelper.getStrengthLabel(strength);
    final crackTime = PasswordStrengthHelper.estimateCrackTime(password);

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthLabel = label;
      _passwordCrackTime = crackTime;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  void _openPasswordGenerator() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PasswordGeneratorDialog(
          initialLength: _generatedPasswordLength,
          initialType: _generatedPasswordType,
          initialPassword: _generatedPassword,
          onPasswordGenerated: (password, length, type) {
            setState(() {
              _generatedPassword = password;
              _generatedPasswordLength = length;
              _generatedPasswordType = type;
              _passwordController.text = password;
            });
          },
        );
      },
    );
  }

  void _closePasswordGenerator() {
    setState(() {
      _showPasswordGenerator = false;
    });
  }

  void _generatePassword() {
    final length = _generatedPasswordLength;
    final type = _generatedPasswordType;
    const letters = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()-_=+[]{}|;:,.<>?';

    String chars = '';
    switch (type) {
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
        List.generate(length, (index) {
          final idx =
              (DateTime.now().millisecondsSinceEpoch + index) % chars.length;
          return chars[idx];
        }).join();

    setState(() {
      _generatedPassword = rand;
    });
  }

  void _applyGeneratedPassword() {
    _passwordController.text = _generatedPassword;
    _closePasswordGenerator();
  }

  void _addAnotherField() {
    setState(() {
      additionalFields.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Additional Field',
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      );
    });
  }

  void _selectSavedLogin(String login) {
    setState(() {
      _loginController.text = login;
    });
  }

  void _selectIconMode(String mode) {
    setState(() {
      _iconSelectionMode = mode;
    });
  }

  void _scanQRCode() {
    // Placeholder for QR code scanning functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Code scanner not implemented')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Account'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _selectIconMode,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'Website Icon',
                    child: Text('Website Icon'),
                  ),
                  const PopupMenuItem(value: 'Symbol', child: Text('Symbol')),
                  const PopupMenuItem(value: 'Color', child: Text('Color')),
                  const PopupMenuItem(
                    value: 'Custom Icon',
                    child: Text('Custom Icon'),
                  ),
                ],
            icon: const Icon(Icons.image),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with icon selection mode display
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 20,
                  child: Icon(_getIconForMode(_iconSelectionMode)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Login with saved logins dropdown
            TextFormField(
              controller: _loginController,
              decoration: InputDecoration(
                labelText: 'Login',
                suffixIcon: PopupMenuButton<String>(
                  icon: const Icon(Icons.person),
                  onSelected: _selectSavedLogin,
                  itemBuilder:
                      (context) =>
                          savedLogins
                              .map(
                                (login) => PopupMenuItem(
                                  value: login,
                                  child: Text(login),
                                ),
                              )
                              .toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Password with visibility toggle, strength meter, and generator icon
            TextFormField(
              controller: _passwordController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                    IconButton(
                      icon: const Icon(Icons.vpn_key),
                      onPressed: _openPasswordGenerator,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Password strength meter
            LinearProgressIndicator(
              value: _passwordStrength,
              backgroundColor: Colors.grey[300],
              color:
                  _passwordStrength < 0.5
                      ? Colors.red
                      : _passwordStrength < 0.75
                      ? Colors.orange
                      : Colors.green,
              minHeight: 6,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_passwordStrengthLabel),
                Text('Crack time: $_passwordCrackTime'),
              ],
            ),
            const SizedBox(height: 16),

            // Website input
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // One-time password (2FA) with QR code scanner
            TextFormField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: 'One-time password (2FA)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code),
                  onPressed: _scanQRCode,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Add another field button
            ElevatedButton(
              onPressed: _addAnotherField,
              child: const Text('ADD ANOTHER FIELD'),
            ),
            const SizedBox(height: 16),

            // Additional fields
            ...additionalFields,

            // Notes input
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Attach image and attach file buttons
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Attach image not implemented')),
                );
              },
              child: const Text('ATTACH IMAGE'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Attach file not implemented')),
                );
              },
              child: const Text('ATTACH FILE'),
            ),

            // Password generator popup
            if (_showPasswordGenerator) _buildPasswordGeneratorPopup(),
          ],
        ),
      ),
    );
  }

  IconData _getIconForMode(String mode) {
    switch (mode) {
      case 'Website Icon':
        return Icons.language;
      case 'Symbol':
        return Icons.star;
      case 'Color':
        return Icons.color_lens;
      case 'Custom Icon':
        return Icons.image;
      default:
        return Icons.language;
    }
  }

  Widget _buildPasswordGeneratorPopup() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Generate Password',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFd4b87a),
                ),
              ),
              const SizedBox(height: 16),

              // Password display with refresh icon
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _generatedPasswordController,
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
                    onPressed: () {
                      _generatePassword();
                      _generatedPasswordController.text = _generatedPassword;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Password strength segmented bar
              Row(
                children: List.generate(4, (index) {
                  Color color;
                  if (_passwordStrength >= (index + 1) * 0.25) {
                    color = Colors.green;
                  } else if (_passwordStrength > index * 0.25) {
                    color = Colors.lightGreen;
                  } else {
                    color = Colors.grey[300]!;
                  }
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 6,
                      color: color,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 4),

              Text(
                'Crack time: $_passwordCrackTime',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),

              const SizedBox(height: 16),

              // Password length slider with label below
              Slider(
                value: _generatedPasswordLength.toDouble(),
                min: 8,
                max: 64,
                divisions: 56,
                label: _generatedPasswordLength.toString(),
                onChanged: (value) {
                  setState(() {
                    _generatedPasswordLength = value.toInt();
                    _generatePassword();
                    _generatedPasswordController.text = _generatedPassword;
                  });
                },
              ),
              Center(child: Text('Length: $_generatedPasswordLength')),

              const SizedBox(height: 16),

              // Password type dropdown with updated options
              DropdownButton<String>(
                value: _generatedPasswordType,
                items: const [
                  DropdownMenuItem(
                    value: 'Memorable',
                    child: Text('Memorable'),
                  ),
                  DropdownMenuItem(
                    value: 'Letters and numbers',
                    child: Text('Letters and numbers'),
                  ),
                  DropdownMenuItem(value: 'Random', child: Text('Random')),
                  DropdownMenuItem(
                    value: 'Numbers only',
                    child: Text('Numbers only'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _generatedPasswordType = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // OK and Cancel buttons aligned to bottom right
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _closePasswordGenerator,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _applyGeneratedPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFd4b87a),
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
