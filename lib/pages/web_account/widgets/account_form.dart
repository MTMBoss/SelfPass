import 'package:flutter/material.dart';
import '../../../controllers/account_controller.dart';
import '../../../models/account.dart';
import '../../../helpers/password_strength_helper.dart';
import '../../../widgets/password_generator_dialog.dart';
import 'password_field.dart';

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

  // Controllers per i campi "Scadenza" e "Data"
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

  /// Solo il "Title" non può essere rimosso.
  final List<String> nonRemovableFields = ['Title'];

  /// I campi standard per cui abbiamo widget predefiniti.
  final List<String> standardFields = [
    'Title',
    'Login',
    'Password',
    'Website',
    'Scadenza',
    'Data',
    'One-time password (2FA)',
    'Notes',
  ];

  /// Lista che determina l'ordine e la presenza dei campi nel form.
  /// Inizialmente contiene i campi standard (default).
  List<String> enabledFields = [
    'Title',
    'Login',
    'Password',
    'Website',
    'One-time password (2FA)',
    'Notes',
  ];

  /// Qui vengono memorizzati i duplicati (o campi extra) con i relativi widget e controller.
  /// Ogni entry è una mappa con le chiavi: 'label', 'controller', 'widget'
  List<Map<String, dynamic>> additionalFields = [];

  // Helper: converte una data dal formato "dd/MM/yyyy" a "yyyy-MM-dd"
  String _formatDateForParse(String dateStr) {
    final parts = dateStr.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return dateStr;
  }

  static const List<String> fieldOptions = [
    'Testo',
    'Numero',
    'Login',
    'Password',
    'Password monouso (2FA)',
    'Scadenza',
    'Sito web',
    'Email',
    'Telefono',
    'Data',
    'Pin',
    'Privato',
    'Applicazione',
  ];

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
      setState(() {}); // Trigger per il rebuild.
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.editingAccount != null) {
      _initializeWithAccount(widget.editingAccount!);
    }
    _websiteController.addListener(_onWebsiteChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  /// Metodo per rimuovere un campo se non è "Title".
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

  /// Helper che incapsula il widget del campo in una Row che aggiunge un pulsante "X"
  /// per eliminare il campo (se non è non-removibile).
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

  /// In modalità edit ricostruiamo la lista dei campi a partire dall'account salvato.
  /// Se il campo appare come duplicato (ad es. "Login (2)"), viene aggiunto a additionalFields.
  void _initializeWithAccount(Account account) {
    _titleController.text = account.accountName;
    _loginController.text = account.username;
    _passwordController.text = account.password;
    _websiteController.text = account.website;
    _iconSelectionMode = account.iconMode;
    _selectedSymbolIcon = account.symbolIcon;
    _selectedSymbolColor = account.colorIcon;
    _selectedColorIcon = account.colorIcon;

    enabledFields = List.from([
      'Title',
    ]); // "Title" è sempre presente e non eliminabile.
    for (var field in account.enabledFields) {
      if (!enabledFields.contains(field)) {
        enabledFields.add(field);
      } else {
        int count =
            enabledFields
                .where((e) => e == field || e.startsWith("$field ("))
                .length;
        enabledFields.add('$field (${count + 1})');
      }
    }
    // Aggiungiamo a additionalFields solo i duplicati (o i campi extra) che non sono esattamente quelli standard.
    additionalFields = [];
    for (var field in enabledFields) {
      // Se il campo è presente esattamente nei default (senza suffisso) lo tratteremo come default, non duplicato.
      if (standardFields.contains(field) && !field.contains('(')) continue;
      // Altrimenti, crea il widget extra.
      TextEditingController controller = TextEditingController();
      additionalFields.add({
        'label': Text(field),
        'controller': controller,
        'widget': Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: field,
              border: const OutlineInputBorder(),
              // Per "Login" (o "Email") duplicati, usiamo il suffix con l'icona per account selection.
              suffixIcon:
                  (field.startsWith('Login') || field.startsWith('Email'))
                      ? IconButton(
                        icon: const Icon(Icons.person_outline),
                        onPressed: () => _showAccountSelection(controller),
                      )
                      : null,
            ),
          ),
        ),
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _websiteController.removeListener(_onWebsiteChanged);
    _passwordController.removeListener(_onPasswordChanged);
    _websiteController.dispose();
    _otpController.dispose();
    _notesController.dispose();
    _scadenzaController.dispose();
    _dataController.dispose();
    for (var entry in additionalFields) {
      final controller = entry['controller'];
      if (controller is TextEditingController) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  /// Mostra un popup menu per selezionare uno degli account registrati.
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

  void saveAccount() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    final accountToSave = Account(
      accountName: _titleController.text.trim(),
      username: _loginController.text.trim(),
      password: _passwordController.text,
      website: _websiteController.text.trim(),
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

  /// Widget per aggiungere un nuovo campo.
  /// Se il campo esiste già, viene aggiunto un suffisso (ad esempio "Login (2)").
  Widget _buildAddFieldButton() {
    return PopupMenuButton<String>(
      onSelected: (String selectedOption) {
        setState(() {
          int count =
              enabledFields
                  .where(
                    (e) =>
                        e == selectedOption ||
                        e.startsWith("$selectedOption ("),
                  )
                  .length;
          String newFieldLabel = selectedOption;
          if (count > 0) {
            newFieldLabel = "$selectedOption (${count + 1})";
          }
          enabledFields.add(newFieldLabel);
          if (!standardFields.contains(newFieldLabel)) {
            TextEditingController? controller;
            if (selectedOption == 'Login' ||
                selectedOption == 'Email' ||
                selectedOption == 'Scadenza' ||
                selectedOption == 'Data') {
              controller = TextEditingController();
            }
            additionalFields.add({
              'label': Text(newFieldLabel),
              'widget': Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: newFieldLabel,
                    border: const OutlineInputBorder(),
                    // Per duplicati di Login o Email, mettiamo l'icona nel prefix
                    // oppure, se preferisci, nel suffix; in questo esempio la mettiamo nel prefix.
                    suffixIcon:
                        (selectedOption == 'Login' || selectedOption == 'Email')
                            ? IconButton(
                              icon: const Icon(Icons.person_outline),
                              onPressed: () {
                                if (controller != null) {
                                  _showAccountSelection(controller);
                                }
                              },
                            )
                            : null,
                  ),
                ),
              ),
              'controller': controller,
            });
          }
        });
      },
      itemBuilder: (BuildContext context) {
        return fieldOptions
            .map<PopupMenuItem<String>>(
              (String option) =>
                  PopupMenuItem<String>(value: option, child: Text(option)),
            )
            .toList();
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

  /// Costruisce il widget per un campo aggiuntivo (duplicato) usando l'entry memorizzata.
  Widget _buildAdditionalField(Map<String, dynamic> entry) {
    Text labelWidget = entry['label'] as Text;
    return Row(
      children: [
        Expanded(child: entry['widget']),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              additionalFields.remove(entry);
              enabledFields.remove(labelWidget.data);
            });
          },
        ),
      ],
    );
  }

  /// Costruisce in modo unificato il widget di un campo, dato il suo nome.
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
          // Per Login, utilizziamo il prefixIcon per la selezione account; _wrapField aggiunge la "X".
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
        case 'Scadenza':
          return _wrapField(
            'Scadenza',
            TextFormField(
              controller: _scadenzaController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Scadenza',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate:
                          _scadenzaController.text.isNotEmpty
                              ? DateTime.tryParse(
                                    _formatDateForParse(
                                      _scadenzaController.text,
                                    ),
                                  ) ??
                                  DateTime.now()
                              : DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _scadenzaController.text =
                            "${pickedDate.day.toString().padLeft(2, '0')}/"
                            "${pickedDate.month.toString().padLeft(2, '0')}/"
                            "${pickedDate.year}";
                      });
                    }
                  },
                ),
              ),
            ),
          );
        case 'Data':
          return _wrapField(
            'Data',
            TextFormField(
              controller: _dataController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Data',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate:
                          _dataController.text.isNotEmpty
                              ? DateTime.tryParse(
                                    _formatDateForParse(_dataController.text),
                                  ) ??
                                  DateTime.now()
                              : DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dataController.text =
                            "${pickedDate.day.toString().padLeft(2, '0')}/"
                            "${pickedDate.month.toString().padLeft(2, '0')}/"
                            "${pickedDate.year}";
                      });
                    }
                  },
                ),
              ),
            ),
          );
        default:
          break;
      }
    }
    // Per duplicati o campi aggiuntivi, cerchiamo l'entry in additionalFields.
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

  /// Costruisce la lista completa dei widget dei campi in base a enabledFields.
  List<Widget> _buildAllFields() {
    return enabledFields.map((field) {
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
          // Visualizza tutti i campi (default e duplicati) in un unico elenco.
          ..._buildAllFields(),
          // Pulsante per aggiungere un nuovo campo.
          _buildAddFieldButton(),
        ],
      ),
    );
  }
}
