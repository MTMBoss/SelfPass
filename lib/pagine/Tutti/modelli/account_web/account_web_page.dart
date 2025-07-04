// lib/pages/Tutti/moduli/account_web/account_web_page.dart

import 'package:flutter/material.dart';
import 'package:selfpass/modelli/credenziali.dart';
import 'package:selfpass/modelli/archivio_credenziali.dart';
import 'dart:io';

import 'package:selfpass/utils/file_utils.dart';

import 'package:open_file/open_file.dart';

import '../../Campi/campo_titolo.dart';
import '../../Campi/campo_app.dart';
import '../../Campi/campo_testo_custom.dart';
import '../../Campi/campi_login.dart';
import '../../Campi/campi_data.dart';
import '../../Campi/campo_qr.dart';
import 'aggiungi_campo.dart';
import 'aggiungi_file_immagine.dart';

import 'package:selfpass/widgets/common_appbar.dart';
import 'package:logger/logger.dart';

import 'package:selfpass/widgets/organizza_campi.dart';

typedef FieldBuilder =
    Widget Function(TextEditingController controller, VoidCallback onRemove);

final Map<FieldType, FieldBuilder> fieldBuilders = {
  FieldType.testo:
      (c, rm) => CampoTestoCustom(label: 'Testo', controller: c, onRemove: rm),
  FieldType.numero:
      (c, rm) => CampoTestoCustom(label: 'Numero', controller: c, onRemove: rm),
  FieldType.login: (c, rm) => LoginCampo(controller: c, onRemove: rm),
  FieldType.password:
      (c, rm) => CampoTestoCustom(
        controller: c,
        onRemove: rm,
        label: 'Password',
        passwordGenerator: true,
      ),
  FieldType.passwordMonouso:
      (c, rm) => PasswordMonousoCampo(controller: c, onRemove: rm),
  FieldType.scadenza: (c, rm) => ScadenzaCampo(controller: c, onRemove: rm),
  FieldType.sitoWeb:
      (c, rm) =>
          CampoTestoCustom(label: 'Sito Web', controller: c, onRemove: rm),
  FieldType.email: (c, rm) => EmailCampo(controller: c, onRemove: rm),
  FieldType.telefono:
      (c, rm) =>
          CampoTestoCustom(label: 'Telefono', controller: c, onRemove: rm),
  FieldType.data: (c, rm) => DataCampo(controller: c, onRemove: rm),
  FieldType.pin:
      (c, rm) => CampoTestoCustom(
        label: 'PIN',
        controller: c,
        onRemove: rm,
        obscureText: true,
      ),
  FieldType.privato:
      (c, rm) => CampoTestoCustom(
        label: 'Privato',
        controller: c,
        onRemove: rm,
        obscureText: true,
      ),
  FieldType.applicazione:
      (c, rm) => Row(
        children: [
          Expanded(child: ApplicazioneCampo(controller: c)),
          IconButton(icon: const Icon(Icons.close), onPressed: rm),
        ],
      ),
};

class AccountWebPage extends StatefulWidget {
  final Credential? credential;
  const AccountWebPage({super.key, this.credential});

  @override
  State<AccountWebPage> createState() => _AccountWebPageState();
}

class _AccountWebPageState extends State<AccountWebPage> {
  late final TextEditingController titoloController;

  Color selectedColor = Colors.black;
  String? customSymbol;
  bool applyColorToEmoji = false;
  String? faviconUrl;

  final List<FieldType> _selectedFields = [];
  final List<TextEditingController> _controllers = [];

  String? _selectedImagePath;
  String? _selectedFileName;
  String? _selectedFilePath;

