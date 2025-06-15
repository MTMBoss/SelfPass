import 'package:flutter/material.dart';

class PersonalizzatoPage extends StatelessWidget {
  const PersonalizzatoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personalizzato')),
      body: const Center(child: Text('Pagina Personalizzato')),
    );
  }
}
