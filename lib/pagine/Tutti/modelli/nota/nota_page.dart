import 'package:flutter/material.dart';

import 'package:selfpass/widgets/common_appbar.dart';

class NotaPage extends StatelessWidget {
  const NotaPage({super.key});

  void _save() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Nota', onSave: _save, context: context),
      body: const Center(child: Text('Pagina Nota')),
    );
  }
}
