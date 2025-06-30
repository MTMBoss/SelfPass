import 'package:flutter/material.dart';

void organizeFields(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (context) => const OrganizzaCampiPage()));
}

class OrganizzaCampiPage extends StatelessWidget {
  const OrganizzaCampiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organizza Campi')),
      body: const Center(child: Text('Qui puoi organizzare i campi.')),
    );
  }
}
