import 'package:flutter/material.dart';
import '../models/account.dart';
import '../services/icon_service.dart';

class AccountIcon extends StatelessWidget {
  final Account account;

  const AccountIcon({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final iconMode = account.iconMode;
    switch (iconMode) {
      case 'Website Icon':
        if (account.website.isNotEmpty) {
          return ClipOval(
            child: Image.network(
              IconService.getFaviconUrl(account.website),
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
          color: account.colorIcon ?? Colors.amber,
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
