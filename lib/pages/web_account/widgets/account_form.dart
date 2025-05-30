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
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // New controllers for Scadenza and Data fields
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

  // Change additionalFields to store label, widget, and controller
  List<Map<String, dynamic>> additionalFields = [];
  // Make enabledFields public so it can be accessed from WebAccountPage
  List<String> enabledFields = [
    'Title',
    'Login',
    'Password',
    'Website',
    'One-time password (2FA)',
    'Notes',
  ];

  // Helper method to convert dd/MM/yyyy string to yyyy-MM-dd for DateTime.parse
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
      setState(() {
        // Trigger rebuild when website URL changes
      });
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

  void _initializeWithAccount(Account account) {
    _titleController.text = account.accountName;
    _loginController.text = account.username;
    _passwordController.text = account.password;
    _websiteController.text = account.website;
    _iconSelectionMode = account.iconMode;
    _selectedSymbolIcon = account.symbolIcon;
    _selectedSymbolColor = account.colorIcon;
    _selectedColorIcon = account.colorIcon;
    enabledFields = List.from(account.enabledFields);
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

    // Dispose new controllers
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
        // Pass the existing account's id when updating
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

  void _deleteField(String fieldName) {
    setState(() {
      enabledFields.remove(fieldName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (String field in enabledFields) ...[
            if (field == 'Title') ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: const UnderlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => _deleteField('Title'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
            ],
            if (field == 'Login') ...[
              TextFormField(
                controller: _loginController,
                decoration: InputDecoration(
                  labelText: 'Login',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Account icon button that shows registered accounts
                      IconButton(
                        icon: const Icon(Icons.person_outline),
                        onPressed: () {
                          final accounts = _accountController.accounts;
                          if (accounts.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No accounts registered'),
                              ),
                            );
                            return;
                          }
                          final RenderBox button =
                              context.findRenderObject() as RenderBox;
                          final RenderBox overlay =
                              Overlay.of(context).context.findRenderObject()
                                  as RenderBox;
                          final RelativeRect position = RelativeRect.fromRect(
                            Rect.fromPoints(
                              button.localToGlobal(
                                Offset.zero,
                                ancestor: overlay,
                              ),
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
                                        const Icon(
                                          Icons.account_circle,
                                          size: 20,
                                        ),
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
                                _loginController.text =
                                    selectedAccount.username;
                              });
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _deleteField('Login'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (field == 'Password') ...[
              PasswordField(
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
              ),
              const SizedBox(height: 16),
            ],
            if (field == 'Website') ...[
              TextFormField(
                controller: _websiteController,
                decoration: InputDecoration(
                  labelText: 'Website',
                  border: const UnderlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _deleteField('Website'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (field == 'Scadenza') ...[
              TextFormField(
                controller: _scadenzaController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Scadenza',
                  border: const UnderlineInputBorder(),
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
              const SizedBox(height: 16),
            ],
            if (field == 'Data') ...[
              TextFormField(
                controller: _dataController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Data',
                  border: const UnderlineInputBorder(),
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
              const SizedBox(height: 16),
            ],
            if (field == 'One-time password (2FA)') ...[
              TextFormField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: 'One-time password (2FA)',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.qr_code),
                        onPressed: () {
                          // QR code scanning functionality
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed:
                            () => _deleteField('One-time password (2FA)'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (field == 'Notes') ...[
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _deleteField('Notes'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],

          // Add another field button
          PopupMenuButton<String>(
            onSelected: (String selectedOption) {
              setState(() {
                TextEditingController? controller;
                if (selectedOption == 'Login' ||
                    selectedOption == 'Email' ||
                    selectedOption == 'Scadenza' ||
                    selectedOption == 'Data') {
                  controller = TextEditingController();
                }
                additionalFields.add({
                  'label': Text(selectedOption),
                  'widget': Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: selectedOption,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  'controller': controller,
                });
              });
            },
            itemBuilder: (BuildContext context) {
              return fieldOptions.map<PopupMenuItem<String>>((String option) {
                return PopupMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
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
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Additional fields
          ...additionalFields.map((entry) {
            final labelWidget = entry['label'];
            final fieldWidget = entry['widget'];
            Widget fieldWithIcon = fieldWidget!;
            if (labelWidget is Text &&
                (labelWidget.data == 'Email' || labelWidget.data == 'Login')) {
              // Wrap the TextFormField with suffixIcon containing the "omino" icon button
              final TextEditingController? controller = entry['controller'];
              fieldWithIcon = Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: labelWidget.data,
                    border: const OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.person_outline),
                          onPressed: () {
                            final accounts = _accountController.accounts;
                            if (accounts.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No accounts registered'),
                                ),
                              );
                              return;
                            }
                            final RenderBox button =
                                context.findRenderObject() as RenderBox;
                            final RenderBox overlay =
                                Overlay.of(context).context.findRenderObject()
                                    as RenderBox;
                            final RelativeRect position = RelativeRect.fromRect(
                              Rect.fromPoints(
                                button.localToGlobal(
                                  Offset.zero,
                                  ancestor: overlay,
                                ),
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
                                          const Icon(
                                            Icons.account_circle,
                                            size: 20,
                                          ),
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
                                  if (controller != null) {
                                    controller.text = selectedAccount.username;
                                  }
                                });
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              additionalFields.remove(entry);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (labelWidget is Text &&
                (labelWidget.data == 'Scadenza' ||
                    labelWidget.data == 'Data')) {
              final TextEditingController? controller = entry['controller'];
              fieldWithIcon = Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: controller,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: labelWidget.data,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate:
                              controller != null && controller.text.isNotEmpty
                                  ? DateTime.tryParse(
                                        _formatDateForParse(controller.text),
                                      ) ??
                                      DateTime.now()
                                  : DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            if (controller != null) {
                              controller.text =
                                  "${pickedDate.day.toString().padLeft(2, '0')}/"
                                  "${pickedDate.month.toString().padLeft(2, '0')}/"
                                  "${pickedDate.year}";
                            }
                          });
                        }
                      },
                    ),
                  ),
                ),
              );
            }
            return Row(
              key: ValueKey(labelWidget),
              children: [
                Expanded(child: fieldWithIcon),
                if (!(labelWidget is Text &&
                    (labelWidget.data == 'Email' ||
                        labelWidget.data == 'Login')))
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        additionalFields.remove(entry);
                      });
                    },
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
