import 'package:flutter/material.dart';

class Password2FAPage extends StatelessWidget {
  const Password2FAPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('Pagina Password monouso (2FA)')),
    );
  }
}
