import 'package:flutter/material.dart';
import '../../widgets/search_field.dart';

class SettingsTab extends StatelessWidget {
  final ValueChanged<String>? onSearchChanged;
  final TextEditingController? controller;
  final String? initialValue;

  const SettingsTab({
    super.key,
    this.onSearchChanged,
    this.controller,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchField(
          onChanged: onSearchChanged,
          controller: controller,
          initialValue: initialValue,
        ),
        const Expanded(child: Center(child: Text('Pagina delle impostazioni'))),
      ],
    );
  }
}
