import 'package:flutter/material.dart';
import '../../../controllers/account_controller.dart';
import '../../../models/account.dart';
import '../../../helpers/password_strength_helper.dart';
import '../../../widgets/password_generator_dialog.dart';
import 'password_field.dart';
import 'icon_selector.dart';

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
  // Campo default per la password
  final TextEditingController _passwordController = TextEditingController();
  // Campo website standard
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Controllers per i campi Data e Scadenza
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

  /// Solo "Title" non può essere eliminato.
  final List<String> nonRemovableFields = ['Title'];

  /// Campi standard della UI
  final List<String> standardFields = [
    'Title',
    'Login',
    'Password',
    'Website',
    'One-time password (2FA)',
    'Notes',
  ];

  /// Lista dei campi visualizzati nel form.
  /// Inizialmente contiene i campi standard.
  List<String> enabledFields = [
    'Title',
    'Login',
    'Password', // Campo default per la password
    'Website', // Campo default per WebSite
    'One-time password (2FA)',
    'Notes',
  ];

  /// Struttura per i campi aggiuntivi (dinamici).
  /// Ogni voce contiene:
  /// • 'label': un widget Text che rappresenta il nome del campo
  /// • 'type': "password", "website" oppure "text"
  /// • 'controller': il TextEditingController associato
  /// • per password, anche lo stato di visibilità ed altri indicatori
  List<Map<String, dynamic>> additionalFields = [];

  // In fieldOptions includiamo "Website" per permettere all'utente di aggiungerlo (nel caso in cui venga eliminato il default)
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

  // Restituisce il sito web in uso. Se il campo standard "Website" è presente lo usa; altrimenti, cerca tra quelli aggiunti.
  String getWebsiteUrl() {
    if (enabledFields.contains('Website')) {
      return _websiteController.text;
    } else {
      for (var entry in additionalFields) {
        if (entry['type'] == 'website') {
          return (entry['controller'] as TextEditingController).text;
        }
      }
    }
    return "";
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
    // Quando cambia il valore nel campo standard, aggiorniamo l'icona.
    if (_iconSelectionMode == 'Website Icon') {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _websiteController.addListener(_onWebsiteChanged);
    _passwordController.addListener(_onPasswordChanged);
    if (widget.editingAccount != null) {
      _initializeWithAccount(widget.editingAccount!);
    }
  }

  /// Incapsula un widget campo in una Row che include un pulsante "X" per eliminarlo.
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

  /// Elimina il campo dal form.
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

  /// Modalità Edit:
  /// Utilizza direttamente la lista salvata in account.enabledFields (senza duplicare "Title")
  /// e per ogni campo extra (non standard) crea il controller. Se il campo è di tipo "password"
  /// prepopola il controller usando account.additionalPasswords; se è di tipo "website", usalo per il sito.
  void _initializeWithAccount(Account account) {
    _titleController.text = account.accountName;
    _loginController.text = account.username;
    _passwordController.text = account.password; // campo default
    _websiteController.text = account.website;
    _iconSelectionMode = account.iconMode;
    _selectedSymbolIcon = account.symbolIcon;
    _selectedSymbolColor = account.colorIcon;
    _selectedColorIcon = account.colorIcon;

    // Copia la lista salvata per non duplicare "Title"
    enabledFields = List<String>.from(account.enabledFields);

    // Per ogni campo extra (non standard) in enabledFields, crea il controller.
    additionalFields = [];
    for (var field in enabledFields) {
      if (standardFields.contains(field)) continue;
      TextEditingController controller = TextEditingController();
      String fieldType =
          field.toLowerCase().contains('password')
              ? 'password'
              : (field.toLowerCase().contains('website') ? 'website' : 'text');
      if (fieldType == 'password') {
        final RegExp reg = RegExp(r'Password\s*\((\d+)\)');
        final Match? match = reg.firstMatch(field);
        if (match != null) {
          int n = int.parse(match.group(1)!);
          int index = n - 2; // Primo extra -> indice 0
          if (index >= 0 && index < account.additionalPasswords.length) {
            controller.text = account.additionalPasswords[index];
          }
        }
      } else if (fieldType == 'website') {
        controller.text = account.website;
        // Aggiunge un listener per aggiornare in tempo reale l'icona (in caso l'utente modifichi il sito dinamico)
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
    super.dispose();
  }

  /// Mostra un popup per selezionare un account registrato.
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

  /// Salvataggio:
  /// • La password principale viene presa dal campo default.
  /// • Le password extra vengono raccolte dai campi aggiuntivi di tipo "password".
  /// • Il sito web viene determinato tramite getWebsiteUrl() (che gestisce anche i campi dinamici).
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
      website: getWebsiteUrl(),
      iconMode: _iconSelectionMode,
      symbolIcon: _selectedSymbolIcon,
      colorIcon: _selectedColorIcon ?? _selectedSymbolColor,
      customIconPath: null,
      isFavorite: widget.editingAccount?.isFavorite ?? false,
      enabledFields: enabledFields,
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

  // Apertura del generatore per un campo password aggiuntivo.
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

  /// Bottone per aggiungere un nuovo campo dinamico.
  /// Se l'opzione scelta è "Website", viene creato un campo di tipo "website"
  /// che funziona come quello standard.
  Widget _buildAddFieldButton() {
    return PopupMenuButton<String>(
      onSelected: (String selectedOption) {
        setState(() {
          if (selectedOption == 'Website') {
            TextEditingController newWebsiteController =
                TextEditingController();
            newWebsiteController.addListener(() {
              // Aggiorna in tempo reale il logo
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

  /// Costruisce il widget per un campo aggiuntivo in base alla sua configurazione.
  Widget _buildAdditionalField(Map<String, dynamic> entry) {
    if (entry['type'] == 'password') {
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
      // Per campi di tipo "text" o "website"
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

  /// Costruisce il widget per un campo (standard o aggiuntivo) in base al nome.
  Widget _buildField(String field) {
    if (standardFields.contains(field) && !field.contains('(')) {
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
        case 'One-time password (2FA)':
          return _wrapField(
            'One-time password (2FA)',
            TextFormField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: 'One-time password (2FA)',
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
          break;
      }
    }
    // Per i campi aggiuntivi (ad esempio "Password (2)" o "Website" dinamico)
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

  /// Costruisce la lista di tutti i campi da visualizzare (escluso "Title", già gestito separatamente).
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
          // Row: Campo "Title" a sinistra, IconSelector a destra.
          Row(
            children: [
              Expanded(child: _buildField('Title')),
              const SizedBox(width: 16),
              IconSelector(
                iconSelectionMode: _iconSelectionMode,
                websiteUrl: getWebsiteUrl(),
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
          // Gli altri campi (tranne Title)
          ..._buildAllFields(),
          _buildAddFieldButton(),
        ],
      ),
    );
  }
}
