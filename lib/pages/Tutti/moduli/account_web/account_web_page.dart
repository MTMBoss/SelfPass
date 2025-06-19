import 'package:flutter/material.dart';

import '../../Campi/campi_normali.dart';
import '../../Campi/campi_login.dart';
import '../../Campi/campi_chiave.dart';
import '../../Campi/campo_qr.dart';

class AccountWebPage extends StatefulWidget {
  const AccountWebPage({super.key});

  @override
  State<AccountWebPage> createState() => _AccountWebPageState();
}

class _AccountWebPageState extends State<AccountWebPage> {
  final TextEditingController titoloController = TextEditingController();
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController sitoWebController = TextEditingController();
  final TextEditingController passwordMonousoController =
      TextEditingController();
  final TextEditingController noteController = TextEditingController();

  bool showTitolo = true;
  bool showLogin = true;
  bool showPassword = true;
  bool showSitoWeb = true;
  bool showPasswordMonouso = true;
  bool showNote = true;

  void removeField(String field) {
    setState(() {
      switch (field) {
        case 'titolo':
          // Do not remove titolo field as per user feedback
          break;
        case 'login':
          showLogin = false;
          break;
        case 'password':
          showPassword = false;
          break;
        case 'sitoWeb':
          showSitoWeb = false;
          break;
        case 'passwordMonouso':
          showPasswordMonouso = false;
          break;
        case 'note':
          showNote = false;
          break;
      }
    });
  }

  @override
  void dispose() {
    titoloController.dispose();
    loginController.dispose();
    passwordController.dispose();
    sitoWebController.dispose();
    passwordMonousoController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _saveCredentials() {
    // Placeholder save function: collect data and log it
    final titolo = titoloController.text;
    final login = loginController.text;
    final password = passwordController.text;
    final sitoWeb = sitoWebController.text;
    final passwordMonouso = passwordMonousoController.text;
    final note = noteController.text;

    // Use debugPrint instead of print for better logging in Flutter
    debugPrint('Saving credentials:');
    debugPrint('Titolo: $titolo');
    debugPrint('Login: $login');
    debugPrint('Password: $password');
    debugPrint('Sito Web: $sitoWeb');
    debugPrint('Password Monouso: $passwordMonouso');
    debugPrint('Note: $note');

    // Implement actual save logic here

    // Optionally, navigate back after saving
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Web'),
        leading: IconButton(
          icon: const Icon(Icons.check),
          onPressed: _saveCredentials,
          tooltip: 'Save credentials',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (showTitolo) ...[
              TitoloCampo(
                controller: titoloController,
                // Remove the onRemove callback to hide the "x" button
              ),
              const SizedBox(height: 12),
            ],
            if (showLogin) ...[
              LoginCampo(
                controller: loginController,
                onRemove: () {
                  removeField('login');
                },
              ),
              const SizedBox(height: 12),
            ],
            if (showPassword) ...[
              PasswordCampo(
                controller: passwordController,
                obscureText: false,
                onRemove: () {
                  removeField('password');
                },
              ),
              const SizedBox(height: 12),
            ],
            if (showSitoWeb) ...[
              SitoWebCampo(
                controller: sitoWebController,
                onRemove: () {
                  removeField('sitoWeb');
                },
              ),
              const SizedBox(height: 12),
            ],
            if (showPasswordMonouso) ...[
              PasswordMonousoCampo(
                controller: passwordMonousoController,
                onRemove: () {
                  removeField('passwordMonouso');
                },
              ),
              const SizedBox(height: 12),
            ],
            if (showNote) ...[
              NoteCampo(
                controller: noteController,
                onRemove: () {
                  removeField('note');
                },
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
