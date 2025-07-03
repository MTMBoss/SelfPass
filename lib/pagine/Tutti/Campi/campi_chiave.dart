import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

enum PasswordType { memorizzabile, lettereNumeri, random, soloNumeri }

class PasswordGeneratorDialog extends StatefulWidget {
  const PasswordGeneratorDialog({super.key});

  @override
  State<PasswordGeneratorDialog> createState() =>
      PasswordGeneratorDialogState();
}

class PasswordGeneratorDialogState extends State<PasswordGeneratorDialog> {
  int length = 12;
  PasswordType passwordType = PasswordType.random;

  bool includeUppercase = true;
  bool includeNumbers = true;
  bool includeSymbols = true;

  String generatedPassword = '';
  String crackTimeEstimate = '';

  static const String lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
  static const String uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String numberChars = '0123456789';
  static const String symbolChars = '!@#\$%^&*()-_=+[]{}|;:,.<>?';

  @override
  void initState() {
    super.initState();
    generatePassword();
  }

  void generatePassword() {
    String chars = '';
    switch (passwordType) {
      case PasswordType.memorizzabile:
        chars = lowercaseChars + numberChars;
        break;
      case PasswordType.lettereNumeri:
        chars = lowercaseChars + uppercaseChars + numberChars;
        break;
      case PasswordType.random:
        chars = lowercaseChars;
        if (includeUppercase) chars += uppercaseChars;
        if (includeNumbers) chars += numberChars;
        if (includeSymbols) chars += symbolChars;
        break;
      case PasswordType.soloNumeri:
        chars = numberChars;
        break;
    }

    if (chars.isEmpty) {
      setState(() {
        generatedPassword = '';
        crackTimeEstimate = '';
      });
      return;
    }

    final rand = Random.secure();
    final password =
        List.generate(
          length,
          (index) => chars[rand.nextInt(chars.length)],
        ).join();

    setState(() {
      generatedPassword = password;
      crackTimeEstimate = estimateCrackTime(password);
    });
  }

  String estimateCrackTime(String password) {
    const guessesPerSecond = 1e9;

    int poolSize = 0;
    if (password.contains(RegExp(r'[a-z]'))) poolSize += 26;
    if (password.contains(RegExp(r'[A-Z]'))) poolSize += 26;
    if (password.contains(RegExp(r'[0-9]'))) poolSize += 10;
    if (password.contains(RegExp(r'[!@#\$%^&*()\-_=+\[\]{}|;:,.<>?]'))) {
      poolSize += 32;
    }

    double combinations = pow(poolSize, password.length).toDouble();
    double seconds = combinations / guessesPerSecond;

    if (seconds < 1) return 'Molto veloce da craccare';
    if (seconds < 60) return '${seconds.toStringAsFixed(0)} secondi';
    if (seconds < 3600) return '${(seconds / 60).toStringAsFixed(0)} minuti';
    if (seconds < 86400) return '${(seconds / 3600).toStringAsFixed(0)} ore';
    if (seconds < 31536000) {
      return '${(seconds / 86400).toStringAsFixed(0)} giorni';
    }
    if (seconds < 3153600000) {
      return '${(seconds / 31536000).toStringAsFixed(0)} anni';
    }
    return 'Molto difficile da craccare';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Genera Password'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Password Preview
              Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      generatedPassword,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      if (generatedPassword.isNotEmpty) {
                        Clipboard.setData(
                          ClipboardData(text: generatedPassword),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password copiata')),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: generatePassword,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Tempo stimato per craccare: $crackTimeEstimate'),
              const SizedBox(height: 16),

              // Slider lunghezza
              Row(
                children: [
                  const Text('Lunghezza:'),
                  const SizedBox(width: 8),
                  Text(length.toString()),
                ],
              ),
              Slider(
                value: length.toDouble(),
                min: 6,
                max: 32,
                divisions: 26,
                label: length.toString(),
                onChanged: (value) {
                  setState(() {
                    length = value.toInt();
                    generatePassword();
                  });
                },
              ),

              const Divider(),

              // Tipo password
              Column(
                children: [
                  RadioListTile<PasswordType>(
                    title: const Text('Memorizzabile'),
                    value: PasswordType.memorizzabile,
                    groupValue: passwordType,
                    onChanged: (value) {
                      setState(() {
                        passwordType = value!;
                        generatePassword();
                      });
                    },
                  ),
                  RadioListTile<PasswordType>(
                    title: const Text('Lettere e numeri'),
                    value: PasswordType.lettereNumeri,
                    groupValue: passwordType,
                    onChanged: (value) {
                      setState(() {
                        passwordType = value!;
                        generatePassword();
                      });
                    },
                  ),
                  RadioListTile<PasswordType>(
                    title: const Text('Random'),
                    value: PasswordType.random,
                    groupValue: passwordType,
                    onChanged: (value) {
                      setState(() {
                        passwordType = value!;
                        generatePassword();
                      });
                    },
                  ),
                  RadioListTile<PasswordType>(
                    title: const Text('Solo numeri'),
                    value: PasswordType.soloNumeri,
                    groupValue: passwordType,
                    onChanged: (value) {
                      setState(() {
                        passwordType = value!;
                        generatePassword();
                      });
                    },
                  ),
                ],
              ),

              // Checkbox solo per tipo random
              if (passwordType == PasswordType.random) ...[
                const Divider(),
                CheckboxListTile(
                  title: const Text('Lettere maiuscole'),
                  value: includeUppercase,
                  onChanged: (val) {
                    setState(() {
                      includeUppercase = val!;
                      generatePassword();
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Numeri'),
                  value: includeNumbers,
                  onChanged: (val) {
                    setState(() {
                      includeNumbers = val!;
                      generatePassword();
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Simboli'),
                  value: includeSymbols,
                  onChanged: (val) {
                    setState(() {
                      includeSymbols = val!;
                      generatePassword();
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed:
              generatedPassword.isEmpty
                  ? null
                  : () => Navigator.of(context).pop(generatedPassword),
          child: const Text('Usa Password'),
        ),
      ],
    );
  }
}
