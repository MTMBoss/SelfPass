import 'package:flutter/material.dart';
import '../models/account.dart';

class AccountIcon extends StatelessWidget {
  final Account account;

  const AccountIcon({super.key, required this.account});

  String _getFaviconUrl(String websiteUrl) {
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

  @override
  Widget build(BuildContext context) {
    final iconMode = account.iconMode;
    switch (iconMode) {
      case 'Website Icon':
        if (account.accountName.isNotEmpty && account.website.isNotEmpty) {
          return ClipOval(
            child: Image.network(
              _getFaviconUrl(account.website),
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.language);
              },
            ),
          );
        } else {
          return const Icon(Icons.language);
        }
      case 'Symbol':
        return Icon(
          account.symbolIcon ?? Icons.star,
          size: 40,
          color: Colors.amber,
        );
      case 'Color':
        return CircleAvatar(
          radius: 20,
          backgroundColor: account.colorIcon ?? Colors.blueGrey,
        );
      case 'Custom Icon':
        if (account.customIconPath != null &&
            account.customIconPath?.isNotEmpty == true) {
          return ClipOval(
            child: Image.asset(
              account.customIconPath!,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image);
              },
            ),
          );
        } else {
          return const Icon(Icons.image);
        }
      default:
        return const Icon(Icons.language);
    }
  }
}
