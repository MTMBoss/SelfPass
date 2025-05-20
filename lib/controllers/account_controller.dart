import 'package:flutter/foundation.dart';
import '../models/account.dart';

class AccountController extends ChangeNotifier {
  static final AccountController _instance = AccountController._internal();

  factory AccountController() {
    return _instance;
  }

  AccountController._internal();

  List<Account> accounts = [
    Account(
      accountName: 'Google',
      username: 'user@gmail.com',
      password: '••••••',
      website: 'https://www.google.com',
    ),
    Account(
      accountName: 'Facebook',
      username: 'user@facebook.com',
      password: '••••••',
      website: 'https://www.facebook.com',
    ),
    Account(
      accountName: 'Twitter',
      username: 'user@twitter.com',
      password: '••••••',
      website: 'https://www.twitter.com',
    ),
    Account(
      accountName: 'Instagram',
      username: 'user@instagram.com',
      password: '••••••',
      website: 'https://www.instagram.com',
    ),
  ];

  List<Account> get favoriteAccounts =>
      accounts.where((account) => account.isFavorite).toList();

  List<Account> filterAccounts(String query) {
    if (query.isEmpty) {
      return accounts;
    }
    final lowerQuery = query.toLowerCase();
    return accounts.where((account) {
      return account.accountName.toLowerCase().contains(lowerQuery) ||
          account.username.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<Account> filterFavoriteAccounts(String query) {
    final favorites = favoriteAccounts;
    if (query.isEmpty) {
      return favorites;
    }
    final lowerQuery = query.toLowerCase();
    return favorites.where((account) {
      return account.accountName.toLowerCase().contains(lowerQuery) ||
          account.username.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  void toggleFavorite(Account account) {
    account.isFavorite = !account.isFavorite;
    notifyListeners();
  }

  void addAccount(Account account) {
    accounts.add(account);
    notifyListeners();
  }

  void updateAccount(Account updatedAccount) {
    final index = accounts.indexWhere(
      (a) => a.accountName == updatedAccount.accountName,
    );
    if (index != -1) {
      accounts[index] = updatedAccount;
      notifyListeners();
    }
  }
}
