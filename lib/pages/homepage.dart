import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/account.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/floating_menu.dart';
import 'homepage_tabs/all_accounts_tab.dart';
import 'homepage_tabs/favorites_tab.dart';
import 'homepage_tabs/settings_tab.dart';
import 'homepage_tabs/tickets_tab.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: const CustomAppBar(),
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          AllAccountsTab(
            accounts: filteredAccounts,
            searchQuery: _searchQuery,
            onFavoriteToggle: toggleFavorite,
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          FavoritesTab(
            favoriteAccounts: filteredFavoriteAccounts,
            searchQuery: _searchQuery,
            onFavoriteToggle: toggleFavorite,
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          SettingsTab(
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          TicketsTab(
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Stack(
        children: [
          if (_isMenuOpen)
            FloatingMenu(
              animation: _animationController,
              toggleMenu: _toggleMenu,
            ),
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
