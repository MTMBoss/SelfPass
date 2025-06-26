// lib/pages/Tutti/tutti.dart

import 'package:flutter/material.dart';
import 'package:selfpass/models/credential.dart';
import 'package:selfpass/models/credential_store.dart';
// Import relativo alla DetailPage
import 'moduli/account_web/credential_detail_page.dart';

class TuttiPage extends StatefulWidget {
  const TuttiPage({super.key});

  @override
  State<TuttiPage> createState() => _TuttiPageState();
}

class _TuttiPageState extends State<TuttiPage> {
  List<Credential> credentials = [];
  final Map<int, TextEditingController> _titleControllers = {};

  @override
  void initState() {
    super.initState();
    _loadCredentials();
    CredentialStore().addListener(_loadCredentials);
  }

  void _loadCredentials() {
    credentials = CredentialStore().credentials;
    _titleControllers
      ..forEach((_, ctrl) => ctrl.dispose())
      ..clear();
    for (var i = 0; i < credentials.length; i++) {
      _titleControllers[i] = TextEditingController(text: credentials[i].titolo);
    }
    setState(() {});
  }

  @override
  void dispose() {
    CredentialStore().removeListener(_loadCredentials);
    for (var ctrl in _titleControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutti')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: credentials.length,
        itemBuilder: (context, index) {
          final cred = credentials[index];
          final titleCtrl = _titleControllers[index]!;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: _buildIcon(cred),
              title: Text(
                titleCtrl.text,
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle:
                  cred.login.isNotEmpty
                      ? Text(
                        cred.login,
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                      : null,
              onTap: () async {
                final updated = await Navigator.of(context).push<Credential>(
                  MaterialPageRoute(
                    builder:
                        (_) => CredentialDetailPage(initialCredential: cred),
                  ),
                );
                if (updated != null) {
                  // aggiorna lista e titolo in place
                  credentials[index] = updated;
                  titleCtrl.text = updated.titolo;
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildIcon(Credential cred) {
    // custom symbol
    if (cred.customSymbol?.isNotEmpty == true) {
      if (cred.applyColorToEmoji) {
        final col =
            cred.selectedColorValue != null
                ? Color(cred.selectedColorValue!)
                : Colors.black;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback:
              (bounds) =>
                  LinearGradient(colors: [col, col]).createShader(bounds),
          child: Text(cred.customSymbol!, style: const TextStyle(fontSize: 24)),
        );
      }
      return Text(cred.customSymbol!, style: const TextStyle(fontSize: 24));
    }
    // favicon
    if (cred.faviconUrl?.isNotEmpty == true) {
      return Image.network(
        cred.faviconUrl!,
        width: 24,
        height: 24,
        errorBuilder: (_, __, ___) {
          final bg =
              cred.selectedColorValue != null
                  ? Color(cred.selectedColorValue!)
                  : Colors.black;
          return CircleAvatar(radius: 12, backgroundColor: bg);
        },
      );
    }
    // fallback: colored circle
    final bg =
        cred.selectedColorValue != null
            ? Color(cred.selectedColorValue!)
            : Colors.black;
    return CircleAvatar(radius: 12, backgroundColor: bg);
  }
}
