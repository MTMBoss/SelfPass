import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Restituisce true se l'autenticazione è andata a buon fine, false altrimenti.
  Future<bool> authenticate() async {
    try {
      // Verifica se il dispositivo supporta la biometria.
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();

      // Recupera l'elenco delle biometrie disponibili (es. impronta, facciale, ecc.)
      final List<BiometricType> availableBiometrics =
          await _auth.getAvailableBiometrics();
      debugPrint(
        'canCheckBiometrics: $canCheckBiometrics, isDeviceSupported: $isDeviceSupported, availableBiometrics: $availableBiometrics',
      );

      // Se il dispositivo non supporta la biometria e non ne ha registrate,
      // si potrebbe optare per un meccanismo di fallback (da implementare).
      if (!canCheckBiometrics &&
          (availableBiometrics.isEmpty || !isDeviceSupported)) {
        debugPrint('Biometric authentication not supported');
        // Qui potresti chiamare un metodo per il fallback (ad es. PIN/password).
        return false;
      }

      // Personalizza il messaggio in base ai metodi biometrici disponibili.
      String localizedReason = 'Please authenticate to access the app';
      if (availableBiometrics.contains(BiometricType.fingerprint)) {
        localizedReason = 'Please scan your fingerprint to access the app';
      } else if (availableBiometrics.contains(BiometricType.face)) {
        localizedReason = 'Please scan your face to access the app';
      }

      // Avvia il processo di autenticazione.
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      debugPrint('Authentication result: $didAuthenticate');
      return didAuthenticate;
    } catch (e) {
      debugPrint('Authentication error: $e');
      // Qui potresti gestire in modo specifico l'errore e attivare un fallback.
      return false;
    }
  }
}
