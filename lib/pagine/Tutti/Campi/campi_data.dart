import 'package:flutter/material.dart';
import 'campo_testo_custom.dart';

class ScadenzaCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const ScadenzaCampo({super.key, required this.controller, this.onRemove});

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text =
          "${picked.day.toString().padLeft(2, '0')}/"
          "${picked.month.toString().padLeft(2, '0')}/"
          "${picked.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Scadenza',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: false,
      icon: Icons.calendar_today,
      onIconPressed: () => _selectDate(context),
    );
  }
}

class DataCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const DataCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Data',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: false,
    );
  }
}

class DataNascitaCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const DataNascitaCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Data di Nascita',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: false,
    );
  }
}

class RilascioCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const RilascioCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Rilascio',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: false,
    );
  }
}
