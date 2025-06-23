// lib/pages/Tutti/tutti.dart
import 'package:flutter/material.dart';
import 'package:selfpass/models/credential.dart';
import 'package:selfpass/models/credential_store.dart';
import 'package:selfpass/pages/Tutti/moduli/account_web/credential_detail_page.dart';

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
    credentials = CredentialStore().credentials;
    CredentialStore().addListener(_onCredentialsChanged);
    for (int i = 0; i < credentials.length; i++) {
      _titleControllers[i] = TextEditingController(text: credentials[i].titolo);
    }
  }

  @override
  void dispose() {
    CredentialStore().removeListener(_onCredentialsChanged);
    for (final c in _titleControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onCredentialsChanged() {
    setState(() {
      credentials = CredentialStore().credentials;
      for (int i = 0; i < credentials.length; i++) {
        if (!_titleControllers.containsKey(i)) {
          _titleControllers[i] = TextEditingController(
            text: credentials[i].titolo,
          );
        } else {
          _titleControllers[i]!.text = credentials[i].titolo;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutti')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: credentials.length,
        itemBuilder: (context, index) {
          final credential = credentials[index];
          final titleController = _titleControllers[index]!;

          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              leading: Builder(
                builder: (context) {
                  // 1) custom emoji
                  if (credential.customSymbol != null) {
                    if (credential.applyColorToEmoji) {
                      final color =
                          credential.selectedColorValue != null
                              ? Color(credential.selectedColorValue!)
                              : Colors.black;
                      return ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback:
                            (bounds) => LinearGradient(
                              colors: [color, color],
                            ).createShader(bounds),
                        child: Text(
                          credential.customSymbol!,
                          style: const TextStyle(fontSize: 24),
                        ),
                      );
                    } else {
                      return Text(
                        credential.customSymbol!,
                        style: const TextStyle(fontSize: 24),
                      );
                    }
                  }
                  // 2) saved favicon
                  if (credential.faviconUrl != null &&
                      credential.faviconUrl!.isNotEmpty) {
                    return Image.network(
                      credential.faviconUrl!,
                      width: 24,
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        final bg =
                            credential.selectedColorValue != null
                                ? Color(credential.selectedColorValue!)
                                : Colors.black;
                        return CircleAvatar(radius: 12, backgroundColor: bg);
                      },
                    );
                  }
                  // 3) colored circle
                  final bgColor =
                      credential.selectedColorValue != null
                          ? Color(credential.selectedColorValue!)
                          : Colors.black;
                  return CircleAvatar(radius: 12, backgroundColor: bgColor);
                },
              ),
              title: Text(
                titleController.text,
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle:
                  credential.login.isNotEmpty
                      ? Text(
                        credential.login,
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                      : null,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            CredentialDetailPage(credential: credential),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
