// lib/models/credential.dart

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
  });
}
