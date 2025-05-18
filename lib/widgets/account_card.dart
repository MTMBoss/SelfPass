import 'package:flutter/material.dart';
import '../models/account.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final String searchQuery;
  // Callback per la gestione della pressione della stella:
  final VoidCallback onFavoriteToggle;

  const AccountCard({
    super.key,
    required this.account,
    required this.searchQuery,
    required this.onFavoriteToggle,
  });

  // Metodo che evidenzia le occorrenze della query nel testo
  List<TextSpan> _highlightOccurrences(String text, String query) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }

    final List<TextSpan> spans = [];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      // Occorrenza trovata evidenziata
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: const TextStyle(backgroundColor: Colors.yellow),
        ),
      );
      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(
              context,
            ).style.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            children: _highlightOccurrences(account.accountName, searchQuery),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(
                  context,
                ).style.copyWith(fontSize: 14),
                children: _highlightOccurrences(
                  'Username: ${account.username}',
                  searchQuery,
                ),
              ),
            ),
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(
                  context,
                ).style.copyWith(fontSize: 14),
                children: _highlightOccurrences(
                  'Password: ${account.password}',
                  searchQuery,
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            // Icona piena se l'account è tra i preferiti, altrimenti solo il bordo
            account.isFavorite ? Icons.star : Icons.star_border,
            color: account.isFavorite ? Colors.amber : Colors.grey,
          ),
          onPressed: onFavoriteToggle,
        ),
      ),
    );
  }
}
