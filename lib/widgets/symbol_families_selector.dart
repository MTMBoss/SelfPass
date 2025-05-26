import 'package:flutter/material.dart';
import 'symbol_data.dart';

typedef SymbolSelectedCallback = void Function(IconData icon, Color? color);

class SymbolFamiliesSelector extends StatefulWidget {
  final SymbolSelectedCallback onSymbolSelected;

  const SymbolFamiliesSelector({super.key, required this.onSymbolSelected});
  @override
  SymbolFamiliesSelectorState createState() => SymbolFamiliesSelectorState();
}

class SymbolFamiliesSelectorState extends State<SymbolFamiliesSelector> {
  final PageController _pageController = PageController();

  final Map<String, List<IconData>> _symbolFamilies = symbolFamilies;

  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildFamilyPage(String familyName, List<IconData> icons) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            familyName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.count(
              crossAxisCount: 5,
              children:
                  icons.map((iconData) {
                    return IconButton(
                      icon: Icon(iconData, size: 32),
                      onPressed: () {
                        widget.onSymbolSelected(iconData, Colors.black);
                      },
                      color: Colors.black,
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children:
                  _symbolFamilies.entries
                      .map((entry) => _buildFamilyPage(entry.key, entry.value))
                      .toList(),
            ),
          ),
          SizedBox(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_symbolFamilies.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.blue : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
