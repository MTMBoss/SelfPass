import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/account.dart';
import '../widgets/account_list.dart';
import '../widgets/search_field.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'web_account_page.dart';
import 'credit_card_page.dart';
import 'id_passport_page.dart';
import 'note_page.dart';
import 'another_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin {
  final Logger logger = Logger();

  // Lista di account d'esempio (isFavorite inizialmente false)
  final List<Account> accounts = [
    Account(
      accountName: 'Google',
      username: 'user@gmail.com',
      password: '••••••',
    ),
    Account(
      accountName: 'Facebook',
      username: 'user@facebook.com',
      password: '••••••',
    ),
    Account(
      accountName: 'Twitter',
      username: 'user@twitter.com',
      password: '••••••',
    ),
    Account(
      accountName: 'Instagram',
      username: 'user@instagram.com',
      password: '••••••',
    ),
  ];

  // Calcola la lista dei preferiti basandosi sul flag isFavorite dell'account
  List<Account> get favoriteAccounts =>
      accounts.where((account) => account.isFavorite).toList();

  // Stato della query di ricerca
  String _searchQuery = '';

  // Getter per filtrare gli account in base alla query (case-insensitive)
  List<Account> get filteredAccounts =>
      _searchQuery.isEmpty
          ? accounts
          : accounts.where((account) {
            return account.accountName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                account.username.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList();

  List<Account> get filteredFavoriteAccounts =>
      _searchQuery.isEmpty
          ? favoriteAccounts
          : favoriteAccounts.where((account) {
            return account.accountName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                account.username.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList();

  // Funzione per alternare il flag isFavorite
  void toggleFavorite(Account account) {
    setState(() {
      account.isFavorite = !account.isFavorite;
    });
  }

  // Costruisce il contenuto in base all'indice selezionato
  Widget _buildContent() {
    return IndexedStack(
      index: _selectedIndex,
      children: [
        Column(
          children: [
            SearchField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            Expanded(
              child: AccountList(
                accounts: filteredAccounts,
                searchQuery: _searchQuery,
                onFavoriteToggle: toggleFavorite,
              ),
            ),
          ],
        ),
        Column(
          children: [
            SearchField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            Expanded(
              child: AccountList(
                accounts: filteredFavoriteAccounts,
                searchQuery: _searchQuery,
                onFavoriteToggle: toggleFavorite,
              ),
            ),
          ],
        ),
        Column(
          children: const [
            SearchField(),
            Expanded(child: Center(child: Text('Pagina delle impostazioni'))),
          ],
        ),
        Column(
          children: const [
            SearchField(),
            Expanded(
              child: Center(
                child: Text(
                  'Pagina Biglietti',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Indice della pagina attualmente visualizzata:
  // 0 -> Tutti gli account; 1 -> Preferiti; 2 -> Impostazioni
  int _selectedIndex = 0;

  late AnimationController _animationController;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (_isMenuOpen) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  Future<void> _navigateTo(Widget page) async {
    _toggleMenu();
    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (BuildContext context) => page),
    );
  }

  Widget _buildMenuOption(IconData icon, String label, Widget page) {
    return GestureDetector(
      onTap: () => _navigateTo(page),
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

  Widget _buildMenu() {
    return Positioned(
      bottom: 80,
      right: 16,
      child: FadeTransition(
        opacity: _animationController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildMenuOption(
              Icons.language,
              'Web Account',
              const WebAccountPage(),
            ),
            _buildMenuOption(
              Icons.credit_card,
              'Credit Card',
              const CreditCardPage(),
            ),
            _buildMenuOption(
              Icons.badge,
              'ID/Passport',
              const IDPassportPage(),
            ),
            _buildMenuOption(Icons.note, 'Note', const NotePage()),
            _buildMenuOption(Icons.more_horiz, 'Another', const AnotherPage()),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: const CustomAppBar(),
      backgroundColor: Colors.white,
      body: _buildContent(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Stack(
        children: [
          if (_isMenuOpen) _buildMenu(),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _toggleMenu,
              backgroundColor: Colors.blue,
              shape: const CircleBorder(),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return RotationTransition(
                    turns:
                        child.key == const ValueKey('icon1')
                            ? Tween<double>(
                              begin: 0.75,
                              end: 1.0,
                            ).animate(animation)
                            : Tween<double>(
                              begin: 1.0,
                              end: 0.75,
                            ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child:
                    _isMenuOpen
                        ? const Icon(
                          Icons.close,
                          key: ValueKey('icon2'),
                          color: Colors.white,
                          size: 28,
                        )
                        : const Icon(
                          Icons.add,
                          key: ValueKey('icon1'),
                          color: Colors.white,
                          size: 28,
                        ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
