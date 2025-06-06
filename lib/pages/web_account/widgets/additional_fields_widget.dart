import 'package:flutter/material.dart';
import '../../../helpers/password_strength_helper.dart';
import '../../../widgets/password_generator_dialog.dart';
import 'password_field.dart';

class AdditionalFieldsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> additionalFields;
  final List<String> enabledFields;
  final Function(String) onDeleteField;
  final Function(String) onAddField;
  final Function(Map<String, dynamic>) onUpdateField;

  static const List<String> fieldOptions = [
    'Testo',
    'Numero',
    'Login',
    'Password',
    'Password monouso (2FA)',
    'Website',
    'Email',
    'Telefono',
    'Data',
    'Pin',
    'Privato',
    'Applicazione',
  ];

  const AdditionalFieldsWidget({
    super.key,
    required this.additionalFields,
    required this.enabledFields,
    required this.onDeleteField,
    required this.onAddField,
    required this.onUpdateField,
  });

  void _openPasswordGenerator(
    BuildContext context,
    Map<String, dynamic> entry,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => PasswordGeneratorDialog(
            initialLength: 12,
            initialType: 'Random',
            initialPassword: entry['controller'].text,
            onPasswordGenerated: (pwd, _, __) {
              entry['controller'].text = pwd;
              final str = PasswordStrengthHelper.calculatePasswordStrength(pwd);
              entry['passwordStrength'] = str;
              entry['passwordStrengthLabel'] =
                  PasswordStrengthHelper.getStrengthLabel(str);
              entry['passwordCrackTime'] =
                  PasswordStrengthHelper.estimateCrackTime(pwd);
              onUpdateField(entry);
            },
          ),
    );
  }

  Widget _buildAdditionalField(
    BuildContext context,
    Map<String, dynamic> entry,
  ) {
    final type = entry['type'] as String;

    if (type == 'password') {
      return PasswordField(
        controller: entry['controller'],
        passwordVisible: entry['passwordVisible'] as bool,
        passwordStrength: entry['passwordStrength'] as double,
        passwordStrengthLabel: entry['passwordStrengthLabel'] as String,
        passwordCrackTime: entry['passwordCrackTime'] as String,
        onToggleVisibility: () {
          entry['passwordVisible'] = !(entry['passwordVisible'] as bool);
          onUpdateField(entry);
        },
        onGeneratePassword: () => _openPasswordGenerator(context, entry),
        onDelete: () => onDeleteField((entry['label'] as Text).data ?? ''),
      );
    } else {
      final label = (entry['label'] as Text).data ?? '';
      InputDecoration deco = InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      );
      if (label.toLowerCase().contains('login') ||
          label.toLowerCase().contains('email')) {
        deco = deco.copyWith(
          suffixIcon: IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // This callback can be implemented if needed
            },
          ),
        );
      }
      return Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: entry['controller'],
              decoration: deco,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => onDeleteField(label),
          ),
        ],
      );
    }
  }

  Widget _buildAddFieldButton(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (opt) => onAddField(opt),
      itemBuilder:
          (ctx) =>
              fieldOptions
                  .map(
                    (opt) =>
                        PopupMenuItem<String>(value: opt, child: Text(opt)),
                  )
                  .toList(),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        child: const Text(
          'ADD ANOTHER FIELD',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...enabledFields.where((f) => f != 'Title').map((field) {
          final entry = additionalFields.firstWhere(
            (e) => (e['label'] as Text).data == field,
            orElse: () => <String, dynamic>{},
          );
          if (entry.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildAdditionalField(context, entry),
            );
          }
          return const SizedBox();
        }),
        _buildAddFieldButton(context),
      ],
    );
  }
}
