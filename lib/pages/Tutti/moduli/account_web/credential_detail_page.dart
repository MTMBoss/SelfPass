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

  // Logo related state
  Color selectedColor = Colors.black;
  String? customSymbol;
  bool applyColorToEmoji = false;
  String? faviconUrl;

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

    // Initialize logo state from credential
    selectedColor =
        widget.credential.selectedColorValue != null
            ? Color.fromARGB(
              (widget.credential.selectedColorValue! >> 24) & 0xFF,
              (widget.credential.selectedColorValue! >> 16) & 0xFF,
              (widget.credential.selectedColorValue! >> 8) & 0xFF,
              widget.credential.selectedColorValue! & 0xFF,
            )
            : Colors.black;
    customSymbol = widget.credential.customSymbol;
    applyColorToEmoji = widget.credential.applyColorToEmoji;
    faviconUrl = widget.credential.faviconUrl;
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
      selectedColorValue: selectedColor.toARGB32(),
      customSymbol: customSymbol,
      applyColorToEmoji: applyColorToEmoji,
      faviconUrl: faviconUrl,
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
        onPressed: () async {
          if (isEditing) {
            _saveChanges();
          } else {
            // Navigate to AccountWebPage for editing existing credential
            final updatedCredential = await Navigator.of(
              context,
            ).push<Credential>(
              MaterialPageRoute(
                builder:
                    (context) => AccountWebPage(credential: widget.credential),
              ),
            );
            if (updatedCredential != null) {
              setState(() {
                // Update local state with updated credential data
                titoloController.text = updatedCredential.titolo;
                loginController.text = updatedCredential.login;
                passwordController.text = updatedCredential.password;
                sitoWebController.text = updatedCredential.sitoWeb;
                passwordMonousoController.text =
                    updatedCredential.passwordMonouso;
                noteController.text = updatedCredential.note;

                selectedColor =
                    updatedCredential.selectedColorValue != null
                        ? Color.fromARGB(
                          (updatedCredential.selectedColorValue! >> 24) & 0xFF,
                          (updatedCredential.selectedColorValue! >> 16) & 0xFF,
                          (updatedCredential.selectedColorValue! >> 8) & 0xFF,
                          updatedCredential.selectedColorValue! & 0xFF,
                        )
                        : Colors.black;
                customSymbol = updatedCredential.customSymbol;
                applyColorToEmoji = updatedCredential.applyColorToEmoji;
                faviconUrl = updatedCredential.faviconUrl;
              });
            }
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Titolo',
                      titoloController,
                      enabled: isEditing,
                    ),
                  ),
                  if (faviconUrl != null && faviconUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Image.network(
                        faviconUrl!,
                        width: 32,
                        height: 32,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported, size: 32),
                      ),
                    )
                  else if (customSymbol != null && customSymbol!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback:
                            (bounds) => LinearGradient(
                              colors: [selectedColor, selectedColor],
                            ).createShader(bounds),
                        child: Text(
                          customSymbol!,
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            shadows:
                                applyColorToEmoji
                                    ? [
                                      Shadow(
                                        offset: Offset(0, 0),
                                        blurRadius: 3,
                                        color: Colors.black.withAlpha(128),
                                      ),
                                    ]
                                    : null,
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: selectedColor,
                      ),
                    ),
                ],
              ),
            if (titoloController.text.isNotEmpty)
              // Removed duplicate title field here because it is already shown in Row with logo
              Container(),
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
