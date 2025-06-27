import 'package:flutter/foundation.dart';

/// identifica il tipo di campo
enum FieldType {
  testo,
  numero,
  login,
  password,
  passwordMonouso,
  scadenza,
  sitoWeb,
  email,
  telefono,
  data,
  pin,
  privato,
  applicazione,
}

/// coppia tipo+valore per i campi extra
@immutable
class CustomField {
  final FieldType type;
  final String value;
  const CustomField(this.type, this.value);
}

class Credential {
  final String titolo;
  final String login;
  final String password;
  final String sitoWeb;
  final String passwordMonouso;
  final String note;

  final bool showLogin;
  final bool showPassword;
  final bool showSitoWeb;
  final bool showPasswordMonouso;
  final bool showNote;

  // logo state
  final int? selectedColorValue;
  final String? customSymbol;
  final bool applyColorToEmoji;
  final String? faviconUrl;

  // **qui la nuova lista dei campi aggiunti**
  final List<CustomField> customFields;

  // New property for favorite state
  final bool isFavorite;

  Credential({
    required this.titolo,
    required this.login,
    required this.password,
    required this.sitoWeb,
    required this.passwordMonouso,
    required this.note,
    this.showLogin = true,
    this.showPassword = true,
    this.showSitoWeb = true,
    this.showPasswordMonouso = true,
    this.showNote = true,
    this.selectedColorValue,
    this.customSymbol,
    this.applyColorToEmoji = false,
    this.faviconUrl,
    this.customFields = const [],
    this.isFavorite = false,
  });

  // Add a copyWith method to facilitate updating isFavorite
  Credential copyWith({
    String? titolo,
    String? login,
    String? password,
    String? sitoWeb,
    String? passwordMonouso,
    String? note,
    bool? showLogin,
    bool? showPassword,
    bool? showSitoWeb,
    bool? showPasswordMonouso,
    bool? showNote,
    int? selectedColorValue,
    String? customSymbol,
    bool? applyColorToEmoji,
    String? faviconUrl,
    List<CustomField>? customFields,
    bool? isFavorite,
  }) {
    return Credential(
      titolo: titolo ?? this.titolo,
      login: login ?? this.login,
      password: password ?? this.password,
      sitoWeb: sitoWeb ?? this.sitoWeb,
      passwordMonouso: passwordMonouso ?? this.passwordMonouso,
      note: note ?? this.note,
      showLogin: showLogin ?? this.showLogin,
      showPassword: showPassword ?? this.showPassword,
      showSitoWeb: showSitoWeb ?? this.showSitoWeb,
      showPasswordMonouso: showPasswordMonouso ?? this.showPasswordMonouso,
      showNote: showNote ?? this.showNote,
      selectedColorValue: selectedColorValue ?? this.selectedColorValue,
      customSymbol: customSymbol ?? this.customSymbol,
      applyColorToEmoji: applyColorToEmoji ?? this.applyColorToEmoji,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      customFields: customFields ?? this.customFields,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
