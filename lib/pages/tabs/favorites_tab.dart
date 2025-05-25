import 'package:flutter/material.dart';
import '../../models/account.dart';
import '../../widgets/account_list.dart';
import '../../widgets/search_field.dart';

class FavoritesTab extends StatelessWidget {
  final List<Account> favoriteAccounts;
  final String searchQuery;
  final ValueChanged<Account> onFavoriteToggle;
  final ValueChanged<String> onSearchChanged;

  const FavoritesTab({
    super.key,
    required this.favoriteAccounts,
    required this.searchQuery,
    required this.onFavoriteToggle,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchField(onChanged: onSearchChanged),
        Expanded(
          child: AccountList(
            accounts: favoriteAccounts,
            searchQuery: searchQuery,
            onFavoriteToggle: onFavoriteToggle,
          ),
        ),
      ],
    );
  }
}
