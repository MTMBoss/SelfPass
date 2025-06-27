import 'package:flutter/material.dart';

import 'package:selfpass/widgets/common_appbar.dart';

class DocumentoIdPage extends StatelessWidget {
  const DocumentoIdPage({super.key});

  void _save() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'CI/Passaporto',
        onSave: _save,
        context: context,
      ),
      body: const Center(child: Text('Pagina CI/Passaporto')),
    );
  }
}
