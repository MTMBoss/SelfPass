import 'credenziali.dart';

import 'package:flutter/foundation.dart';

class CredentialStore extends ChangeNotifier {
  CredentialStore._privateConstructor();

  static final CredentialStore _instance =
      CredentialStore._privateConstructor();

  factory CredentialStore() {
    return _instance;
  }

  final List<Credential> _credentials = [];

  List<Credential> get credentials => List.unmodifiable(_credentials);

  void addCredential(Credential credential) {
    _credentials.add(credential);
    notifyListeners();
  }

  void removeCredential(Credential credential) {
    _credentials.remove(credential);
    notifyListeners();
  }

  void updateCredential(Credential oldCredential, Credential newCredential) {
    final index = _credentials.indexOf(oldCredential);
    if (index != -1) {
      _credentials[index] = newCredential;
      notifyListeners();
    }
  }
}