  @override
  void initState() {
    super.initState();
    final c = widget.credential;

    titoloController = TextEditingController(text: c?.titolo ?? '');

    if (c != null) {
      if (c.selectedColorValue != null) {
        selectedColor = Color(c.selectedColorValue!);
      }
      customSymbol = c.customSymbol;
      applyColorToEmoji = c.applyColorToEmoji;
      faviconUrl = c.faviconUrl;
      _selectedImagePath = c.imagePath;
      _selectedFilePath = c.filePath;
      _selectedFileName = null; // Will set below if filePath exists
      if (_selectedFilePath != null) {
        // Extract file name from path
        _selectedFileName = basename(_selectedFilePath!);
      }
    }

    // Campi standard
    void addIf(bool cond, FieldType t, String text) {
      if (cond) {
        _selectedFields.add(t);
        _controllers.add(TextEditingController(text: text));
      }
    }

    addIf(c == null || c.showLogin, FieldType.login, c?.login ?? '');
    addIf(c == null || c.showPassword, FieldType.password, c?.password ?? '');
    addIf(c == null || c.showSitoWeb, FieldType.sitoWeb, c?.sitoWeb ?? '');
    addIf(
      c == null || c.showPasswordMonouso,
      FieldType.passwordMonouso,
      c?.passwordMonouso ?? '',
    );
    addIf(c == null || c.showNote, FieldType.testo, c?.note ?? '');

    // Campi custom salvati
    if (c != null) {
      for (final cf in c.customFields) {
        _selectedFields.add(cf.type);
        _controllers.add(TextEditingController(text: cf.value));
      }
    }
  }

