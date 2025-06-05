// lib/pages/web_account/widgets/account_form.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:otp/OTP.dart';
import '../../../controllers/account_controller.dart';
import '../../../models/account.dart';
import '../../../helpers/password_strength_helper.dart';
import '../../../widgets/password_generator_dialog.dart';
import 'password_field.dart';
import 'icon_selector.dart';
import '../../qr_scanner_page.dart';

class AccountForm extends StatefulWidget {
  final Account? editingAccount;
  const AccountForm({super.key, this.editingAccount});

  @override
  AccountFormState createState() => AccountFormState();
}

class AccountFormState extends State<AccountForm> {
  // Controllers per i campi standard
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Controllers per campi aggiuntivi (es. Data, scadenza)
  final TextEditingController _scadenzaController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();

  final AccountController _accountController = AccountController();

  bool _passwordVisible = false;
  double _passwordStrength = 0;
  String _passwordStrengthLabel = '';
  String _passwordCrackTime = '';
  String _iconSelectionMode = 'Website Icon';
  IconData? _selectedSymbolIcon;
  Color? _selectedSymbolColor;
  Color? _selectedColorIcon;

  // Campi standard (non rimovibili) e predefiniti
  final List<String> nonRemovableFields = ['Title'];
  final List<String> standardFields = [
    'Title',
    'Login',
    'Password',
    'Website',
    'One-time password (2FA)', // versione inglese
    'Password monouso (2FA)', // versione italiana
    'Notes',
  ];

  List<String> enabledFields = [
    'Title',
    'Login',
    'Password',
    'Website',
    'One-time password (2FA)',
    'Notes',
  ];

  // Lista dei campi aggiuntivi inseriti manualmente.
  // Ogni voce è una Map con chiavi: 'label', 'type' e 'controller'
  List<Map<String, dynamic>> additionalFields = [];

  // Opzioni del menu "ADD ANOTHER FIELD"
  static const List<String> fieldOptions = [
    'Testo',
    'Numero',
    'Login',
    'Password',
    'Password monouso (2FA)',
    'Website',
    'Email',
    'Telefono',
    'Data',
    'Pin',
    'Privato',
    'Applicazione',
  ];

  // Variabili per il TOTP/OTP
  String? _otpSecret;
  int _remainingSeconds = 30;
  late Timer _countdownTimer;

  // Aggiorna il codice OTP usando _otpSecret
  void _updateOTP() {
    if (_otpSecret == null) return;
    final otpCode = OTP.generateTOTPCodeString(
      _otpSecret!,
      DateTime.now().millisecondsSinceEpoch,
      length: 6,
    );
    setState(() {
      _otpController.text = otpCode;
    });
  }

  // Forza e tempo di crack per la password principale
  void _onPasswordChanged() {
    final password = _passwordController.text;
    setState(() {
      _passwordStrength = PasswordStrengthHelper.calculatePasswordStrength(
        password,
      );
      _passwordStrengthLabel = PasswordStrengthHelper.getStrengthLabel(
        _passwordStrength,
      );
      _passwordCrackTime = PasswordStrengthHelper.estimateCrackTime(password);
    });
  }

