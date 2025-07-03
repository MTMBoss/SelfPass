import 'package:flutter/material.dart';
import 'simple_page.dart';
import '../pagine/Tutti/modelli/account_web/account_web_page.dart';
import '../pagine/Tutti/modelli/carta_credito/carta_credito_page.dart';
import '../pagine/Tutti/modelli/password_2fa/password_2fa_page.dart';
import '../pagine/Tutti/modelli/documento_id/documento_id_page.dart';
import '../pagine/Tutti/modelli/nota/nota_page.dart';

class FabMenu extends StatefulWidget {
  const FabMenu({super.key});

  @override
  State<FabMenu> createState() => _FabMenuState();
}

class _FabMenuState extends State<FabMenu> with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Map<String, dynamic>> _allOptions = [
    {'icon': Icons.web, 'title': 'Account Web', 'page': const AccountWebPage()},
    {
      'icon': Icons.credit_card,
      'title': 'Carta di Credito',
      'page': const CartaCreditoPage(),
    },
    {
      'icon': Icons.lock,
      'title': 'Password monouso (2FA)',
      'page': const Password2FAPage(),
    },
    {
      'icon': Icons.badge,
      'title': 'CI/Passaporto',
      'page': const DocumentoIdPage(),
    },
    {'icon': Icons.note, 'title': 'Nota', 'page': const NotaPage()},
    {
      'icon': Icons.shield,
      'title': 'Assicurazione',
      'page': SimplePage('Assicurazione'),
    },
    {
      'icon': Icons.email,
      'title': 'Account Email',
      'page': SimplePage('Account Email'),
    },
    {'icon': Icons.code, 'title': 'Codice', 'page': SimplePage('Codice')},
    {
      'icon': Icons.account_balance,
      'title': 'Conto Bancario',
      'page': SimplePage('Conto Bancario'),
    },
    {
      'icon': Icons.wifi,
      'title': 'Fornitore dei servizi Internet',
      'page': SimplePage('Fornitore dei servizi Internet'),
    },
    {
      'icon': Icons.app_registration,
      'title': 'Iscrizione',
      'page': SimplePage('Iscrizione'),
    },
    {
      'icon': Icons.vpn_key,
      'title': 'Licenza Software',
      'page': SimplePage('Licenza Software'),
    },
    {
      'icon': Icons.login,
      'title': 'Login/password',
      'page': SimplePage('Login/password'),
    },
    {
      'icon': Icons.drive_eta,
      'title': 'Patente di guida',
      'page': SimplePage('Patente di guida'),
    },
    {
      'icon': Icons.verified_user,
      'title': 'Previdenza Sociale',
      'page': SimplePage('Previdenza Sociale'),
    },
    {
      'icon': Icons.router,
      'title': 'Router Wi-Fi',
      'page': SimplePage('Router Wi-Fi'),
    },
    {
      'icon': Icons.person,
      'title': 'Personalizzato',
      'page': SimplePage('Personalizzato'),
    },
  ];

  final List<String> _recentTitles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      _isOpen ? _controller.forward() : _controller.reverse();
    });
  }

  void _navigateTo(Map<String, dynamic> option) {
    _toggleMenu();
    _updateRecent(option['title']);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => option['page']));
  }

  void _updateRecent(String title) {
    setState(() {
      _recentTitles.remove(title);
      _recentTitles.insert(0, title);
      if (_recentTitles.length > 3) {
        _recentTitles.removeLast();
      }
    });
  }

  Widget _buildOption(
    IconData icon,
    String label,
    VoidCallback onTap,
    double offset,
  ) {
    return Positioned(
      bottom: 70.0 + offset,
      right: 16.0,
      child: ScaleTransition(
        scale: _animation,
        child: FloatingActionButton.extended(
          heroTag: label,
          icon: Icon(icon),
          label: Text(label),
          onPressed: onTap,
          shape: const StadiumBorder(),
          backgroundColor: Colors.blueAccent,
        ),
      ),
    );
  }

  void _showAltroMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final recentOptions =
                _recentTitles
                    .map(
                      (title) =>
                          _allOptions.firstWhere((e) => e['title'] == title),
                    )
                    .toList();

            final otherOptions =
                _allOptions
                    .where((opt) => !_recentTitles.contains(opt['title']))
                    .toList();

            return ListView(
              shrinkWrap: true,
              children: [
                if (recentOptions.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "Recenti",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ...recentOptions.map(
                  (option) => ListTile(
                    leading: Icon(option['icon']),
                    title: Text(option['title']),
                    trailing: const Icon(Icons.history),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateTo(option);
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "Tutti",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...otherOptions.map(
                  (option) => ListTile(
                    leading: Icon(option['icon']),
                    title: Text(option['title']),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateTo(option);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleMenu,
              child: Container(color: Colors.black54),
            ),
          ),
        _buildOption(Icons.more_horiz, 'Altro', _showAltroMenu, 0),
        _buildOption(Icons.note, 'Nota', () => _navigateTo(_allOptions[4]), 60),
        _buildOption(
          Icons.badge,
          'CI/Passaporto',
          () => _navigateTo(_allOptions[3]),
          120,
        ),
        _buildOption(
          Icons.lock,
          'Password monouso (2FA)',
          () => _navigateTo(_allOptions[2]),
          180,
        ),
        _buildOption(
          Icons.credit_card,
          'Carta di credito',
          () => _navigateTo(_allOptions[1]),
          240,
        ),
        _buildOption(
          Icons.web,
          'Account Web',
          () => _navigateTo(_allOptions[0]),
          300,
        ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: FloatingActionButton(
            heroTag: 'main_fab',
            onPressed: _toggleMenu,
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _animation,
            ),
          ),
        ),
      ],
    );
  }
}
