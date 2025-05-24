import 'package:flutter/material.dart';

class OrganizeFieldsPage extends StatefulWidget {
  final List<String> fields;
  const OrganizeFieldsPage({super.key, required this.fields});

  @override
  OrganizeFieldsPageState createState() => OrganizeFieldsPageState();
}

class OrganizeFieldsPageState extends State<OrganizeFieldsPage> {
  late List<String> _fields;

  @override
  void initState() {
    super.initState();
    _fields = List<String>.from(widget.fields);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final String item = _fields.removeAt(oldIndex);
      _fields.insert(newIndex, item);
    });
  }

  void _onDelete(int index) {
    setState(() {
      _fields.removeAt(index);
    });
  }

  void _onSave() {
    Navigator.of(context).pop(_fields);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Organizza Campi'),
        actions: [
          IconButton(
            onPressed: _onSave,
            icon: const Icon(Icons.check, color: Colors.black),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0),
        child: ReorderableListView.builder(
          itemCount: _fields.length,
          onReorder: _onReorder,
          buildDefaultDragHandles: false,
          itemBuilder: (context, index) {
            return ListTile(
              key: ValueKey(_fields[index]),
              title: Row(
                children: [
                  // Icona di trascinamento a sinistra
                  ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle),
                  ),
                  const SizedBox(width: 12),
                  // Testo che occupa tutto lo spazio centrale
                  Expanded(
                    child: Text(
                      _fields[index],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  // Icona di chiusura tutta a destra
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _onDelete(index),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
