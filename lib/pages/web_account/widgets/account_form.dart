import 'package:flutter/material.dart';
import '../../../controllers/account_controller.dart';
import '../../../models/account.dart';
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

  final AccountController _accountController = AccountController();

  bool _passwordVisible = false;
  final double _passwordStrength = 0;
  final String _passwordStrengthLabel = '';
  final String _passwordCrackTime = '';
  String _iconSelectionMode = 'Website Icon';
  IconData? _selectedSymbolIcon;
  Color? _selectedSymbolColor;
  Color? _selectedColorIcon;

  List<Map<String, Widget>> additionalFields = [];
  // Make enabledFields public so it can be accessed from WebAccountPage
  List<String> enabledFields = [
    'Title',
    'Login',
    'Password',
    'Website',
    'One-time password (2FA)',
    'Notes',
  ];

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
    _websiteController.dispose();
    _otpController.dispose();
    _notesController.dispose();
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
        _accountController.updateAccount(accountToSave);
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
                additionalFields.add({
                  'label': Text(selectedOption),
                  'widget': Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: selectedOption,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
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
            return Row(
              key: ValueKey(labelWidget),
              children: [
                Expanded(child: fieldWidget!),
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
