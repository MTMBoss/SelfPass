import 'package:flutter/material.dart';
import 'package:selfpass/modelli/credenziali.dart';
import 'package:selfpass/pagine/Tutti/modelli/account_web/aggiungi_campo.dart';

/// Ora FieldData porta direttamente il tipo!
class FieldData {
  final FieldType type;
  String value;
  FieldData(this.type, this.value);
}

class OrganizzaCampiPage extends StatefulWidget {
  final List<FieldData> fields;
  const OrganizzaCampiPage({super.key, required this.fields});

  @override
  State<OrganizzaCampiPage> createState() => _OrganizzaCampiPageState();
}

class _OrganizzaCampiPageState extends State<OrganizzaCampiPage> {
  late List<FieldData> _fields;

  @override
  void initState() {
    super.initState();
    // cloniamo la lista
    _fields = widget.fields.map((f) => FieldData(f.type, f.value)).toList();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _fields.removeAt(oldIndex);
      _fields.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizza Campi'),
        leading: IconButton(
          icon: const Icon(Icons.check),
          tooltip: 'Conferma',
          onPressed: () {
            // restituisci la lista di FieldData modificata
            Navigator.of(context).pop<List<FieldData>>(_fields);
          },
        ),
      ),
      body: ReorderableListView(
        // Disabilita le handle di default sul trailing
        buildDefaultDragHandles: false,
        onReorder: _onReorder,
        children: [
          for (var i = 0; i < _fields.length; i++)
            ListTile(
              key: ValueKey(_fields[i]),
              // Handle personalizzata a sinistra
              leading: ReorderableDragStartListener(
                index: i,
                child: const Icon(Icons.drag_handle),
              ),
              title: Text(fieldNames[_fields[i].type]!),
              subtitle: Text(_fields[i].value),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _fields.removeAt(i)),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Aggiungi campo',
        child: const Icon(Icons.add),
        onPressed: () async {
          final FieldType? picked = await showModalBottomSheet<FieldType>(
            context: context,
            builder:
                (_) => SafeArea(
                  child: ListView(
                    children:
                        FieldType.values.map((t) {
                          return ListTile(
                            title: Text(fieldNames[t]!),
                            onTap: () => Navigator.pop(context, t),
                          );
                        }).toList(),
                  ),
                ),
          );
          if (picked != null) {
            setState(() {
              _fields.add(FieldData(picked, ''));
            });
          }
        },
      ),
    );
  }
}
