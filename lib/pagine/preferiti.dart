import 'package:flutter/material.dart';
import 'package:selfpass/modelli/credenziali.dart';
import 'package:selfpass/modelli/archivio_credenziali.dart';

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
            leading: _buildIcon(cred),
            title: RichText(
              text: _highlightOccurrences(
                cred.titolo,
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
          ),
        );
      },
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
