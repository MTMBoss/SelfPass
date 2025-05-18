import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'SelfPass',
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: Builder(
        builder:
            (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            // Handle dropdown menu actions based on selected option
            if (value == 'Opzione 1') {
              // Action for Option 1
            } else if (value == 'Opzione 2') {
              // Action for Option 2
            }
          },
          icon: const Icon(Icons.more_vert, color: Colors.black),
          itemBuilder:
              (BuildContext context) => const [
                PopupMenuItem<String>(
                  value: 'Opzione 1',
                  child: Text('Opzione 1'),
                ),
                PopupMenuItem<String>(
                  value: 'Opzione 2',
                  child: Text('Opzione 2'),
                ),
              ],
        ),
      ],
      backgroundColor: Colors.white,
      elevation: 0.0,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
