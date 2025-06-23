import 'package:flutter/material.dart';
import '../../Campi/titolo_campo.dart';

import '../../Campi/campi_normali.dart';
import '../../Campi/campi_login.dart';
import '../../Campi/campi_chiave.dart';
import '../../Campi/campo_qr.dart';

import 'package:selfpass/models/credential.dart';
import 'package:selfpass/models/credential_store.dart';

class AccountWebPage extends StatefulWidget {
  final Credential? credential;

  const AccountWebPage({super.key, this.credential});

  @override
  State<AccountWebPage> createState() => _AccountWebPageState();
}

class _AccountWebPageState extends State<AccountWebPage> {
  late TextEditingController titoloController;
  late TextEditingController loginController;
  late TextEditingController passwordController;
  late TextEditingController sitoWebController;
  late TextEditingController passwordMonousoController;
  late TextEditingController noteController;

  bool showTitolo = true;
  bool showLogin = true;
  bool showPassword = true;
  bool showSitoWeb = true;
  bool showPasswordMonouso = true;
  bool showNote = true;

  // New logo state variables
  Color selectedColor = Colors.black;
  String? customSymbol;
  bool applyColorToEmoji = false;
  String? faviconUrl;

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

  @override
  void initState() {
    super.initState();
    final c = widget.credential;
    titoloController = TextEditingController(text: c?.titolo ?? '');
    loginController = TextEditingController(text: c?.login ?? '');
    passwordController = TextEditingController(text: c?.password ?? '');
    sitoWebController = TextEditingController(text: c?.sitoWeb ?? '');
    passwordMonousoController = TextEditingController(
      text: c?.passwordMonouso ?? '',
    );
    noteController = TextEditingController(text: c?.note ?? '');

    showTitolo = true;
    showLogin = c == null ? true : c.showLogin;
    showPassword = c == null ? true : c.showPassword;
    showSitoWeb = c == null ? true : c.showSitoWeb;
    showPasswordMonouso = c == null ? true : c.showPasswordMonouso;
    showNote = c == null ? true : c.showNote;

    // Initialize logo state from credential
    if (c != null) {
      selectedColor =
          c.selectedColorValue != null
              ? Color.fromARGB(
                (c.selectedColorValue! >> 24) & 0xFF,
                (c.selectedColorValue! >> 16) & 0xFF,
                (c.selectedColorValue! >> 8) & 0xFF,
                c.selectedColorValue! & 0xFF,
              )
              : Colors.black;
      customSymbol = c.customSymbol;
      applyColorToEmoji = c.applyColorToEmoji;
      faviconUrl = c.faviconUrl;
    }
  }

  void _saveCredentials() {
    final credential = Credential(
      titolo: showTitolo ? titoloController.text : '',
      login: showLogin ? loginController.text : '',
      password: showPassword ? passwordController.text : '',
      sitoWeb: showSitoWeb ? sitoWebController.text : '',
      passwordMonouso:
          showPasswordMonouso ? passwordMonousoController.text : '',
      note: showNote ? noteController.text : '',
      showLogin: showLogin,
      showPassword: showPassword,
      showSitoWeb: showSitoWeb,
      showPasswordMonouso: showPasswordMonouso,
      showNote: showNote,
      selectedColorValue: selectedColor.toARGB32(),
      customSymbol: customSymbol,
      applyColorToEmoji: applyColorToEmoji,
      faviconUrl: faviconUrl,
    );

    final store = CredentialStore();
    if (widget.credential != null) {
      store.removeCredential(widget.credential!);
    }
    store.addCredential(credential);

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
                sitoWebController: sitoWebController,
                selectedColor: selectedColor,
                customSymbol: customSymbol,
                applyColorToEmoji: applyColorToEmoji,
                faviconUrl: faviconUrl,
                onSelectedColorChanged: (color) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        selectedColor = color;
                      });
                    }
                  });
                },
                onCustomSymbolChanged: (symbol) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        customSymbol = symbol;
                      });
                    }
                  });
                },
                onApplyColorToEmojiChanged: (apply) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        applyColorToEmoji = apply;
                      });
                    }
                  });
                },
                onFaviconUrlChanged: (url) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        faviconUrl = url;
                      });
                    }
                  });
                },
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
