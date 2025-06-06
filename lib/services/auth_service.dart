import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      debugPrint(
        'canCheckBiometrics: \$canCheckBiometrics, isDeviceSupported: \$isDeviceSupported',
      );
      if (!canCheckBiometrics && !isDeviceSupported) {
        debugPrint('Biometric authentication not supported');
        return false;
      }
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      debugPrint('Authentication result: \$didAuthenticate');
      return didAuthenticate;
    } catch (e) {
      debugPrint('Authentication error: $e');
      return false;
    }
  }
}
