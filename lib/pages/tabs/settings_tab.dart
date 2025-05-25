import 'package:flutter/material.dart';
import '../../widgets/search_field.dart';

class SettingsTab extends StatelessWidget {
  final ValueChanged<String>? onSearchChanged;

  const SettingsTab({super.key, this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchField(onChanged: onSearchChanged),
        const Expanded(child: Center(child: Text('Pagina delle impostazioni'))),
      ],
    );
  }
}
