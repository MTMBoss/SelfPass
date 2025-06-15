import 'package:flutter/material.dart';

class NotaPage extends StatelessWidget {
  const NotaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nota')),
      body: const Center(child: Text('Pagina Nota')),
    );
  }
}
