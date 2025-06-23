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

  // New fields for logo state
  final int? selectedColorValue;
  final String? customSymbol;
  final bool applyColorToEmoji;
  final String? faviconUrl;

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
  });
}
