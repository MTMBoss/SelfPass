// lib/main.dart
import 'package:flutter/material.dart';
import 'pagine/Tutti/tutti.dart';
import 'pagine/preferiti.dart';
import 'pagine/biglietti.dart';
import 'pagine/impostazioni.dart';
import 'tema.dart';
import 'widgets/menu.dart';
import 'widgets/drawer.dart';
import 'widgets/fab_menu.dart';
import 'widgets/cerca.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system, // o ThemeMode.dark / ThemeMode.light
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _searchQuery = '';

  List<Widget> get _pages => <Widget>[
    TuttiPage(searchQuery: _searchQuery),
    const PreferitiPage(),
    const BigliettiPage(),
    const ImpostazioniPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('SelfPass'),
        actions: const <Widget>[AppMenu()],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Cerca(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Expanded to fill remaining space with the selected page content
          Expanded(child: _pages.elementAt(_selectedIndex)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Tutti'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Preferiti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_num),
            label: 'Biglietti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Impostazioni',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
      floatingActionButton: const FabMenu(),
    );
  }
}
