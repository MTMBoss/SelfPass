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

  @override
  void initState() {
    super.initState();
    credentials = CredentialStore().credentials;
    CredentialStore().addListener(_onCredentialsChanged);
  }

  @override
  void dispose() {
    CredentialStore().removeListener(_onCredentialsChanged);
    super.dispose();
  }

  void _onCredentialsChanged() {
    setState(() {
      credentials = CredentialStore().credentials;
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
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              title: Text(credential.titolo),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (credential.login.isNotEmpty)
                    Text('Login: ${credential.login}'),
                  if (credential.password.isNotEmpty)
                    Text('Password: ${credential.password}'),
                  if (credential.sitoWeb.isNotEmpty)
                    Text('Sito Web: ${credential.sitoWeb}'),
                  if (credential.passwordMonouso.isNotEmpty)
                    Text('Password Monouso: ${credential.passwordMonouso}'),
                  if (credential.note.isNotEmpty)
                    Text('Note: ${credential.note}'),
                ],
              ),
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
