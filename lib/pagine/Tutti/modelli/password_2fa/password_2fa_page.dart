import 'package:flutter/material.dart';

import 'package:selfpass/widgets/common_appbar.dart';

class Password2FAPage extends StatelessWidget {
  const Password2FAPage({super.key});

  void _save() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Password monouso (2FA)',
        onSave: _save,
        context: context,
      ),
      body: const Center(child: Text('Pagina Password monouso (2FA)')),
    );
  }
}
