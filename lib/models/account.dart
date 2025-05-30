import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Account {
  final String id;
  final String accountName;
  final String username;
  final String password;
  final String website;
  bool isFavorite;

  // Icon related fields
  final String iconMode;
  final IconData? symbolIcon;
  final Color? colorIcon;
  final String? customIconPath;

  // Field configuration
  final List<String> enabledFields;

  Account({
    String? id,
    required this.accountName,
    required this.username,
    required this.password,
    required this.website,
    this.isFavorite = false,
    this.iconMode = 'Website Icon',
    this.symbolIcon,
    this.colorIcon,
    this.customIconPath,
    List<String>? enabledFields,
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
    String? website,
    bool? isFavorite,
    String? iconMode,
    IconData? symbolIcon,
    Color? colorIcon,
    String? customIconPath,
    List<String>? enabledFields,
  }) {
    return Account(
      id: id ?? this.id,
      accountName: accountName ?? this.accountName,
      username: username ?? this.username,
      password: password ?? this.password,
      website: website ?? this.website,
      isFavorite: isFavorite ?? this.isFavorite,
      iconMode: iconMode ?? this.iconMode,
      symbolIcon: symbolIcon ?? this.symbolIcon,
      colorIcon: colorIcon ?? this.colorIcon,
      customIconPath: customIconPath ?? this.customIconPath,
      enabledFields: enabledFields ?? this.enabledFields,
    );
  }
}
