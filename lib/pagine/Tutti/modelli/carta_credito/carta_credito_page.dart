import 'package:flutter/material.dart';

import 'package:selfpass/widgets/common_appbar.dart';

class CartaCreditoPage extends StatelessWidget {
  const CartaCreditoPage({super.key});

  void _save() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Carta di Credito',
        onSave: _save,
        context: context,
      ),
      body: const Center(child: Text('Pagina Carta di Credito')),
    );
  }
}
