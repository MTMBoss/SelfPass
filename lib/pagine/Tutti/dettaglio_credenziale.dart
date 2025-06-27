// lib/pages/Tutti/moduli/account_web/credential_detail_page.dart

import 'package:flutter/material.dart';
import 'package:selfpass/modelli/credenziali.dart';
import 'modelli/account_web/account_web_page.dart';

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
    final color =
        credential.selectedColorValue != null
            ? Color(credential.selectedColorValue!)
            : Colors.black;

    Widget buildIcon() {
      if (credential.customSymbol?.isNotEmpty == true) {
        if (credential.applyColorToEmoji) {
          return ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback:
                (bounds) =>
                    LinearGradient(colors: [color, color]).createShader(bounds),
            child: Text(
              credential.customSymbol!,
              style: const TextStyle(fontSize: 32),
            ),
          );
        }
        return Text(
          credential.customSymbol!,
          style: const TextStyle(fontSize: 32),
        );
      }
      if (credential.faviconUrl?.isNotEmpty == true) {
        return Image.network(
          credential.faviconUrl!,
          width: 32,
          height: 32,
          errorBuilder:
              (_, __, ___) => CircleAvatar(radius: 16, backgroundColor: color),
        );
      }
      return CircleAvatar(radius: 16, backgroundColor: color);
    }

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
                  buildIcon(),
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
          ],
        ),
      ),
    );
  }
}
