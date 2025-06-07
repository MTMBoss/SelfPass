import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/account.dart';

class AccountController extends ChangeNotifier {
  static final AccountController _instance = AccountController._internal();

  factory AccountController() {
    return _instance;
  }

  AccountController._internal() {
    _loadAccounts();
  }

  List<Account> accounts = [];

  Future<void> _loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? accountsJson = prefs.getString('accounts');
    if (accountsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(accountsJson);
        accounts = decoded.map((e) => Account.fromJson(e)).toList();
      } catch (e) {
        // Log dell'errore per debug e rimozione dei dati corrotti
        debugPrint('Errore nel parsing degli account: $e');
        accounts = [];
        await prefs.remove('accounts');
      }
    } else {
      accounts = [];
    }
    notifyListeners();
  }

  Future<void> _saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(accounts.map((e) => e.toJson()).toList());
    await prefs.setString('accounts', encoded);
  }

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
    final index = accounts.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      accounts[index].isFavorite = !accounts[index].isFavorite;
      notifyListeners();
      _saveAccounts();
    }
  }

  void addAccount(Account account) {
    accounts.add(account);
    notifyListeners();
    _saveAccounts();
  }

  void updateAccount(Account updatedAccount) {
    final index = accounts.indexWhere((a) => a.id == updatedAccount.id);
    if (index != -1) {
      accounts[index] = updatedAccount.copyWith(
        isFavorite: accounts[index].isFavorite,
      );
      notifyListeners();
      _saveAccounts();
    }
  }
}
