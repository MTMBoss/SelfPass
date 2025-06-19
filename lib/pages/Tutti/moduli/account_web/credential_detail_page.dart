import 'package:flutter/material.dart';
import 'package:selfpass/models/credential.dart';
import 'package:selfpass/models/credential_store.dart';

import 'account_web_page.dart';

class CredentialDetailPage extends StatefulWidget {
  final Credential credential;

  const CredentialDetailPage({super.key, required this.credential});

  @override
  State<CredentialDetailPage> createState() => _CredentialDetailPageState();
}

class _CredentialDetailPageState extends State<CredentialDetailPage> {
  late bool isEditing;

  late TextEditingController titoloController;
  late TextEditingController loginController;
  late TextEditingController passwordController;
  late TextEditingController sitoWebController;
  late TextEditingController passwordMonousoController;
  late TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    isEditing = false;

    titoloController = TextEditingController(text: widget.credential.titolo);
    loginController = TextEditingController(text: widget.credential.login);
    passwordController = TextEditingController(
      text: widget.credential.password,
    );
    sitoWebController = TextEditingController(text: widget.credential.sitoWeb);
    passwordMonousoController = TextEditingController(
      text: widget.credential.passwordMonouso,
    );
    noteController = TextEditingController(text: widget.credential.note);
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

  void _saveChanges() {
    final updatedCredential = Credential(
      titolo: titoloController.text,
      login: loginController.text,
      password: passwordController.text,
      sitoWeb: sitoWebController.text,
      passwordMonouso: passwordMonousoController.text,
      note: noteController.text,
    );

    final store = CredentialStore();
    // Remove old credential and add updated one
    store.removeCredential(widget.credential);
    store.addCredential(updatedCredential);

    setState(() {
      isEditing = false;
    });

    Navigator.of(context).pop();
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool enabled = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: enabled ? const OutlineInputBorder() : InputBorder.none,
        ),
        maxLines: null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Credential' : 'Credential Details'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isEditing) {
            _saveChanges();
          } else {
            // Navigate to AccountWebPage for editing existing credential
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => AccountWebPage(credential: widget.credential),
              ),
            );
          }
        },
        tooltip: isEditing ? 'Save' : 'Edit',
        child: Icon(isEditing ? Icons.save : Icons.edit),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (titoloController.text.isNotEmpty)
              _buildTextField('Titolo', titoloController, enabled: isEditing),
            if (loginController.text.isNotEmpty)
              _buildTextField('Login', loginController, enabled: isEditing),
            if (passwordController.text.isNotEmpty)
              _buildTextField(
                'Password',
                passwordController,
                enabled: isEditing,
              ),
            if (sitoWebController.text.isNotEmpty)
              _buildTextField(
                'Sito Web',
                sitoWebController,
                enabled: isEditing,
              ),
            if (passwordMonousoController.text.isNotEmpty)
              _buildTextField(
                'Password Monouso',
                passwordMonousoController,
                enabled: isEditing,
              ),
            if (noteController.text.isNotEmpty)
              _buildTextField('Note', noteController, enabled: isEditing),
          ],
        ),
      ),
    );
  }
}
