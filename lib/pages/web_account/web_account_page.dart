import 'package:flutter/material.dart';
import '../../models/account.dart';
import 'widgets/account_form.dart';
import '../organize_fields_page.dart';

class WebAccountPage extends StatefulWidget {
  const WebAccountPage({super.key});

  @override
  WebAccountPageState createState() => WebAccountPageState();
}

class WebAccountPageState extends State<WebAccountPage> {
  Account? _editingAccount;
  final _formKey = GlobalKey<AccountFormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Account) {
      _editingAccount = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.check, color: Colors.black),
          onPressed: () {
            if (_formKey.currentState != null) {
              _formKey.currentState!.saveAccount();
            }
          },
        ),
        title: const Text('Web Account'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'organize_fields':
                  if (_formKey.currentState != null) {
                    List<String> fieldsToOrganize = List.from(
                      _formKey.currentState!.enabledFields,
                    );
                    // Add additional fields if any
                    for (var entry in _formKey.currentState!.additionalFields) {
                      final labelWidget = entry['label'];
                      if (labelWidget is Text) {
                        final label = labelWidget.data;
                        if (label != null && label.isNotEmpty) {
                          fieldsToOrganize.add(label);
                        }
                      }
                    }
                    // Navigate to OrganizeFieldsPage
                    final reorderedFields = await Navigator.push<List<String>>(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                OrganizeFieldsPage(fields: fieldsToOrganize),
                      ),
                    );
                    if (reorderedFields != null &&
                        _formKey.currentState != null) {
                      _formKey.currentState!.setState(() {
                        _formKey.currentState!.enabledFields = reorderedFields;
                      });
                    }
                  }
                  break;
                case 'cancel_changes':
                  Navigator.pop(context);
                  break;
                case 'save_template':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Save as template not implemented yet'),
                    ),
                  );
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'organize_fields',
                    child: Text('Organizza Campi'),
                  ),
                  const PopupMenuItem(
                    value: 'cancel_changes',
                    child: Text('Annulla Modifiche'),
                  ),
                  const PopupMenuItem(
                    value: 'save_template',
                    child: Text('Salva come modello'),
                  ),
                ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: AccountForm(key: _formKey, editingAccount: _editingAccount),
    );
  }
}
