import 'package:flutter/material.dart';

import 'package:selfpass/modelli/credenziali.dart';

typedef AddFieldCallback = void Function(FieldType);

final Map<FieldType, String> fieldNames = {
  FieldType.testo: 'Testo',
  FieldType.numero: 'Numero',
  FieldType.login: 'Login',
  FieldType.password: 'Password',
  FieldType.passwordMonouso: 'Password monouso',
  FieldType.scadenza: 'Scadenza',
  FieldType.sitoWeb: 'Sito Web',
  FieldType.email: 'Email',
  FieldType.telefono: 'Telefono',
  FieldType.data: 'Data',
  FieldType.pin: 'PIN',
  FieldType.privato: 'Privato',
  FieldType.applicazione: 'Applicazione',
};

class AggiungiCampoButton extends StatelessWidget {
  final AddFieldCallback onFieldAdded;
  final BuildContext parentContext;

  const AggiungiCampoButton({
    super.key,
    required this.onFieldAdded,
    required this.parentContext,
  });

  Future<void> _showAddFieldMenu(BuildContext context) async {
    final picked = await showModalBottomSheet<FieldType>(
      context: context,
      builder:
          (ctx) => SafeArea(
            child: ListView(
              shrinkWrap: true,
              children:
                  FieldType.values.map((t) {
                    return ListTile(
                      title: Text(fieldNames[t]!),
                      onTap: () => Navigator.pop(ctx, t),
                    );
                  }).toList(),
            ),
          ),
    );
    if (picked != null) {
      onFieldAdded(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add),
      label: const Text('Aggiungi campo'),
      onPressed: () => _showAddFieldMenu(parentContext),
    );
  }
}
