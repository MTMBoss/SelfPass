import 'package:flutter/material.dart';

class AppMenu extends StatelessWidget {
  const AppMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        // Handle menu selection
      },
      itemBuilder: (BuildContext context) {
        return {'Option 1', 'Option 2', 'Option 3'}.map((String choice) {
          return PopupMenuItem<String>(value: choice, child: Text(choice));
        }).toList();
      },
    );
  }
}
