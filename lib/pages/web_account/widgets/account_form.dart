// lib/pages/web_account/widgets/account_form.dart

import 'package:flutter/material.dart';
import 'package:otp/OTP.dart';
import '../../../controllers/account_controller.dart';
import '../../../models/account.dart';
import '../../../helpers/password_strength_helper.dart';
import '../../../widgets/password_generator_dialog.dart';
import 'password_field.dart';
import 'icon_selector.dart';
import 'additional_fields_widget.dart';
import 'otp_field_widget.dart';

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
  final TextEditingController _notesController = TextEditingController();

  final AccountController _accountController = AccountController();

  bool _passwordVisible = false;
  double _passwordStrength = 0;
  String _passwordStrengthLabel = '';
  String _passwordCrackTime = '';
  String _iconSelectionMode = 'Website Icon';
  IconData? _selectedSymbolIcon;
  Color? _selectedSymbolColor;
  Color? _selectedColorIcon;

  // Etichette non rimovibili
  final List<String> nonRemovableFields = ['Title'];

  // Tutti i campi "standard" di base
  final List<String> standardFields = [
    'Title',
    'Login',
    'Password',
    'Website',
    'Notes',
  ];

  // Etichette visibili (ordine + inclusioni dinamiche)
  List<String> enabledFields = [
    'Title',
    'Login',
    'Password',
    'Website',
    'Notes',
  ];

  // Rappresentazione interna dei campi extra
  List<Map<String, dynamic>> additionalFields = [];

  // Variabili per OTP/TOTP
  String? _otpSecret;
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _websiteController.addListener(_onWebsiteChanged);
    _passwordController.addListener(_onPasswordChanged);

    // Se stiamo modificando un account esistente, lo ripristiniamo
    if (widget.editingAccount != null) {
      setEditingAccount(widget.editingAccount);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _websiteController.dispose();
    _otpController.dispose();
    _notesController.dispose();
    for (var entry in additionalFields) {
      final ctrl = entry['controller'];
      if (ctrl is TextEditingController) ctrl.dispose();
    }
    super.dispose();
  }

  // Aggiorna il codice OTP basato su _otpSecret
  // Removed, handled in OtpFieldWidget
  void _updateOTP() {}

  // Ricalcola forza e crack‐time per la password principale
  void _onPasswordChanged() {
    final pwd = _passwordController.text;
    setState(() {
      _passwordStrength = PasswordStrengthHelper.calculatePasswordStrength(pwd);
      _passwordStrengthLabel = PasswordStrengthHelper.getStrengthLabel(
        _passwordStrength,
      );
      _passwordCrackTime = PasswordStrengthHelper.estimateCrackTime(pwd);
    });
  }

  // Ricarica l'icona se cambiamo il sito (modalità Website Icon)
  void _onWebsiteChanged() {
    if (_iconSelectionMode == 'Website Icon') {
      setState(() {});
    }
  }

  /// Ripristina l'account in modifica, evitando di duplicare le etichette
  void setEditingAccount(Account? account) {
    if (account == null) return;

    // 1) Prendo esattamente le label salvate (ordine + duplicati già gestiti)
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

    // 4) Costruisco i campi extra basati su enabledFields
    const standard = <String>{
      'Title',
      'Login',
      'Password',
      'Website',
      'One-time password (2FA)',
      'Password monouso (2FA)',
      'Notes',
    };
    int pwdIdx = 0;

    for (var label in enabledFields) {
      // Salto i campi standard
      if (standard.contains(label)) continue;

      // Se la label inizia per "Password", è password extra
      if (label.startsWith('Password')) {
        final pwd =
            (pwdIdx < account.additionalPasswords.length)
                ? account.additionalPasswords[pwdIdx++]
                : '';
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
      // Altri campi custom (text, email, note personalizzate)
      else {
        final textValue = account.extraFields?[label] ?? '';
        if (label == 'Notes') {
          _notesController.text = textValue;
        } else {
          final ctrl = TextEditingController(text: textValue);
          additionalFields.add({
            'label': Text(label),
            'type': 'text',
            'controller': ctrl,
          });
        }
      }
    }
  }

  /// Salva l'account (nuovo o modificato) e torna indietro
  void saveAccount() {
    final defaultPwd = _passwordController.text.trim();
    final List<String> extraPwds = [];
    final Map<String, String> extraData = {};

    // Raccolgo i campi extra
    for (var entry in additionalFields) {
      final type = entry['type'] as String;
      final ctrl = entry['controller'] as TextEditingController;
      final text = ctrl.text.trim();
      if (type == 'password') {
        if (text.isNotEmpty) extraPwds.add(text);
      } else if (type == 'otp') {
        // gestito via _otpSecret/_otpController
      } else {
        final label = (entry['label'] as Text).data ?? '';
        if (text.isNotEmpty) extraData[label] = text;
      }
    }

    // Aggiungo le Notes standard se non vuote
    final notes = _notesController.text.trim();
    if (notes.isNotEmpty) extraData['Notes'] = notes;

    // Validazione minima
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

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
        final updated = toSave.copyWith(id: widget.editingAccount!.id);
        _accountController.updateAccount(updated);
      } else {
        _accountController.addAccount(toSave);
      }
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving account: $e')));
    }
  }

  // Incapsula un campo con il pulsante di rimozione (se consentito)
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

  // Mostra la lista di account per selezionare uno username
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
    final position = RelativeRect.fromRect(
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
      position: position,
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
            onPasswordGenerated: (pwd, _, __) {
              setState(() => _passwordController.text = pwd);
            },
          ),
    );
  }

  // Generatore per un campo password extra
  // Removed, handled in AdditionalFieldsWidget

  // Bottone "ADD ANOTHER FIELD"
  // Removed, handled in AdditionalFieldsWidget

  // Costruisce ciascun campo extra in base al tipo
  // Removed, handled in AdditionalFieldsWidget

  // Costruisce un campo standard o lo ricerca in additionalFields
  Widget _buildField(String field) {
    if (standardFields.contains(field)) {
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
    return const SizedBox();
  }

  // Costruisce la lista di tutti i campi (escludendo 'Title' che è già in header)
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
          // Riga superiore: Title + IconSelector
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
          // Tutti gli altri campi
          ..._buildAllFields(),
          AdditionalFieldsWidget(
            additionalFields: additionalFields,
            enabledFields: enabledFields,
            onDeleteField: _deleteField,
            onAddField: (opt) {
              setState(() {
                int count =
                    enabledFields.where((e) => e.startsWith(opt)).length;
                final label = count == 0 ? opt : '$opt (${count + 1})';

                enabledFields.add(label);

                switch (opt) {
                  case 'Website':
                    additionalFields.add({
                      'label': Text(label),
                      'type': 'website',
                      'controller': TextEditingController(),
                    });
                    break;
                  case 'Password':
                    additionalFields.add({
                      'label': Text(label),
                      'type': 'password',
                      'controller': TextEditingController(),
                      'passwordVisible': false,
                      'passwordStrength': 0.0,
                      'passwordStrengthLabel': '',
                      'passwordCrackTime': '',
                    });
                    break;
                  case 'Password monouso (2FA)':
                    additionalFields.add({
                      'label': Text(label),
                      'type': 'otp',
                      'controller': TextEditingController(),
                    });
                    break;
                  default:
                    additionalFields.add({
                      'label': Text(label),
                      'type': 'text',
                      'controller': TextEditingController(),
                    });
                }
              });
            },
            onUpdateField: (entry) {
              setState(() {});
            },
          ),
          if (enabledFields.contains('One-time password (2FA)') ||
              enabledFields.contains('Password monouso (2FA)'))
            OtpFieldWidget(
              controller: _otpController,
              otpSecret: _otpSecret,
              onOtpSecretChanged: (secret) {
                setState(() {
                  _otpSecret = secret;
                  _otpController.text = OTP.generateTOTPCodeString(
                    secret,
                    DateTime.now().millisecondsSinceEpoch,
                    length: 6,
                  );
                });
              },
            ),
        ],
      ),
    );
  }
}
