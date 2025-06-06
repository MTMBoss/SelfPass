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

  // Configurazione dei campi (usata esclusivamente per la UI)
  final List<String> enabledFields;

  // Nuovo campo: Segreto per il codice OTP
  final String? otpSecret;

  // Nuovo campo: Extra fields per salvare campi extra di tipo text (es. Login extra, Email, ecc.)
  final Map<String, String>? extraFields;

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
    this.extraFields,
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
    Map<String, String>? extraFields,
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
      extraFields: extraFields ?? this.extraFields,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountName': accountName,
      'username': username,
      'password': password,
      'additionalPasswords': additionalPasswords,
      'website': website,
      'isFavorite': isFavorite,
      'iconMode': iconMode,
      // Salvare l'identificatore costante (symbolKey) anziché usare IconData dinamico
      'symbolKey': symbolIcon != null ? _iconDataToKey(symbolIcon!) : null,
      // Sostituzione di .value (deprecato) con toARGB32().
      'colorIcon': colorIcon?.toARGB32(),
      'customIconPath': customIconPath,
      'enabledFields': enabledFields,
      'otpSecret': otpSecret,
      'extraFields': extraFields,
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      accountName: json['accountName'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      additionalPasswords:
          (json['additionalPasswords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      website: json['website'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
      iconMode: json['iconMode'] as String? ?? 'Website Icon',
      // Recupero dell'icona tramite l'identificatore (symbolKey) dalla mappa costante
      symbolIcon:
          json['symbolKey'] != null
              ? _iconKeyToIconData(json['symbolKey'] as String)
              : null,
      colorIcon:
          json['colorIcon'] != null ? Color(json['colorIcon'] as int) : null,
      customIconPath: json['customIconPath'] as String?,
      enabledFields:
          (json['enabledFields'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [
            'Title',
            'Login',
            'Password',
            'Website',
            'One-time password (2FA)',
            'Notes',
          ],
      otpSecret: json['otpSecret'] as String?,
      extraFields: (json['extraFields'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String),
      ),
    );
  }

  // Mappa costante per associare una chiave (stringa) ad istanze costanti di IconData
  static const Map<String, IconData> _iconMapping = {
    'language': Icons.language,
    'star': Icons.star,
    'color_lens': Icons.color_lens,
    'image': Icons.image,
    // Puoi aggiungere altre associazioni in base alle tue necessità
  };

  static IconData? _iconKeyToIconData(String key) {
    return _iconMapping[key];
  }

  // Restituisce la chiave di _iconMapping corrispondente all'IconData fornito
  static String? _iconDataToKey(IconData iconData) {
    for (final entry in _iconMapping.entries) {
      if (entry.value.codePoint == iconData.codePoint &&
          entry.value.fontFamily == iconData.fontFamily) {
        return entry.key;
      }
    }
    return null;
  }
}
