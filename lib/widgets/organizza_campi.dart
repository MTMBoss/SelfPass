import 'package:flutter/material.dart';

class FieldData {
  final String fieldName;
  final String fieldValue;

  FieldData(this.fieldName, this.fieldValue);
}

void organizeFields(BuildContext context, List<FieldData> fields) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => OrganizzaCampiPage(fields: fields)),
  );
}

class OrganizzaCampiPage extends StatefulWidget {
  final List<FieldData> fields;

  const OrganizzaCampiPage({super.key, required this.fields});

  @override
  State<OrganizzaCampiPage> createState() => _OrganizzaCampiPageState();
}

class _OrganizzaCampiPageState extends State<OrganizzaCampiPage> {
  late List<FieldData> _fields;
  late List<int> _order;

  @override
  void initState() {
    super.initState();
    _fields = List<FieldData>.from(widget.fields);
    _order = List<int>.generate(_fields.length, (index) => index);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _fields.removeAt(oldIndex);
      _fields.insert(newIndex, item);

      // Update _order to reflect the move
      final orderItem = _order.removeAt(oldIndex);
      _order.insert(newIndex, orderItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizza Campi'),
        leading: IconButton(
          icon: const Icon(Icons.check),
          tooltip: 'Conferma ordine',
          onPressed: () {
            Navigator.of(context).pop<List<int>>(_order);
          },
        ),
      ),
      body: ReorderableListView(
        buildDefaultDragHandles: false,
        onReorder: _onReorder,
        children: [
          for (int index = 0; index < _fields.length; index++)
            ListTile(
              key: ValueKey(_fields[index]),

              // Drag handle only on the left
              leading: ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle),
              ),

              title: Text(_fields[index].fieldName),
              subtitle: Text(_fields[index].fieldValue),

              trailing: IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Elimina campo',
                onPressed: () {
                  setState(() {
                    _fields.removeAt(index);
                    _order.removeAt(index); // <-- tieni in sync anche l'ordine
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}
