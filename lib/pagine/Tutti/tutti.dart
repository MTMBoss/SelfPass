// lib/pages/Tutti/tutti.dart

import 'package:flutter/material.dart';
import 'package:selfpass/modelli/credenziali.dart';
import 'package:selfpass/modelli/archivio_credenziali.dart';
// Import relativo alla DetailPage
import 'dettaglio_credenziale.dart';

class Match {
  final int start;
  final int end;
  Match(this.start, this.end);
}

TextSpan _highlightOccurrences(String source, String query, TextStyle style) {
  if (query.isEmpty) {
    return TextSpan(text: source, style: style);
  }
  final matches = <Match>[];
  final queryLower = query.toLowerCase();
  final sourceLower = source.toLowerCase();
  int start = 0;
  while (true) {
    final index = sourceLower.indexOf(queryLower, start);
    if (index == -1) break;
    matches.add(Match(index, index + query.length));
    start = index + query.length;
  }
  if (matches.isEmpty) {
    return TextSpan(text: source, style: style);
  }
  final spans = <TextSpan>[];
  int lastMatchEnd = 0;
  for (final match in matches) {
    if (match.start > lastMatchEnd) {
      spans.add(
        TextSpan(
          text: source.substring(lastMatchEnd, match.start),
          style: style,
        ),
      );
    }
    spans.add(
      TextSpan(
        text: source.substring(match.start, match.end),
        style: style.copyWith(
          backgroundColor: const Color.fromARGB(255, 81, 73, 1),
        ),
      ),
    );
    lastMatchEnd = match.end;
  }
  if (lastMatchEnd < source.length) {
    spans.add(TextSpan(text: source.substring(lastMatchEnd), style: style));
  }
  return TextSpan(children: spans);
}

class TuttiPage extends StatefulWidget {
  final String searchQuery;

  const TuttiPage({super.key, this.searchQuery = ''});

  @override
  State<TuttiPage> createState() => _TuttiPageState();
}

class _TuttiPageState extends State<TuttiPage> {
  List<Credential> allCredentials = [];
  List<Credential> filteredCredentials = [];
  final Map<int, TextEditingController> _titleControllers = {};

  @override
  void initState() {
    super.initState();
    _loadCredentials();
    CredentialStore().addListener(_loadCredentials);
  }

  void _loadCredentials() {
    allCredentials = CredentialStore().credentials;
    _filterCredentials();
  }

  void _filterCredentials() {
    filteredCredentials =
        allCredentials.where((cred) {
          final query = widget.searchQuery.toLowerCase();
          final title = cred.titolo.toLowerCase();
          final login = cred.login.toLowerCase();
          return title.contains(query) || login.contains(query);
        }).toList();

    _titleControllers
      ..forEach((_, ctrl) => ctrl.dispose())
      ..clear();
    for (var i = 0; i < filteredCredentials.length; i++) {
      _titleControllers[i] = TextEditingController(
        text: filteredCredentials[i].titolo,
      );
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant TuttiPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _filterCredentials();
    }
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredCredentials.length,
        itemBuilder: (context, index) {
          final cred = filteredCredentials[index];
          final titleCtrl = _titleControllers[index]!;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: _buildIcon(cred),
              title: RichText(
                text: _highlightOccurrences(
                  titleCtrl.text,
                  widget.searchQuery,
                  Theme.of(context).textTheme.titleMedium!,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle:
                  cred.login.isNotEmpty
                      ? RichText(
                        text: _highlightOccurrences(
                          cred.login,
                          widget.searchQuery,
                          Theme.of(context).textTheme.bodySmall!,
                        ),
                      )
                      : null,
              trailing: IconButton(
                icon: Icon(
                  cred.isFavorite ? Icons.star : Icons.star_border,
                  color: cred.isFavorite ? Colors.amber : null,
                ),
                onPressed: () {
                  final updatedCred = cred.copyWith(
                    isFavorite: !cred.isFavorite,
                  );
                  CredentialStore().updateCredential(cred, updatedCred);
                },
              ),
              onTap: () async {
                final updated = await Navigator.of(context).push<Credential>(
                  MaterialPageRoute(
                    builder:
                        (_) => CredentialDetailPage(initialCredential: cred),
                  ),
                );
                if (updated != null) {
                  // aggiorna lista e titolo in place
                  filteredCredentials[index] = updated;
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
