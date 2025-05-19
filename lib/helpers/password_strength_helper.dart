class PasswordStrengthHelper {
  static double calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) strength += 0.25;
    return strength.clamp(0, 1);
  }

  static String getStrengthLabel(double strength) {
    if (strength == 0) return '';
    if (strength < 0.5) return 'Weak';
    if (strength < 0.75) return 'Medium';
    return 'Strong';
  }

  static String estimateCrackTime(String password) {
    if (password.isEmpty) return '';
    int baseTime = password.length * 1000; // milliseconds
    if (RegExp(r'[A-Z]').hasMatch(password)) baseTime *= 2;
    if (RegExp(r'[0-9]').hasMatch(password)) baseTime *= 2;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) baseTime *= 3;

    if (baseTime < 10000) return 'Seconds';
    if (baseTime < 60000) return 'Minutes';
    if (baseTime < 3600000) return 'Hours';
    if (baseTime < 86400000) return 'Days';
    if (baseTime < 31536000000) return 'Years';
    return 'Centuries';
  }
}
