import 'package:flutter/material.dart';

class Account {
  final String accountName;
  final String username;
  final String password;
  final String website; // Added website field
  // Nuovo campo per indicare se l'account è tra i preferiti:
  bool isFavorite;

  // New fields for icon mode and related data
  final String iconMode; // 'Website Icon', 'Symbol', 'Color', 'Custom Icon'
  final IconData? symbolIcon;
  final Color? colorIcon;
  final String? customIconPath;

  Account({
    required this.accountName,
    required this.username,
    required this.password,
    required this.website, // Added website to constructor
    this.isFavorite = false,
    this.iconMode = 'Website Icon',
    this.symbolIcon,
    this.colorIcon,
    this.customIconPath,
  });
}
