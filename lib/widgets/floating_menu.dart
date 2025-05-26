import 'package:flutter/material.dart';
import '../pages/web_account/web_account_page.dart';
import '../pages/credit_card_page.dart';
import '../pages/id_passport_page.dart';
import '../pages/note_page.dart';
import '../pages/another_page.dart';

class FloatingMenu extends StatelessWidget {
  final Animation<double> animation;
  final VoidCallback toggleMenu;

  const FloatingMenu({
    super.key,
    required this.animation,
    required this.toggleMenu,
  });

  Widget _buildMenuOption(
    IconData icon,
    String label,
    Widget page,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () async {
        toggleMenu();
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(builder: (BuildContext context) => page),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withAlpha(150),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      right: 16,
      child: FadeTransition(
        opacity: animation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildMenuOption(
              Icons.language,
              'Web Account',
              const WebAccountPage(),
              context,
            ),
            _buildMenuOption(
              Icons.credit_card,
              'Credit Card',
              const CreditCardPage(),
              context,
            ),
            _buildMenuOption(
              Icons.badge,
              'ID/Passport',
              const IDPassportPage(),
              context,
            ),
            _buildMenuOption(Icons.note, 'Note', const NotePage(), context),
            _buildMenuOption(
              Icons.more_horiz,
              'Another',
              const AnotherPage(),
              context,
            ),
          ],
        ),
      ),
    );
  }
}
