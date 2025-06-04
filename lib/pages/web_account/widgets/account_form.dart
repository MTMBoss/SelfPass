// lib/pages/web_account/widgets/account_form.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:otp/otp.dart';
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

  // Campi standard (non rimovibili) e abilitati
  final List<String> nonRemovableFields = ['Title'];
  final List<String> standardFields = [
    'Title',
    'Login',
    'Password',
    'Website',
    'One-time password (2FA)', // versione inglese
    'Password monouso (2FA)', // versione italiana alternativa
    'Notes',
  ];

  // Di default includiamo la versione OTP in inglese
  List<String> enabledFields = [
    'Title',
    'Login',
    'Password',
    'Website',
    'One-time password (2FA)',
    'Notes',
  ];

  // Campi aggiuntivi dinamici
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
  // Il countdown (OTP valido per 30 secondi)
  int _remainingSeconds = 30;
  late Timer _countdownTimer;

  // Rigenera il codice OTP utilizzando _otpSecret
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

  void _onWebsiteChanged() {
    if (_iconSelectionMode == 'Website Icon') {
      setState(() {});
    }
  }

  // Quando si modifica un account, carichiamo anche l'otpSecret se esistente
  void setEditingAccount(Account? account) {
    if (account != null) {
      _titleController.text = account.accountName;
      _loginController.text = account.username;
      _passwordController.text = account.password;
      _websiteController.text = account.website;
      _iconSelectionMode = account.iconMode;
      _selectedSymbolIcon = account.symbolIcon;
      _selectedSymbolColor = account.colorIcon;
      _selectedColorIcon = account.colorIcon;
      enabledFields = List<String>.from(account.enabledFields);

      // Se l'account possiede otpSecret, lo usiamo e rigeneriamo il codice OTP
      if (account.otpSecret != null && account.otpSecret!.isNotEmpty) {
        _otpSecret = account.otpSecret;
        _updateOTP();
      }

      additionalFields = [];
      for (var field in enabledFields) {
        if (standardFields.contains(field)) continue;
        TextEditingController controller = TextEditingController();
        String fieldType =
            field.toLowerCase().contains('password')
                ? 'password'
                : (field.toLowerCase().contains('website')
                    ? 'website'
                    : 'text');
        // Se il campo rappresenta un OTP (versione inglese o italiana)
        if (field == 'One-time password (2FA)' ||
            field == 'Password monouso (2FA)') {
          fieldType = 'otp';
          controller = _otpController;
        } else if (fieldType == 'password') {
          final RegExp reg = RegExp(r'Password\s*\((\d+)\)');
          final Match? match = reg.firstMatch(field);
          if (match != null) {
            int n = int.parse(match.group(1)!);
            int index = n - 2; // Primo extra → indice 0
            if (index >= 0 && index < account.additionalPasswords.length) {
              controller.text = account.additionalPasswords[index];
            }
          }
        } else if (fieldType == 'website') {
          controller.text = account.website;
          controller.addListener(() {
            setState(() {});
          });
        }
        additionalFields.add({
          'label': Text(field),
          'type': fieldType,
          'controller': controller,
          'passwordVisible': false,
          'passwordStrength': 0.0,
          'passwordStrengthLabel': '',
          'passwordCrackTime': '',
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _websiteController.addListener(_onWebsiteChanged);
    _passwordController.addListener(_onPasswordChanged);
    if (widget.editingAccount != null) {
      setEditingAccount(widget.editingAccount);
    }
    // Avvia un timer che ogni secondo aggiorna il countdown e, se il countdown arriva a 30, aggiorna l'OTP.
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      int secondsPassed = secondsSinceEpoch % 30;
      setState(() {
        _remainingSeconds = 30 - secondsPassed;
        if (_remainingSeconds == 30) {
          // Quando il countdown si resetta, aggiornare l'OTP
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
      final controller = entry['controller'];
      if (controller is TextEditingController) controller.dispose();
    }
    _countdownTimer.cancel();
    super.dispose();
  }

  // Salva l'account, includendo il segreto OTP (_otpSecret)
  void saveAccount() {
    String defaultPassword = _passwordController.text.trim();
    List<String> extraPasswords = [];
    for (var entry in additionalFields) {
      if (entry['type'] == 'password') {
        String txt = entry['controller'].text.trim();
        if (txt.isNotEmpty) extraPasswords.add(txt);
      }
    }
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }
    final accountToSave = Account(
      accountName: _titleController.text.trim(),
      username: _loginController.text.trim(),
      password: defaultPassword,
      additionalPasswords: extraPasswords,
      website: _websiteController.text,
      iconMode: _iconSelectionMode,
      symbolIcon: _selectedSymbolIcon,
      colorIcon: _selectedColorIcon ?? _selectedSymbolColor,
      customIconPath: null,
      isFavorite: widget.editingAccount?.isFavorite ?? false,
      enabledFields: enabledFields,
      otpSecret: _otpSecret, // Salvo il segreto OTP
    );
    try {
      if (widget.editingAccount != null) {
        final updatedAccount = accountToSave.copyWith(
          id: widget.editingAccount!.id,
        );
        _accountController.updateAccount(updatedAccount);
      } else {
        _accountController.addAccount(accountToSave);
      }
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving account: ${e.toString()}')),
      );
    }
  }

  // Widget helper per incapsulare un campo con pulsante di eliminazione (se possibile)
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

  void _deleteField(String fieldName) {
    setState(() {
      if (!nonRemovableFields.contains(fieldName)) {
        enabledFields.remove(fieldName);
        additionalFields.removeWhere(
          (entry) => (entry['label'] as Text).data == fieldName,
        );
      }
    });
  }

  void _showAccountSelection(TextEditingController controller) {
    final accounts = _accountController.accounts;
    if (accounts.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No accounts registered')));
      return;
    }
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );
    showMenu<Account>(
      context: context,
      position: position,
      items:
          accounts.map((account) {
            return PopupMenuItem<Account>(
              value: account,
              child: Row(
                children: [
                  const Icon(Icons.account_circle, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      account.username,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    ).then((selectedAccount) {
      if (selectedAccount != null) {
        setState(() {
          controller.text = selectedAccount.username;
        });
      }
    });
  }

  void _openPasswordGenerator() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PasswordGeneratorDialog(
          initialLength: 12,
          initialType: 'Random',
          initialPassword: '',
          onPasswordGenerated: (password, length, type) {
            setState(() {
              _passwordController.text = password;
            });
          },
        );
      },
    );
  }

  void _openPasswordGeneratorForField(Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PasswordGeneratorDialog(
          initialLength: 12,
          initialType: 'Random',
          initialPassword: entry['controller'].text,
          onPasswordGenerated: (password, length, type) {
            setState(() {
              entry['controller'].text = password;
              double strength =
                  PasswordStrengthHelper.calculatePasswordStrength(password);
              entry['passwordStrength'] = strength;
              entry['passwordStrengthLabel'] =
                  PasswordStrengthHelper.getStrengthLabel(strength);
              entry['passwordCrackTime'] =
                  PasswordStrengthHelper.estimateCrackTime(password);
            });
          },
        );
      },
    );
  }

  Widget _buildAddFieldButton() {
    return PopupMenuButton<String>(
      onSelected: (String selectedOption) {
        setState(() {
          if (selectedOption == 'Website') {
            TextEditingController newWebsiteController =
                TextEditingController();
            newWebsiteController.addListener(() {
              setState(() {});
            });
            int count =
                enabledFields.where((e) => e.startsWith(selectedOption)).length;
            String newFieldLabel =
                count == 0 ? selectedOption : "$selectedOption (${count + 1})";
            enabledFields.add(newFieldLabel);
            additionalFields.add({
              'label': Text(newFieldLabel),
              'type': 'website',
              'controller': newWebsiteController,
            });
          } else if (selectedOption == 'Password') {
            TextEditingController newPasswordController =
                TextEditingController();
            int count =
                enabledFields.where((e) => e.startsWith(selectedOption)).length;
            String newFieldLabel =
                count == 0 ? selectedOption : "$selectedOption (${count + 1})";
            enabledFields.add(newFieldLabel);
            additionalFields.add({
              'label': Text(newFieldLabel),
              'type': 'password',
              'controller': newPasswordController,
              'passwordVisible': false,
              'passwordStrength': 0.0,
              'passwordStrengthLabel': '',
              'passwordCrackTime': '',
            });
          } else if (selectedOption == 'Password monouso (2FA)') {
            // Gestione specifica per un campo OTP aggiuntivo
            int count =
                enabledFields.where((e) => e.startsWith(selectedOption)).length;
            String newFieldLabel =
                count == 0 ? selectedOption : "$selectedOption (${count + 1})";
            enabledFields.add(newFieldLabel);
            additionalFields.add({
              'label': Text(newFieldLabel),
              'type': 'otp',
              'controller': TextEditingController(),
            });
          } else {
            int count =
                enabledFields
                    .where(
                      (e) =>
                          e == selectedOption ||
                          e.startsWith("$selectedOption ("),
                    )
                    .length;
            String newFieldLabel =
                count > 0 ? "$selectedOption (${count + 1})" : selectedOption;
            enabledFields.add(newFieldLabel);
            TextEditingController controller = TextEditingController();
            additionalFields.add({
              'label': Text(newFieldLabel),
              'type': 'text',
              'controller': controller,
            });
          }
        });
      },
      itemBuilder: (BuildContext context) {
        return fieldOptions.map<PopupMenuItem<String>>((String option) {
          return PopupMenuItem<String>(value: option, child: Text(option));
        }).toList();
      },
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

  Widget _buildAdditionalField(Map<String, dynamic> entry) {
    if (entry['type'] == 'otp') {
      // Campo OTP aggiuntivo con icona QR e countdown
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
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QRScannerPage()),
                  );
                  if (result != null) {
                    setState(() {
                      entry['controller'].text = result;
                      _otpSecret = result;
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
    } else if (entry['type'] == 'password') {
      bool visible = entry['passwordVisible'] ?? false;
      double strength = entry['passwordStrength'] ?? 0.0;
      String strengthLabel = entry['passwordStrengthLabel'] ?? '';
      String crackTime = entry['passwordCrackTime'] ?? '';
      return PasswordField(
        controller: entry['controller'],
        passwordVisible: visible,
        passwordStrength: strength,
        passwordStrengthLabel: strengthLabel,
        passwordCrackTime: crackTime,
        onToggleVisibility: () {
          setState(() {
            entry['passwordVisible'] = !(entry['passwordVisible'] ?? false);
          });
        },
        onGeneratePassword: () {
          _openPasswordGeneratorForField(entry);
        },
        onDelete: () {
          setState(() {
            additionalFields.remove(entry);
            enabledFields.remove((entry['label'] as Text).data);
          });
        },
      );
    } else {
      return Row(
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
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                additionalFields.remove(entry);
                enabledFields.remove((entry['label'] as Text).data);
              });
            },
          ),
        ],
      );
    }
  }

  Widget _buildField(String field) {
    if (standardFields.contains(field)) {
      if (field == 'One-time password (2FA)' ||
          field == 'Password monouso (2FA)') {
        // Campo OTP standard con icona QR e countdown
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
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const QRScannerPage(),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _otpSecret = result;
                          _otpController.text = result;
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
    Map<String, dynamic>? entry;
    try {
      entry = additionalFields.firstWhere(
        (e) => (e['label'] as Text).data == field,
      );
    } catch (_) {
      entry = null;
    }
    if (entry != null) {
      return _buildAdditionalField(entry);
    }
    return const SizedBox();
  }

  List<Widget> _buildAllFields() {
    return enabledFields.where((field) => field != 'Title').map((field) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: _buildField(field),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Riga contenente il campo "Title" e il selettore delle icone
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
