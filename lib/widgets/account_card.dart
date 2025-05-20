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

  String _getFaviconUrl(String websiteUrl) {
    String domain = websiteUrl;
    if (domain.startsWith('http://')) {
      domain = domain.substring(7);
    } else if (domain.startsWith('https://')) {
      domain = domain.substring(8);
    }
    // Remove any path after domain
    if (domain.contains('/')) {
      domain = domain.split('/')[0];
    }
    // Use Google's favicon service for better favicon fetching with larger size
    return 'https://www.google.com/s2/favicons?domain=$domain&sz=64';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: _buildAccountIcon(),
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
                  account.username.isNotEmpty
                      ? account.username
                      : "No username",
                  searchQuery,
                ),
              ),
            ),
            // Removed password display as per user request
            // RichText(
            //   text: TextSpan(
            //     style: DefaultTextStyle.of(
            //       context,
            //     ).style.copyWith(fontSize: 14),
            //     children: _highlightOccurrences(
            //       'Password: ${account.password}',
            //       searchQuery,
            //     ),
            //   ),
            // ),
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

  Widget _buildAccountIcon() {
    final iconMode = account.iconMode;
    switch (iconMode) {
      case 'Website Icon':
        if (account.accountName.isNotEmpty && account.website.isNotEmpty) {
          return ClipOval(
            child: Image.network(
              _getFaviconUrl(account.website),
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.language);
              },
            ),
          );
        } else {
          return const Icon(Icons.language);
        }
      case 'Symbol':
        return Icon(
          account.symbolIcon ?? Icons.star,
          size: 40,
          color: Colors.amber,
        );
      case 'Color':
        return CircleAvatar(
          radius: 20,
          backgroundColor: account.colorIcon ?? Colors.blueGrey,
        );
      case 'Custom Icon':
        if (account.customIconPath != null &&
            account.customIconPath?.isNotEmpty == true) {
          return ClipOval(
            child: Image.asset(
              account.customIconPath!,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image);
              },
            ),
          );
        } else {
          return const Icon(Icons.image);
        }
      default:
        return const Icon(Icons.language);
    }
  }
}
