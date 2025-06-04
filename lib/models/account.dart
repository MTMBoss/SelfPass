import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Account {
  final String id;
  final String accountName;
  final String username;
  final String password; // password principale
  final List<String> additionalPasswords; // password extra
  final String website;
  bool isFavorite;

  // Campi relativi alle icone
  final String iconMode;
  final IconData? symbolIcon;
  final Color? colorIcon;
  final String? customIconPath;

  // Configurazione dei campi (in questo caso usata solo per la UI)
  final List<String> enabledFields;

  // NUOVO CAMPO: Segreto per il codice OTP
  final String? otpSecret;

  Account({
    String? id,
    required this.accountName,
    required this.username,
    required this.password,
    required this.website,
    this.additionalPasswords = const [],
    this.isFavorite = false,
    this.iconMode = 'Website Icon',
    this.symbolIcon,
    this.colorIcon,
    this.customIconPath,
    List<String>? enabledFields,
    this.otpSecret,
  }) : id = id ?? const Uuid().v4(),
       enabledFields =
           enabledFields ??
           [
             'Title',
             'Login',
             'Password',
             'Website',
             'One-time password (2FA)',
             'Notes',
           ];

  Account copyWith({
    String? id,
    String? accountName,
    String? username,
    String? password,
    List<String>? additionalPasswords,
    String? website,
    bool? isFavorite,
    String? iconMode,
    IconData? symbolIcon,
    Color? colorIcon,
    String? customIconPath,
    List<String>? enabledFields,
    String? otpSecret,
  }) {
    return Account(
      id: id ?? this.id,
      accountName: accountName ?? this.accountName,
      username: username ?? this.username,
      password: password ?? this.password,
      additionalPasswords: additionalPasswords ?? this.additionalPasswords,
      website: website ?? this.website,
      isFavorite: isFavorite ?? this.isFavorite,
      iconMode: iconMode ?? this.iconMode,
      symbolIcon: symbolIcon ?? this.symbolIcon,
      colorIcon: colorIcon ?? this.colorIcon,
      customIconPath: customIconPath ?? this.customIconPath,
      enabledFields: enabledFields ?? this.enabledFields,
      otpSecret: otpSecret ?? this.otpSecret,
    );
  }
}
