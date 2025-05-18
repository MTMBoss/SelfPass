import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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

class _HomepageState extends State<Homepage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: const CustomAppBar(),
      backgroundColor: Colors.white,
      body: _buildContent(),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        activeBackgroundColor: Colors.blue,
        activeForegroundColor: Colors.white,
        buttonSize: const Size(56, 56),
        visible: true,
        closeManually: false,
        curve: Curves.easeInOut,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        elevation: 4,
        shape: const CircleBorder(),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.language),
            backgroundColor: Colors.orange,
            label: 'Web Account',
            labelStyle: const TextStyle(fontSize: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WebAccountPage()),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.credit_card),
            backgroundColor: Colors.orange,
            label: 'Credit Card',
            labelStyle: const TextStyle(fontSize: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreditCardPage()),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.badge),
            backgroundColor: Colors.orange,
            label: 'ID/Passport',
            labelStyle: const TextStyle(fontSize: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const IDPassportPage()),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.note),
            backgroundColor: Colors.orange,
            label: 'Note',
            labelStyle: const TextStyle(fontSize: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotePage()),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.more_horiz),
            backgroundColor: Colors.orange,
            label: 'Another',
            labelStyle: const TextStyle(fontSize: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnotherPage()),
              );
            },
          ),
        ],
      ),
      // Modificata la posizione del FAB a destra
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
