import 'package:flutter/material.dart';
import 'package:selfpass/modelli/credenziali.dart';
import 'package:selfpass/modelli/archivio_credenziali.dart';

import 'package:selfpass/widgets/highlight_text.dart';
import 'package:selfpass/widgets/credential_icon.dart';

class PreferitiPage extends StatefulWidget {
  final String searchQuery;

  const PreferitiPage({super.key, this.searchQuery = ''});

  @override
  State<PreferitiPage> createState() => _PreferitiPageState();
}

class _PreferitiPageState extends State<PreferitiPage> {
  List<Credential> favoriteCredentials = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    CredentialStore().addListener(_loadFavorites);
  }

  void _loadFavorites() {
    final allCreds = CredentialStore().credentials;
    setState(() {
      favoriteCredentials =
          allCreds
              .where(
                (cred) =>
                    cred.isFavorite &&
                    (cred.titolo.toLowerCase().contains(
                          widget.searchQuery.toLowerCase(),
                        ) ||
                        cred.login.toLowerCase().contains(
                          widget.searchQuery.toLowerCase(),
                        )),
              )
              .toList();
    });
  }

  @override
  void didUpdateWidget(covariant PreferitiPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _loadFavorites();
    }
  }

  @override
  void dispose() {
    CredentialStore().removeListener(_loadFavorites);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (favoriteCredentials.isEmpty) {
      return const Center(
        child: Text('Nessun preferito', style: TextStyle(fontSize: 24)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteCredentials.length,
      itemBuilder: (context, index) {
        final cred = favoriteCredentials[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CredentialIcon(cred),
            title: HighlightText(
              source: cred.titolo,
              query: widget.searchQuery,
              style: Theme.of(context).textTheme.titleMedium!,
            ),
            subtitle:
                cred.login.isNotEmpty
                    ? HighlightText(
                      source: cred.login,
                      query: widget.searchQuery,
                      style: Theme.of(context).textTheme.bodySmall!,
                    )
                    : null,
          ),
        );
      },
    );
  }
}
