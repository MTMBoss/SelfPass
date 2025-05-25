import 'package:flutter/material.dart';
import '../../widgets/search_field.dart';

class TicketsTab extends StatelessWidget {
  final ValueChanged<String>? onSearchChanged;

  const TicketsTab({super.key, this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchField(onChanged: onSearchChanged),
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