  // Ricarica l'icona quando cambia il sito
  void _onWebsiteChanged() {
    if (_iconSelectionMode == 'Website Icon') {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _websiteController.addListener(_onWebsiteChanged);
    _passwordController.addListener(_onPasswordChanged);

    // Se sto modificando un account esistente, lo ripristino
    if (widget.editingAccount != null) {
      setEditingAccount(widget.editingAccount);
    }

    // Timer per il countdown OTP
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final passed = secondsSinceEpoch % 30;
      setState(() {
        _remainingSeconds = 30 - passed;
        if (_remainingSeconds == 30) {
          _updateOTP();
        }
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _websiteController.dispose();
    _otpController.dispose();
    _notesController.dispose();
    _scadenzaController.dispose();
    _dataController.dispose();
    for (var entry in additionalFields) {
      final ctrl = entry['controller'];
      if (ctrl is TextEditingController) ctrl.dispose();
    }
    _countdownTimer.cancel();
    super.dispose();
  }

  /// Ripristina interamente l'account in modifica,
  /// compresi i campi password aggiuntivi e quelli text custom.
  void setEditingAccount(Account? account) {
    if (account == null) return;

    // 1) Reset campi abilitati e lista aggiuntivi
    enabledFields = List<String>.from(account.enabledFields);
    additionalFields.clear();

    // 2) Ripristino campi standard
    _titleController.text = account.accountName;
    _loginController.text = account.username;
    _passwordController.text = account.password;
    _websiteController.text = account.website;
    _iconSelectionMode = account.iconMode;
    _selectedSymbolIcon = account.symbolIcon;
    _selectedSymbolColor = account.colorIcon;
    _selectedColorIcon = account.colorIcon;

    // 3) Ripristino OTP se presente
    _otpSecret = account.otpSecret;
    if (_otpSecret != null && _otpSecret!.isNotEmpty) {
      _updateOTP();
    }

    // 4) Ripristino password extra da additionalPasswords
    for (var pwd in account.additionalPasswords) {
      const base = 'Password';
      final count = enabledFields.where((e) => e.startsWith(base)).length;
      final label = count == 0 ? base : '$base (${count + 1})';

      enabledFields.add(label);
      final ctrl = TextEditingController(text: pwd);
      additionalFields.add({
        'label': Text(label),
        'type': 'password',
        'controller': ctrl,
        'passwordVisible': false,
        'passwordStrength': PasswordStrengthHelper.calculatePasswordStrength(
          pwd,
        ),
        'passwordStrengthLabel': PasswordStrengthHelper.getStrengthLabel(
          PasswordStrengthHelper.calculatePasswordStrength(pwd),
        ),
        'passwordCrackTime': PasswordStrengthHelper.estimateCrackTime(pwd),
      });
    }

    // 5) Ripristino campi text custom da extraFields
    if (account.extraFields != null) {
      account.extraFields!.forEach((label, value) {
        // Notes standard
        if (label == 'Notes' && enabledFields.contains(label)) {
          _notesController.text = value;
          return;
        }
        // Field custom
        if (!enabledFields.contains(label)) {
          enabledFields.add(label);
        }
        final ctrl = TextEditingController(text: value);
        additionalFields.add({
          'label': Text(label),
          'type': 'text',
          'controller': ctrl,
        });
      });
    }
  }

  /// Salva l'account (nuovo o modificato) e torna indietro
  void saveAccount() {
    final defaultPwd = _passwordController.text.trim();

    // Raccogli password extra
    final List<String> extraPwds = [];
    final Map<String, String> extraData = {};
    for (var entry in additionalFields) {
      final type = entry['type'] as String;
      final ctrl = entry['controller'] as TextEditingController;
      final text = ctrl.text.trim();
      if (type == 'password') {
        if (text.isNotEmpty) extraPwds.add(text);
      } else if (type == 'otp') {
        // gestito via _otpSecret
      } else {
        final label = (entry['label'] as Text).data ?? '';
        if (text.isNotEmpty) extraData[label] = text;
      }
    }

    // Aggiungo Notes se non vuoto
    final notes = _notesController.text.trim();
    if (notes.isNotEmpty) extraData['Notes'] = notes;

    // Validazione titolo
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    // Costruisco Account da salvare
    final toSave = Account(
      accountName: _titleController.text.trim(),
      username: _loginController.text.trim(),
      password: defaultPwd,
      additionalPasswords: extraPwds,
      website: _websiteController.text.trim(),
      iconMode: _iconSelectionMode,
      symbolIcon: _selectedSymbolIcon,
      colorIcon: _selectedColorIcon ?? _selectedSymbolColor,
      customIconPath: null,
      isFavorite: widget.editingAccount?.isFavorite ?? false,
      enabledFields: enabledFields,
      otpSecret: _otpSecret,
      extraFields: extraData.isEmpty ? null : extraData,
    );

    try {
      if (widget.editingAccount != null) {
        // update
        final updated = toSave.copyWith(id: widget.editingAccount!.id);
        _accountController.updateAccount(updated);
      } else {
        // add new
        _accountController.addAccount(toSave);
      }
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving account: $e')));
    }
  }

  // Incapsula un campo con pulsante di rimozione
  Widget _wrapField(String field, Widget child) {
    if (nonRemovableFields.contains(field)) return child;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: child),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _deleteField(field),
        ),
      ],
    );
  }

  // Rimuove un campo dinamico
  void _deleteField(String fieldName) {
    setState(() {
      if (!nonRemovableFields.contains(fieldName)) {
        enabledFields.remove(fieldName);
        additionalFields.removeWhere(
          (e) => (e['label'] as Text).data == fieldName,
        );
      }
    });
  }

  // Menu per selezionare username da altri account
  void _showAccountSelection(TextEditingController controller) {
    final all = _accountController.accounts;
    if (all.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No accounts registered')));
      return;
    }
    final buttonBox = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final pos = RelativeRect.fromRect(
      Rect.fromPoints(
        buttonBox.localToGlobal(Offset.zero, ancestor: overlay),
        buttonBox.localToGlobal(
          buttonBox.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );
    showMenu<Account>(
      context: context,
      position: pos,
      items:
          all.map((acct) {
            return PopupMenuItem<Account>(
              value: acct,
              child: Row(
                children: [
                  const Icon(Icons.account_circle, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(acct.username, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            );
          }).toList(),
    ).then((sel) {
      if (sel != null) controller.text = sel.username;
    });
  }

  // Apre il dialog di generazione password per il main password
  void _openPasswordGenerator() {
    showDialog(
      context: context,
      builder:
          (_) => PasswordGeneratorDialog(
            initialLength: 12,
            initialType: 'Random',
            initialPassword: '',
            onPasswordGenerated: (pwd, len, type) {
              setState(() => _passwordController.text = pwd);
            },
          ),
    );
  }

  // Generatore per un campo password qualunque
  void _openPasswordGeneratorForField(Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder:
          (_) => PasswordGeneratorDialog(
            initialLength: 12,
            initialType: 'Random',
            initialPassword: entry['controller'].text,
            onPasswordGenerated: (pwd, len, type) {
              setState(() {
                entry['controller'].text = pwd;
                final str = PasswordStrengthHelper.calculatePasswordStrength(
                  pwd,
                );
                entry['passwordStrength'] = str;
                entry['passwordStrengthLabel'] =
                    PasswordStrengthHelper.getStrengthLabel(str);
                entry['passwordCrackTime'] =
                    PasswordStrengthHelper.estimateCrackTime(pwd);
              });
            },
          ),
    );
  }

  // Bottone "ADD ANOTHER FIELD"
  Widget _buildAddFieldButton() {
    return PopupMenuButton<String>(
      onSelected: (opt) {
        setState(() {
          // gestione di ogni opzione analogamente all'originale
          if (opt == 'Website') {
            final ctrl = TextEditingController();
            final count = enabledFields.where((e) => e.startsWith(opt)).length;
            final label = count == 0 ? opt : '$opt (${count + 1})';
            enabledFields.add(label);
            additionalFields.add({
              'label': Text(label),
              'type': 'website',
              'controller': ctrl,
            });
          } else if (opt == 'Password') {
            final ctrl = TextEditingController();
            final count = enabledFields.where((e) => e.startsWith(opt)).length;
            final label = count == 0 ? opt : '$opt (${count + 1})';
            enabledFields.add(label);
            additionalFields.add({
              'label': Text(label),
              'type': 'password',
              'controller': ctrl,
              'passwordVisible': false,
              'passwordStrength': 0.0,
              'passwordStrengthLabel': '',
              'passwordCrackTime': '',
            });
          } else if (opt == 'Password monouso (2FA)') {
            final count = enabledFields.where((e) => e.startsWith(opt)).length;
            final label = count == 0 ? opt : '$opt (${count + 1})';
            enabledFields.add(label);
            additionalFields.add({
              'label': Text(label),
              'type': 'otp',
              'controller': TextEditingController(),
            });
          } else {
            final count =
                enabledFields
                    .where((e) => e == opt || e.startsWith("$opt ("))
                    .length;
            final label = count > 0 ? "$opt (${count + 1})" : opt;
            enabledFields.add(label);
            final ctrl = TextEditingController();
            additionalFields.add({
              'label': Text(label),
              'type': 'text',
              'controller': ctrl,
            });
          }
        });
      },
      itemBuilder:
          (ctx) =>
              fieldOptions
                  .map(
                    (opt) =>
                        PopupMenuItem<String>(value: opt, child: Text(opt)),
                  )
                  .toList(),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        child: const Text(
          'ADD ANOTHER FIELD',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // Costruisce ciascun campo extra in base al tipo
  Widget _buildAdditionalField(Map<String, dynamic> entry) {
    final type = entry['type'] as String;
    if (type == 'otp') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: entry['controller'],
                  decoration: InputDecoration(
                    labelText: (entry['label'] as Text).data,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: () async {
                  final res = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(builder: (_) => const QRScannerPage()),
                  );
                  if (res != null) {
                    setState(() {
                      entry['controller'].text = res;
                      _otpSecret = res;
                      _updateOTP();
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Expires in: $_remainingSeconds sec",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      );
    } else if (type == 'password') {
      return PasswordField(
        controller: entry['controller'] as TextEditingController,
        passwordVisible: entry['passwordVisible'] as bool,
        passwordStrength: entry['passwordStrength'] as double,
        passwordStrengthLabel: entry['passwordStrengthLabel'] as String,
        passwordCrackTime: entry['passwordCrackTime'] as String,
        onToggleVisibility: () {
          setState(() {
            entry['passwordVisible'] = !(entry['passwordVisible'] as bool);
          });
        },
        onGeneratePassword: () => _openPasswordGeneratorForField(entry),
        onDelete: () {
          setState(() {
            enabledFields.remove((entry['label'] as Text).data);
            additionalFields.remove(entry);
          });
        },
      );
    } else {
      final label = (entry['label'] as Text).data ?? '';
      InputDecoration deco = InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      );
      if (label.toLowerCase().contains('login') ||
          label.toLowerCase().contains('email')) {
        deco = deco.copyWith(
          suffixIcon: IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => _showAccountSelection(entry['controller']),
          ),
        );
      }
      return Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: entry['controller'],
              decoration: deco,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                enabledFields.remove(label);
                additionalFields.remove(entry);
              });
            },
          ),
        ],
      );
    }
  }

  // Costruisce un campo standard o cerca in additionalFields
  Widget _buildField(String field) {
    if (standardFields.contains(field)) {
      if (field == 'One-time password (2FA)' ||
          field == 'Password monouso (2FA)') {
        return _wrapField(
          field,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _otpController,
                      decoration: InputDecoration(
                        labelText: field,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () async {
                      final res = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const QRScannerPage(),
                        ),
                      );
                      if (res != null) {
                        setState(() {
                          _otpSecret = res;
                          _otpController.text = res;
                          _updateOTP();
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Expires in: $_remainingSeconds sec",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      }
      switch (field) {
        case 'Title':
          return TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          );
        case 'Login':
          return _wrapField(
            'Login',
            TextFormField(
              controller: _loginController,
              decoration: InputDecoration(
                labelText: 'Login',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () => _showAccountSelection(_loginController),
                ),
              ),
            ),
          );
        case 'Password':
          return PasswordField(
            controller: _passwordController,
            passwordVisible: _passwordVisible,
            passwordStrength: _passwordStrength,
            passwordStrengthLabel: _passwordStrengthLabel,
            passwordCrackTime: _passwordCrackTime,
            onToggleVisibility: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
            onGeneratePassword: _openPasswordGenerator,
            onDelete: () => _deleteField('Password'),
          );
        case 'Website':
          return _wrapField(
            'Website',
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website',
                border: OutlineInputBorder(),
              ),
            ),
          );
        case 'Notes':
          return _wrapField(
            'Notes',
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
          );
        default:
          return const SizedBox();
      }
    }

    // Se non è campo standard, cerco in additionalFields
    final entry = additionalFields.firstWhere(
      (e) => (e['label'] as Text).data == field,
      orElse: () => {},
    );
    if (entry.isNotEmpty) {
      return _buildAdditionalField(entry);
    }
    return const SizedBox();
  }

  List<Widget> _buildAllFields() {
    return enabledFields
        .where((f) => f != 'Title')
        .map(
          (f) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildField(f),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Riga contenente Title + IconSelector
          Row(
            children: [
              Expanded(child: _buildField('Title')),
              const SizedBox(width: 16),
              IconSelector(
                iconSelectionMode: _iconSelectionMode,
                websiteUrl: _websiteController.text,
                selectedSymbolIcon: _selectedSymbolIcon,
                selectedSymbolColor: _selectedSymbolColor,
                selectedColorIcon: _selectedColorIcon,
                onModeSelected: (mode) {
                  setState(() {
                    _iconSelectionMode = mode;
                  });
                },
                onSymbolSelected: (icon, color) {
                  setState(() {
                    _selectedSymbolIcon = icon;
                    _selectedSymbolColor = color;
                    _selectedColorIcon = null;
                  });
                },
                onColorSelected: (color) {
                  setState(() {
                    _selectedColorIcon = color;
                    _selectedSymbolIcon = null;
                    _selectedSymbolColor = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._buildAllFields(),
          _buildAddFieldButton(),
        ],
      ),
    );
  }
}
