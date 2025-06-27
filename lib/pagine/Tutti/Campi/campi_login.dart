import 'package:flutter/material.dart';
import 'package:selfpass/modelli/archivio_credenziali.dart';
import 'package:selfpass/modelli/credenziali.dart';
import 'campo_testo_custom.dart';

class LoginCampo extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const LoginCampo({super.key, required this.controller, this.onRemove});

  @override
  State<LoginCampo> createState() => _LoginCampoState();
}

class _LoginCampoState extends State<LoginCampo> {
  bool _dropdownVisible = false;

  void _toggleDropdown() {
    setState(() {
      _dropdownVisible = !_dropdownVisible;
    });
  }

  void _selectAccount(String login) {
    widget.controller.text = login;
    setState(() {
      _dropdownVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final credentials =
        CredentialStore().credentials.where((c) => c.login.isNotEmpty).toList();

    // Filter unique logins
    final uniqueLogins = <String>{};
    final uniqueCredentials = <Credential>[];
    for (var credential in credentials) {
      if (!uniqueLogins.contains(credential.login)) {
        uniqueLogins.add(credential.login);
        uniqueCredentials.add(credential);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CampoTestoCustom(
          label: 'Login',
          controller: widget.controller,
          onRemove: widget.onRemove ?? () {},
          obscureText: false,
          icon: Icons.person,
          onIconPressed: _toggleDropdown,
        ),
        if (_dropdownVisible)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              color: Theme.of(context).cardColor,
            ),
            constraints: BoxConstraints(maxHeight: 150),
            child: ListView(
              shrinkWrap: true,
              children:
                  uniqueCredentials.map((credential) {
                    return ListTile(
                      title: Text(credential.login),
                      onTap: () => _selectAccount(credential.login),
                    );
                  }).toList(),
            ),
          ),
      ],
    );
  }
}

class EmailCampo extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const EmailCampo({super.key, required this.controller, this.onRemove});

  @override
  State<EmailCampo> createState() => _EmailCampoState();
}

class _EmailCampoState extends State<EmailCampo> {
  bool _dropdownVisible = false;

  void _toggleDropdown() {
    setState(() {
      _dropdownVisible = !_dropdownVisible;
    });
  }

  void _selectAccount(String email) {
    widget.controller.text = email;
    setState(() {
      _dropdownVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final credentials =
        CredentialStore().credentials.where((c) => c.login.isNotEmpty).toList();

    // Filter unique emails
    final uniqueEmails = <String>{};
    final uniqueCredentials = <Credential>[];
    for (var credential in credentials) {
      if (!uniqueEmails.contains(credential.login)) {
        uniqueEmails.add(credential.login);
        uniqueCredentials.add(credential);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CampoTestoCustom(
          label: 'Email',
          controller: widget.controller,
          onRemove: widget.onRemove ?? () {},
          obscureText: false,
          icon: Icons.person,
          onIconPressed: _toggleDropdown,
        ),
        if (_dropdownVisible)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              color: Theme.of(context).cardColor,
            ),
            constraints: BoxConstraints(maxHeight: 150),
            child: ListView(
              shrinkWrap: true,
              children:
                  uniqueCredentials.map((credential) {
                    return ListTile(
                      title: Text(credential.login),
                      onTap: () => _selectAccount(credential.login),
                    );
                  }).toList(),
            ),
          ),
      ],
    );
  }
}
