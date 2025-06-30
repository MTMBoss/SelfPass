import 'package:flutter/material.dart';

class AggiungiImmagineButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AggiungiImmagineButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.image),
      label: const Text('Aggiungi immagine'),
      onPressed: onPressed,
    );
  }
}

class AggiungiFileButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AggiungiFileButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.attach_file),
      label: const Text('Aggiungi file'),
      onPressed: onPressed,
    );
  }
}
