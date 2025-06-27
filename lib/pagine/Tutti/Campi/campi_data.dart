import 'package:flutter/material.dart';
import 'campo_testo_custom.dart';

class ScadenzaCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const ScadenzaCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Scadenza',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: false,
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
