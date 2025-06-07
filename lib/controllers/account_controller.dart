import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/account.dart';
import '../services/encryption_service.dart';
import '../services/auth_service.dart';

class AccountController extends ChangeNotifier {
  static final AccountController _instance = AccountController._internal();

  factory AccountController() {
    return _instance;
  }

  final EncryptionService _encryptionService = EncryptionService();
  final AuthService _authService = AuthService();

  bool _isUnlocked = false;

  AccountController._internal() {
    _init();
  }

  List<Account> accounts = [];

  Future<void> _init() async {
    await _encryptionService.init();
    await _loadAccounts();
  }

  Future<bool> unlock() async {
    final authenticated = await _authService.authenticate();
    if (authenticated) {
      _isUnlocked = true;
      notifyListeners();
    }
    return authenticated;
  }

  Future<void> _loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? accountsJson = prefs.getString('accounts');
    if (accountsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(accountsJson);
        accounts =
            decoded.map((e) {
              final account = Account.fromJson(e);
              if (_isUnlocked) {
                final decryptedPassword = _encryptionService.decrypt(
                  account.password,
                );
                final decryptedAdditionalPasswords =
                    account.additionalPasswords
                        .map((p) => _encryptionService.decrypt(p))
                        .toList();
                return account.copyWith(
                  password: decryptedPassword,
                  additionalPasswords: decryptedAdditionalPasswords,
                );
              } else {
                // Return account with encrypted passwords if not unlocked
                return account;
              }
            }).toList();
      } catch (e) {
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
    final encryptedAccounts =
        accounts.map((account) {
          final encryptedPassword = _encryptionService.encrypt(
            account.password,
          );
          final encryptedAdditionalPasswords =
              account.additionalPasswords
                  .map((p) => _encryptionService.encrypt(p))
                  .toList();
          return account.copyWith(
            password: encryptedPassword,
            additionalPasswords: encryptedAdditionalPasswords,
          );
        }).toList();
    final String encoded = jsonEncode(
      encryptedAccounts.map((e) => e.toJson()).toList(),
    );
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
