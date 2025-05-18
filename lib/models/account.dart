class Account {
  final String accountName;
  final String username;
  final String password;
  // Nuovo campo per indicare se l'account è tra i preferiti:
  bool isFavorite;

  Account({
    required this.accountName,
    required this.username,
    required this.password,
    this.isFavorite = false,
  });
}
