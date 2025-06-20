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
  final Map<int, TextEditingController> _websiteControllers = {};

  @override
  void initState() {
    super.initState();
    credentials = CredentialStore().credentials;
    CredentialStore().addListener(_onCredentialsChanged);
    for (int i = 0; i < credentials.length; i++) {
      _titleControllers[i] = TextEditingController(text: credentials[i].titolo);
      _websiteControllers[i] = TextEditingController(
        text: credentials[i].sitoWeb,
      );
    }
  }

  @override
  void dispose() {
    CredentialStore().removeListener(_onCredentialsChanged);
    for (final controller in _titleControllers.values) {
      controller.dispose();
    }
    for (final controller in _websiteControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onCredentialsChanged() {
    setState(() {
      credentials = CredentialStore().credentials;
      // Update controllers for new credentials list
      for (int i = 0; i < credentials.length; i++) {
        if (!_titleControllers.containsKey(i)) {
          _titleControllers[i] = TextEditingController(
            text: credentials[i].titolo,
          );
        } else {
          _titleControllers[i]!.text = credentials[i].titolo;
        }
        if (!_websiteControllers.containsKey(i)) {
          _websiteControllers[i] = TextEditingController(
            text: credentials[i].sitoWeb,
          );
        } else {
          _websiteControllers[i]!.text = credentials[i].sitoWeb;
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
          final websiteController = _websiteControllers[index]!;

          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              title: Row(
                children: [
                  // Icon/logo on the left
                  Builder(
                    builder: (context) {
                      final urlText = websiteController.text.trim();
                      if (urlText.isEmpty) {
                        return const Icon(Icons.image);
                      }
                      Uri? uri;
                      try {
                        uri = Uri.parse(urlText);
                        if (!uri.hasScheme) {
                          uri = Uri.parse('https://$urlText');
                        }
                      } catch (e) {
                        uri = null;
                      }
                      if (uri == null || uri.host.isEmpty) {
                        return const Icon(Icons.image);
                      }
                      final faviconUri = Uri(
                        scheme: uri.scheme,
                        host: uri.host,
                        port: uri.hasPort ? uri.port : null,
                        path: '/favicon.ico',
                      );
                      return Image.network(
                        faviconUri.toString(),
                        width: 24,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.language);
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  // Title text
                  Expanded(
                    child: Text(
                      titleController.text,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
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
