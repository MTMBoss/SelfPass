import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  late String
  _type; // ad esempio "Random", "Memorizable", "Numbers", "Letters+Numbers"
  late String _generatedPassword;
  double _entropy = 0;
  String _strengthLabel = "";
  String _crackTime = "";

  @override
  void initState() {
    super.initState();
    _length = widget.initialLength;
    _type = widget.initialType;
    _generatedPassword = widget.initialPassword;
    _generatePassword();
  }

  /// Genera la password usando il set di caratteri in base al tipo selezionato.
  void _generatePassword() {
    const String lowercase = "abcdefghijklmnopqrstuvwxyz";
    const String uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const String numbers = "0123456789";
    const String symbols = "!@#\$%^&*()-_=+[]{}|;:,.<>?";

    String availableChars = "";
    switch (_type) {
      case "Memorizable":
        availableChars = "aeioulnrst";
        break;
      case "Numbers":
        availableChars = numbers;
        break;
      case "Letters+Numbers":
        availableChars = lowercase + uppercase + numbers;
        break;
      case "Random":
      default:
        availableChars = lowercase + uppercase + numbers + symbols;
        break;
    }
    // Assicuriamoci che sia disponibile almeno un gruppo
    if (availableChars.isEmpty) {
      availableChars = lowercase;
    }

    final random = Random.secure();
    String password =
        List.generate(
          _length,
          (_) => availableChars[random.nextInt(availableChars.length)],
        ).join();

    setState(() {
      _generatedPassword = password;
      _entropy = _calculateEntropy(availableChars);
      _strengthLabel = _getStrengthLabel(_entropy);
      _crackTime = _estimateCrackTime(_entropy);
    });
  }

  /// Calcola l’entropia stimata (in bit) come: lunghezza * log₂(pool dei caratteri)
  double _calculateEntropy(String availableChars) {
    int poolSize = availableChars.length;
    return _length * (log(poolSize) / log(2));
  }

  /// Restituisce una label basata sui bit di entropia.
  String _getStrengthLabel(double entropy) {
    if (entropy < 28) return "Very Weak";
    if (entropy < 35) return "Weak";
    if (entropy < 59) return "Reasonable";
    if (entropy < 127) return "Strong";
    return "Very Strong";
  }

  /// Stima il tempo di cracking (basato su un tasso di 10^10 ipotesi/s)
  String _estimateCrackTime(double entropy) {
    double totalGuesses = pow(2, entropy).toDouble();
    double seconds = totalGuesses / 1e10;
    if (seconds < 60) return "${seconds.toStringAsFixed(0)} seconds";
    double minutes = seconds / 60;
    if (minutes < 60) return "${minutes.toStringAsFixed(0)} minutes";
    double hours = minutes / 60;
    if (hours < 24) return "${hours.toStringAsFixed(0)} hours";
    double days = hours / 24;
    if (days < 365) return "${days.toStringAsFixed(0)} days";
    double years = days / 365;
    return "${years.toStringAsFixed(1)} years";
  }

  /// Copia la password negli appunti e mostra uno SnackBar
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatedPassword));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password copied to clipboard")),
    );
  }

  void _onGeneratePressed() {
    _generatePassword();
  }

  void _onOkPressed() {
    widget.onPasswordGenerated(_generatedPassword, _length, _type);
    Navigator.of(context).pop();
  }

  void _onCancelPressed() {
    Navigator.of(context).pop();
  }

  void _onTypeChanged(String? newType) {
    if (newType != null) {
      setState(() {
        _type = newType;
        _generatePassword();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Password Generator',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Campo per visualizzare la password generata con l'icona per copiarla
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(
                        text: _generatedPassword,
                      ),
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: _copyToClipboard,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Slider per la lunghezza della password
              Row(
                children: [
                  Text("Length: $_length"),
                  Expanded(
                    child: Slider(
                      value: _length.toDouble(),
                      min: 6,
                      max: 64,
                      divisions: 58,
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
              // Dropdown per il tipo di password
              DropdownButton<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(
                    value: "Memorizable",
                    child: Text("Memorizable"),
                  ),
                  DropdownMenuItem(value: "Numbers", child: Text("Numbers")),
                  DropdownMenuItem(value: "Random", child: Text("Random")),
                  DropdownMenuItem(
                    value: "Letters+Numbers",
                    child: Text("Letters+Numbers"),
                  ),
                ],
                onChanged: _onTypeChanged,
              ),
              const SizedBox(height: 16),
              // Aggiungiamo qui il nuovo pulsante per cambiare password
              ElevatedButton(
                onPressed: _onGeneratePressed,
                child: const Text("Change Password"),
              ),
              const SizedBox(height: 16),
              // Indicatore di forza e stima del tempo di cracking
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Strength: $_strengthLabel"),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: _entropy / 100, // Scala arbitraria per la UI
                      backgroundColor: Colors.grey[300],
                      color:
                          _entropy < 28
                              ? Colors.red
                              : _entropy < 35
                              ? Colors.orange
                              : _entropy < 59
                              ? Colors.yellow
                              : Colors.green,
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("Estimated crack time: $_crackTime"),
                ],
              ),
              const SizedBox(height: 16),
              // Pulsanti di azione: Cancel e OK
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _onCancelPressed,
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _onOkPressed,
                    child: const Text("OK"),
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
