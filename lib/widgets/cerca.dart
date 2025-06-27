import 'package:flutter/material.dart';

class Cerca extends StatefulWidget {
  final ValueChanged<String>? onChanged;

  const Cerca({super.key, this.onChanged});

  @override
  CercaState createState() => CercaState();
}

class CercaState extends State<Cerca> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: 'Cerca',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      onChanged: widget.onChanged,
    );
  }
}
