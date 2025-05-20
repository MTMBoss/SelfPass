import 'package:flutter/material.dart';
import '../models/account.dart';
import '../helpers/text_highlight_helper.dart';
import 'account_icon.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final String searchQuery;
  final VoidCallback onFavoriteToggle;

  const AccountCard({
    super.key,
    required this.account,
    required this.searchQuery,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(context, '/editAccount', arguments: account);
        },
        leading: AccountIcon(account: account),
        title: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(
              context,
            ).style.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            children: highlightOccurrences(account.accountName, searchQuery),
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
                children: highlightOccurrences(
                  account.username.isNotEmpty
                      ? account.username
                      : "No username",
                  searchQuery,
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            account.isFavorite ? Icons.star : Icons.star_border,
            color: account.isFavorite ? Colors.amber : Colors.grey,
          ),
          onPressed: onFavoriteToggle,
        ),
      ),
    );
  }
}
