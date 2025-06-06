import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/account.dart';
import '../controllers/account_controller.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/floating_action_menu.dart';
import 'tabs/all_accounts_tab.dart';
import 'tabs/favorites_tab.dart';
import 'tabs/settings_tab.dart';
import 'tabs/tickets_tab.dart';
import '../services/auth_service.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin {
  final Logger logger = Logger();

  final AccountController _accountController = AccountController();
  final TextEditingController _searchController = TextEditingController();

  // Stato della query di ricerca
  String _searchQuery = '';

  bool _authenticated = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
    _accountController.addListener(_onAccountsChanged);
  }

  Future<void> _authenticate() async {
    final authService = AuthService();
    final authenticated = await authService.authenticate();
    if (!authenticated) {
      if (!mounted) return;
      // Show error dialog with retry option
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: const Text('Authentication Failed'),
              content: const Text('Failed to authenticate. Please try again.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _authenticate();
                  },
                  child: const Text('Retry'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Exit'),
                ),
              ],
            ),
      );
    } else {
      setState(() {
        _authenticated = true;
      });
    }
  }

  @override
  void dispose() {
    _accountController.removeListener(_onAccountsChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onAccountsChanged() {
    setState(() {});
  }

  // Funzione per alternare il flag isFavorite
  void toggleFavorite(Account account) {
    setState(() {
      _accountController.toggleFavorite(account);
    });
  }

  int _selectedIndex = 0;

  // Removed unused AnimationController and _toggleMenu method as FloatingActionMenu handles menu state

  @override
  Widget build(BuildContext context) {
    if (!_authenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: const CustomAppBar(),
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          AllAccountsTab(
            key: ValueKey(_accountController.accounts.length),
            accounts: _accountController.filterAccounts(_searchQuery),
            searchQuery: _searchQuery,
            onFavoriteToggle: toggleFavorite,
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            controller: _searchController,
            initialValue: _searchQuery,
          ),
          FavoritesTab(
            favoriteAccounts: _accountController.filterFavoriteAccounts(
              _searchQuery,
            ),
            searchQuery: _searchQuery,
            onFavoriteToggle: toggleFavorite,
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            controller: _searchController,
            initialValue: _searchQuery,
          ),
          SettingsTab(
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            controller: _searchController,
            initialValue: _searchQuery,
          ),
          TicketsTab(
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            controller: _searchController,
            initialValue: _searchQuery,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionMenu(
        onMenuClosed: () {
          setState(() {});
        },
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
