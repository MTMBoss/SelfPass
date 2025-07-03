// lib/pages/Tutti/moduli/account_web/credential_detail_page.dart

import 'package:flutter/material.dart';
import 'package:selfpass/modelli/credenziali.dart';
import 'modelli/account_web/account_web_page.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:selfpass/widgets/credential_icon.dart';

class CredentialDetailPage extends StatefulWidget {
  final Credential initialCredential;

  const CredentialDetailPage({super.key, required this.initialCredential});

  @override
  State<CredentialDetailPage> createState() => CredentialDetailPageState();
}

class CredentialDetailPageState extends State<CredentialDetailPage> {
  late Credential credential;

  @override
  void initState() {
    super.initState();
    credential = widget.initialCredential;
  }

  @override
  Widget build(BuildContext context) {
    Widget readOnlyField(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextField(
          controller: TextEditingController(text: value),
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
      );
    }

    String labelOf(CustomField cf) {
      final s = cf.type.toString();
      return s.substring(s.indexOf('.') + 1);
    }

    Widget buildImagePreview() {
      if (credential.imagePath == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (_) =>
                        FullScreenImagePage(imagePath: credential.imagePath!),
              ),
            );
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: Image.file(File(credential.imagePath!), fit: BoxFit.cover),
          ),
        ),
      );
    }

    Widget buildFilePreview() {
      if (credential.filePath == null) return const SizedBox.shrink();
      final fileName = credential.filePath!.split(Platform.pathSeparator).last;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: GestureDetector(
          onTap: () {
            OpenFile.open(credential.filePath!);
          },
          child: Text(
            fileName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              color: Colors.blue,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dettagli Credential')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Modifica',
        child: const Icon(Icons.edit),
        onPressed: () async {
          final updated = await Navigator.of(context).push<Credential>(
            MaterialPageRoute(
              builder: (_) => AccountWebPage(credential: credential),
            ),
          );
          if (updated != null) {
            setState(() {
              credential = updated;
            });
          }
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (credential.titolo.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      credential.titolo,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(width: 12),
                  CredentialIcon(credential, size: 32),
                ],
              ),
            const SizedBox(height: 16),
            if (credential.login.isNotEmpty)
              readOnlyField('Login', credential.login),
            if (credential.password.isNotEmpty)
              readOnlyField('Password', credential.password),
            if (credential.sitoWeb.isNotEmpty)
              readOnlyField('Sito Web', credential.sitoWeb),
            if (credential.passwordMonouso.isNotEmpty)
              readOnlyField('Password Monouso', credential.passwordMonouso),
            if (credential.note.isNotEmpty)
              readOnlyField('Note', credential.note),
            if (credential.customFields.isNotEmpty) const Divider(),
            for (final cf in credential.customFields)
              readOnlyField(labelOf(cf), cf.value),
            buildImagePreview(),
            buildFilePreview(),
          ],
        ),
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imagePath;

  const FullScreenImagePage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: InteractiveViewer(child: Image.file(File(imagePath))),
      ),
    );
  }
}
