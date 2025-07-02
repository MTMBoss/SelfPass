import 'package:flutter/material.dart';

typedef MenuOptionSelected = void Function(String value);

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onSave;
  final BuildContext context;
  final VoidCallback? onOrganizzaCampi;

  const CommonAppBar({
    super.key,
    required this.title,
    required this.onSave,
    required this.context,
    this.onOrganizzaCampi,
  });

  void _handleMenuOptionSelected(String value) {
    switch (value) {
      case 'organizza':
        if (onOrganizzaCampi != null) {
          onOrganizzaCampi!();
        }
        break;
      case 'annulla':
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
      case 'modello':
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: IconButton(
        icon: const Icon(Icons.check),
        onPressed: onSave,
        tooltip: 'Salva credenziali',
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: _handleMenuOptionSelected,
          itemBuilder:
              (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'organizza',
                  child: Text('Organizza campi'),
                ),
                const PopupMenuItem<String>(
                  value: 'annulla',
                  child: Text('Annulla modifiche'),
                ),
                const PopupMenuItem<String>(
                  value: 'modello',
                  child: Text('Salva come modello'),
                ),
              ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
