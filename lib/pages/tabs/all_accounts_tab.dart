import 'package:flutter/material.dart';
import '../../models/account.dart';
import '../../widgets/account_list.dart';
import '../../widgets/search_field.dart';

class AllAccountsTab extends StatelessWidget {
  final List<Account> accounts;
  final String searchQuery;
  final ValueChanged<Account> onFavoriteToggle;
  final ValueChanged<String> onSearchChanged;
  final TextEditingController? controller;
  final String? initialValue;

  const AllAccountsTab({
    super.key,
    required this.accounts,
    required this.searchQuery,
    required this.onFavoriteToggle,
    required this.onSearchChanged,
    this.controller,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchField(
          onChanged: onSearchChanged,
          controller: controller,
          initialValue: initialValue,
        ),
        Expanded(
          child: AccountList(
            accounts: accounts,
            searchQuery: searchQuery,
            onFavoriteToggle: onFavoriteToggle,
          ),
        ),
      ],
    );
  }
}
