import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class EncryptionService {
  static const _keyStorageKey = 'encryption_key';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  Encrypter? _encrypter;
  IV? _iv;

  // Istanza del Logger per il debug
  final Logger _logger = Logger();

  EncryptionService() {
    // Per facilitare il debug utilizziamo un IV fisso (16 byte a zero)
    // In produzione è preferibile usare un IV generato casualmente per ogni operazione.
    _iv = IV.fromLength(16);
  }

  /// Inizializza il servizio:
  /// - recupera la chiave salvata nello storage sicuro o ne genera una nuova
  /// - inizializza l'oggetto Encrypter con la modalità CBC
  Future<void> init() async {
    String? base64Key = await _secureStorage.read(key: _keyStorageKey);
    if (base64Key == null) {
      // Genera una nuova chiave AES per AES-256 (32 byte)
      final key = Key.fromSecureRandom(32);
      base64Key = base64.encode(key.bytes);
      await _secureStorage.write(key: _keyStorageKey, value: base64Key);
      _logger.d("Generata nuova chiave: $base64Key");
    } else {
      _logger.d("Chiave esistente: $base64Key");
    }
    final key = Key(base64.decode(base64Key));
    _encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    _logger.d("EncryptionService inizializzato correttamente.");
  }

  /// Cifra il testo in chiaro e restituisce il risultato in Base64.
  String encrypt(String plainText) {
    if (_encrypter == null || _iv == null) {
      throw Exception("EncryptionService non inizializzato");
    }
    final encrypted = _encrypter!.encrypt(plainText, iv: _iv!);
    _logger.d("Encrypt: '$plainText' -> '${encrypted.base64}'");
    return encrypted.base64;
  }

  /// Decifra il testo cifrato (in Base64) e restituisce il testo in chiaro.
  String decrypt(String encryptedText) {
    if (_encrypter == null || _iv == null) {
      throw Exception("EncryptionService non inizializzato");
    }
    final encrypted = Encrypted.fromBase64(encryptedText);
    final decrypted = _encrypter!.decrypt(encrypted, iv: _iv!);
    _logger.d("Decrypt: '$encryptedText' -> '$decrypted'");
    return decrypted;
  }
}
