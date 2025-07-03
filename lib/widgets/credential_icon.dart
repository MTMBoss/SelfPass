import 'package:flutter/material.dart';
import 'package:selfpass/modelli/credenziali.dart';

class CredentialIcon extends StatelessWidget {
  final Credential cred;
  final double size;

  const CredentialIcon(this.cred, {super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final double fontSize = size.toDouble();
    final double radius = size / 2;

    // custom symbol
    if (cred.customSymbol?.isNotEmpty == true) {
      if (cred.applyColorToEmoji) {
        final col =
            cred.selectedColorValue != null
                ? Color(cred.selectedColorValue!)
                : Colors.black;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback:
              (bounds) =>
                  LinearGradient(colors: [col, col]).createShader(bounds),
          child: Text(cred.customSymbol!, style: TextStyle(fontSize: fontSize)),
        );
      }
      return Text(cred.customSymbol!, style: TextStyle(fontSize: fontSize));
    }
    // favicon
    if (cred.faviconUrl?.isNotEmpty == true) {
      return Image.network(
        cred.faviconUrl!,
        width: fontSize,
        height: fontSize,
        errorBuilder: (_, __, ___) {
          final bg =
              cred.selectedColorValue != null
                  ? Color(cred.selectedColorValue!)
                  : Colors.black;
          return CircleAvatar(radius: radius, backgroundColor: bg);
        },
      );
    }
    // fallback: colored circle
    final bg =
        cred.selectedColorValue != null
            ? Color(cred.selectedColorValue!)
            : Colors.black;
    return CircleAvatar(radius: radius, backgroundColor: bg);
  }
}
