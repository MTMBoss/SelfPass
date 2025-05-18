import 'package:flutter/material.dart';
import '../models/account.dart';
import 'account_card.dart';

class AccountList extends StatelessWidget {
  final List<Account> accounts;
  final String searchQuery;
  final ValueChanged<Account> onFavoriteToggle;

  const AccountList({
    super.key,
    required this.accounts,
    required this.searchQuery,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: accounts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final account = accounts[index];
        return AccountCard(
          account: account,
          searchQuery: searchQuery,
          onFavoriteToggle: () => onFavoriteToggle(account),
        );
      },
    );
  }
}
