import 'package:flutter/material.dart';
import 'services/encryption_service.dart';

Future<void> main() async {
  // Assicura l'inizializzazione di Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza il servizio di crittografia
  final encryptionService = EncryptionService();
  await encryptionService.init();

  // Test di crittografia e decifratura
  final String originalText = "TestoSegreto123!";
  final String cipherText = encryptionService.encrypt(originalText);
  final String decryptedText = encryptionService.decrypt(cipherText);

  runApp(
    MyApp(original: originalText, cipher: cipherText, decrypted: decryptedText),
  );
}

class MyApp extends StatelessWidget {
  final String original;
  final String cipher;
  final String decrypted;

  const MyApp({
    super.key,
    required this.original,
    required this.cipher,
    required this.decrypted,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Encryption Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text("Encryption Demo")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Originale:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(original),
              const SizedBox(height: 16),
              const Text(
                "Cifrato (Base64):",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(cipher),
              const SizedBox(height: 16),
              const Text(
                "Decifrato:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(decrypted),
            ],
          ),
        ),
      ),
    );
  }
}