  @override
  void dispose() {
    titoloController.dispose();
    for (final ctrl in _controllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _removeAt(int i) {
    setState(() {
      _selectedFields.removeAt(i);
      _controllers[i].dispose();
      _controllers.removeAt(i);
    });
  }

  String _getFirst(FieldType t) {
    for (int i = 0; i < _selectedFields.length; i++) {
      if (_selectedFields[i] == t) return _controllers[i].text;
    }
    return '';
  }

  void _saveCredentials() {
    // Validate required fields before saving
    if (_getFirst(FieldType.login).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Il campo Login è obbligatorio.')),
      );
      return;
    }
    if (_getFirst(FieldType.password).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Il campo Password è obbligatorio.')),
      );
      return;
    }

    // 1) quali tipi sono “standard”
    // 2) vedremo se abbiamo già incontrato la loro prima occorrenza
    final defaultTypes = <FieldType>{
      FieldType.login,
      FieldType.password,
      FieldType.sitoWeb,
      FieldType.passwordMonouso,
      FieldType.testo,
    };
    final seenDefault = <FieldType, bool>{};

    final extras = <CustomField>[];
    for (int i = 0; i < _selectedFields.length; i++) {
      final type = _selectedFields[i];
      final value = _controllers[i].text;

      // se è un tipo di default e non ne abbiamo ancora “saltata” la prima occorrenza,
      // allora lo escludiamo (è quello standard); altrimenti lo includiamo
      if (defaultTypes.contains(type)) {
        if (seenDefault[type] == true) {
          // seconda (o terza...) password → la salvo come custom
          extras.add(CustomField(type, value));
        } else {
          // prima password/login/etc → lo ignoro
          seenDefault[type] = true;
        }
      } else {
        // ogni tipo non‐default è sempre custom
        extras.add(CustomField(type, value));
      }
    }

    final newCred = Credential(
      titolo: titoloController.text,
      login: _getFirst(FieldType.login),
      password: _getFirst(FieldType.password),
      sitoWeb: _getFirst(FieldType.sitoWeb),
      passwordMonouso: _getFirst(FieldType.passwordMonouso),
      note: _getFirst(FieldType.testo),
      showLogin: _selectedFields.contains(FieldType.login),
      showPassword: _selectedFields.contains(FieldType.password),
      showSitoWeb: _selectedFields.contains(FieldType.sitoWeb),
      showPasswordMonouso: _selectedFields.contains(FieldType.passwordMonouso),
      showNote: _selectedFields.contains(FieldType.testo),
      selectedColorValue: selectedColor.toARGB32(),
      customSymbol: customSymbol,
      applyColorToEmoji: applyColorToEmoji,
      faviconUrl: faviconUrl,
      customFields: extras, // <-- solo custom
      imagePath: _selectedImagePath,
      filePath: _selectedFilePath,
    );

    final store = CredentialStore();
    if (widget.credential != null) {
      store.updateCredential(widget.credential!, newCred);
    } else {
      store.addCredential(newCred);
    }
    Navigator.of(context).pop(newCred);

    // Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Credenziali salvate con successo.')),
    );
  }

  TextEditingController? _getControllerOf(FieldType t) {
    for (int i = 0; i < _selectedFields.length; i++) {
      if (_selectedFields[i] == t) return _controllers[i];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Account Web',
        onSave: _saveCredentials,
        context: context,
        onOrganizzaCampi: () async {
          // costruisco la lista di FieldData con tipo+valore
          final fields = <FieldData>[];
          for (int i = 0; i < _selectedFields.length; i++) {
            fields.add(FieldData(_selectedFields[i], _controllers[i].text));
          }

          // apro OrganizzaCampiPage e aspetto il risultato
          final reordered = await Navigator.of(context).push<List<FieldData>>(
            MaterialPageRoute(
              builder: (_) => OrganizzaCampiPage(fields: fields),
            ),
          );
          if (reordered == null) return;

          // ricostruisco _selectedFields e _controllers secondo l'ordine e i valori ritornati
          setState(() {
            _selectedFields.clear();
            for (final ctrl in _controllers) {
              ctrl.dispose();
            }
            _controllers.clear();

            for (var fd in reordered) {
              _selectedFields.add(fd.type);
              _controllers.add(TextEditingController(text: fd.value));
            }
          });
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TitoloCampo(
              controller: titoloController,
              sitoWebController: _getControllerOf(FieldType.sitoWeb),
              selectedColor: selectedColor,
              customSymbol: customSymbol,
              applyColorToEmoji: applyColorToEmoji,
              faviconUrl: faviconUrl,
              onSelectedColorChanged:
                  (c) => WidgetsBinding.instance.addPostFrameCallback(
                    (_) => setState(() => selectedColor = c),
                  ),
              onCustomSymbolChanged:
                  (s) => WidgetsBinding.instance.addPostFrameCallback(
                    (_) => setState(() => customSymbol = s),
                  ),
              onApplyColorToEmojiChanged:
                  (v) => WidgetsBinding.instance.addPostFrameCallback(
                    (_) => setState(() => applyColorToEmoji = v),
                  ),
              onFaviconUrlChanged:
                  (u) => WidgetsBinding.instance.addPostFrameCallback(
                    (_) => setState(() => faviconUrl = u),
                  ),
            ),
            const SizedBox(height: 12),

            for (int i = 0; i < _selectedFields.length; i++) ...[
              fieldBuilders[_selectedFields[i]]!(
                _controllers[i],
                () => _removeAt(i),
              ),
              const SizedBox(height: 12),
            ],

            AggiungiCampoButton(
              parentContext: context,
              onFieldAdded: (FieldType t) {
                setState(() {
                  _selectedFields.add(t);
                  _controllers.add(TextEditingController());
                });
              },
            ),
            const SizedBox(height: 8),
            AggiungiImmagineButton(
              onImageSelected: (image) {
                if (image != null) {
                  final path = (image as dynamic).path;
                  Logger().i('Selected image path: $path');
                  setState(() {
                    _selectedImagePath = path;
                  });
                }
              },
            ),
            if (_selectedImagePath != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => FullScreenImagePage(
                            imagePath: _selectedImagePath!,
                          ),
                    ),
                  );
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Image.file(
                    File(_selectedImagePath!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            AggiungiFileButton(
              onFileSelected: (file) {
                if (file != null) {
                  final name = (file as dynamic).name;
                  final path = (file as dynamic).path;
                  Logger().i('Selected file name: $name');
                  setState(() {
                    _selectedFileName = name;
                    _selectedFilePath = path;
                  });
                }
              },
            ),
            if (_selectedFileName != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  if (_selectedFilePath != null) {
                    OpenFile.open(_selectedFilePath!);
                  }
                },
                child: Text(
                  _selectedFileName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imagePath;

  const FullScreenImagePage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: InteractiveViewer(child: Image.file(File(imagePath))),
      ),
    );
  }
}
