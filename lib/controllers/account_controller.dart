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
      iconMode: 'Website Icon',
    ),
    Account(
      accountName: 'Facebook',
      username: 'user@facebook.com',
      password: '••••••',
      website: 'https://www.facebook.com',
      iconMode: 'Website Icon',
    ),
    Account(
      accountName: 'Twitter',
      username: 'user@twitter.com',
      password: '••••••',
      website: 'https://www.twitter.com',
      iconMode: 'Website Icon',
    ),
    Account(
      accountName: 'Instagram',
      username: 'user@instagram.com',
      password: '••••••',
      website: 'https://www.instagram.com',
      iconMode: 'Website Icon',
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
    // Find the account by comparing name and username
    final index = accounts.indexWhere(
      (a) =>
          a.accountName == updatedAccount.accountName &&
          a.username == updatedAccount.username,
    );

    if (index != -1) {
      // Preserve the favorite state from the existing account
      final existingAccount = accounts[index];
      accounts[index] = Account(
        accountName: updatedAccount.accountName,
        username: updatedAccount.username,
        password: updatedAccount.password,
        website: updatedAccount.website,
        isFavorite: existingAccount.isFavorite, // Preserve favorite state
        iconMode: updatedAccount.iconMode,
        symbolIcon: updatedAccount.symbolIcon,
        colorIcon: updatedAccount.colorIcon,
        customIconPath: updatedAccount.customIconPath,
      );
      notifyListeners();
    } else {
      // If account not found, add as new
      addAccount(updatedAccount);
    }
  }
}
