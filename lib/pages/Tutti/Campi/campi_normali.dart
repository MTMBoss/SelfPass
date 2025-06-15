import 'package:flutter/material.dart';
import 'campo_testo_custom.dart';

class TitoloCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const TitoloCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Titolo',
      controller: controller,
      onRemove: onRemove,
      obscureText: false,
    );
  }
}

class SitoWebCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const SitoWebCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Sito Web',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: false,
    );
  }
}

class NoteCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const NoteCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Note',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: false,
    );
  }
}

class TestoCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const TestoCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Testo',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: false,
    );
  }
}

class NumeroCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const NumeroCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Numero',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: false,
    );
  }
}

class TelefonoCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const TelefonoCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Telefono',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: false,
    );
  }
}

class PinCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const PinCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'PIN',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: true,
    );
  }
}

class PrivatoCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const PrivatoCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Privato',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: true,
    );
  }
}

class CVVCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const CVVCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'CVV',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: true,
    );
  }
}

class BloccoCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const BloccoCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Blocco',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: false,
    );
  }
}

class ProprietarioCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const ProprietarioCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Proprietario',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: false,
    );
  }
}

class NomeCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const NomeCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Nome',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: false,
    );
  }
}

class CognomeCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const CognomeCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Cognome',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: false,
    );
  }
}

class DNSCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const DNSCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'DNS',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: false,
    );
  }
}

class DNS2Campo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const DNS2Campo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'DNS2',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: false,
    );
  }
}

class ProtocolloCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const ProtocolloCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Protocollo',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: false,
    );
  }
}

class IndirizzoIPCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const IndirizzoIPCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Indirizzo IP',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: false,
    );
  }
}

class ReteCampo extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const ReteCampo({super.key, required this.controller, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return CampoTestoCustom(
      label: 'Rete',
      controller: controller,
      onRemove: onRemove ?? () {},
      obscureText: false,
    );
  }
}
