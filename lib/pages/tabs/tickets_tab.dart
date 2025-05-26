import 'package:flutter/material.dart';
import '../../widgets/search_field.dart';

class TicketsTab extends StatelessWidget {
  final ValueChanged<String>? onSearchChanged;
  final TextEditingController? controller;
  final String? initialValue;

  const TicketsTab({
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
        const Expanded(
          child: Center(
            child: Text(
              'Pagina Biglietti',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
