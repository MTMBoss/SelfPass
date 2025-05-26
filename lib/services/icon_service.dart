import 'package:flutter/material.dart';

class IconService {
  static IconData getIconForMode(String mode) {
    switch (mode) {
      case 'Website Icon':
        return Icons.language;
      case 'Symbol':
        return Icons.star;
      case 'Color':
        return Icons.color_lens;
      case 'Custom Icon':
        return Icons.image;
      default:
        return Icons.language;
    }
  }

  static String getFaviconUrl(String websiteUrl) {
    String domain = websiteUrl;
    if (domain.startsWith('http://')) {
      domain = domain.substring(7);
    } else if (domain.startsWith('https://')) {
      domain = domain.substring(8);
    }
    if (domain.contains('/')) {
      domain = domain.split('/')[0];
    }
    return 'https://www.google.com/s2/favicons?domain=$domain&sz=64';
  }

  static final List<Color> availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];
}
