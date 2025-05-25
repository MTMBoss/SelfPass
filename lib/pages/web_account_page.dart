import 'package:flutter/material.dart';
import '../helpers/password_strength_helper.dart';
import '../widgets/password_generator_dialog.dart';

import '../models/account.dart';
import '../controllers/account_controller.dart';
import '../widgets/symbol_families_selector.dart';
import 'organize_fields_page.dart';

class WebAccountPage extends StatefulWidget {
  const WebAccountPage({super.key});

  @override
  WebAccountPageState createState() => WebAccountPageState();
}

class WebAccountPageState extends State<WebAccountPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final AccountController _accountController = AccountController();

  Account? _editingAccount;

  bool _passwordVisible = false;
  double _passwordStrength = 0;
  String _passwordStrengthLabel = '';
  String _passwordCrackTime = '';

  // Password generator state
  bool _showPasswordGenerator = false;
  int _generatedPasswordLength = 12;
  String _generatedPasswordType =
      'Random'; // Options: Memorizable, Numbers, Random, Letters+Numbers
  String _generatedPassword = '';
  final TextEditingController _generatedPasswordController =
      TextEditingController();

  // Additional fields with labels
  List<Map<String, Widget>> additionalFields = [];

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

  // Saved logins example (in real app, load from storage)
  List<String> savedLogins = ['user@example.com', 'admin@site.com', 'testuser'];

  // Icon selection mode
  String _iconSelectionMode =
      'Website Icon'; // Other options: Symbol, Color, Custom Icon

  // New icon data fields
  IconData? _selectedSymbolIcon;
  Color? _selectedSymbolColor;
  Color? _selectedColorIcon;
  String? _selectedCustomIconPath;

  // Predefined list of colors for selection
  final List<Color> _availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
    _websiteController.addListener(() {
      final websiteText = _websiteController.text.trim();
      if (websiteText.isNotEmpty) {
        setState(() {
          _iconSelectionMode = 'Website Icon';
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Account) {
      _editingAccount = args;
      _titleController.text = _editingAccount!.accountName;
      _loginController.text = _editingAccount!.username;
      _passwordController.text = _editingAccount!.password;
      _websiteController.text = _editingAccount!.website;
      _iconSelectionMode = _editingAccount!.iconMode;
      _selectedSymbolIcon = _editingAccount!.symbolIcon;
      _selectedSymbolColor = _editingAccount!.colorIcon;
      _selectedColorIcon = _editingAccount!.colorIcon;
      _selectedCustomIconPath = _editingAccount!.customIconPath;
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
    super.dispose();
  }

  List<String>? _lastReorderedFields;

  // New state list to track main fields displayed
  // ignore: prefer_final_fields
  List<String> _mainFields = [
    'Title',
    'Login',
    'Password',
    'Website',
    'One-time password (2FA)',
    'Notes',
  ];

  void _saveAccount() {
    // Reorder additionalFields if reordered fields exist
    if (_lastReorderedFields != null) {
      setState(() {
        List<String> mainFields = [
          'Title',
          'Login',
          'Password',
          'Website',
          'One-time password (2FA)',
          'Notes',
        ];
        List<String> reorderedAdditional =
            _lastReorderedFields!
                .where((f) => !mainFields.contains(f))
                .toList();
        List<Map<String, Widget>> newAdditionalFields = [];
        for (var label in reorderedAdditional) {
          var existing = additionalFields.firstWhere((entry) {
            final labelWidget = entry['label'];
            if (labelWidget is Text) {
              return labelWidget.data == label;
            }
            return false;
          }, orElse: () => <String, Widget>{});
          if (existing.isNotEmpty) {
            newAdditionalFields.add(existing);
          }
        }
        additionalFields = newAdditionalFields;
      });
    }

    // Unify colorIcon assignment to always use _selectedColorIcon
    Color? unifiedColorIcon = _selectedColorIcon;
    if (_iconSelectionMode == 'Symbol' && _selectedSymbolColor != null) {
      unifiedColorIcon = _selectedSymbolColor;
    }

    final accountToSave = Account(
      accountName: _titleController.text.trim(),
      username: _loginController.text.trim(),
      password: _passwordController.text,
      website: _websiteController.text.trim(),
      iconMode: _iconSelectionMode,
      symbolIcon: _selectedSymbolIcon,
      colorIcon: unifiedColorIcon,
      customIconPath: _selectedCustomIconPath,
    );

    if (_editingAccount != null) {
      _accountController.updateAccount(accountToSave);
    } else {
      _accountController.addAccount(accountToSave);
    }
    Navigator.pop(context);
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    final strength = PasswordStrengthHelper.calculatePasswordStrength(password);
    final label = PasswordStrengthHelper.getStrengthLabel(strength);
    final crackTime = PasswordStrengthHelper.estimateCrackTime(password);

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthLabel = label;
      _passwordCrackTime = crackTime;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  void _openPasswordGenerator() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PasswordGeneratorDialog(
          initialLength: _generatedPasswordLength,
          initialType: _generatedPasswordType,
          initialPassword: _generatedPassword,
          onPasswordGenerated: (password, length, type) {
            setState(() {
              _generatedPassword = password;
              _generatedPasswordLength = length;
              _generatedPasswordType = type;
              _passwordController.text = password;
            });
          },
        );
      },
    );
  }

  void _closePasswordGenerator() {
    setState(() {
      _showPasswordGenerator = false;
    });
  }

  void _generatePassword() {
    final length = _generatedPasswordLength;
    final type = _generatedPasswordType;
    const letters = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()-_=+[]{}|;:,.<>?';

    String chars = '';
    switch (type) {
      case 'Memorizable':
        chars = 'aeioulnrst';
        break;
      case 'Numbers':
        chars = numbers;
        break;
      case 'Random':
        chars = letters + letters.toUpperCase() + numbers + symbols;
        break;
      case 'Letters+Numbers':
        chars = letters + letters.toUpperCase() + numbers;
        break;
      default:
        chars = letters + letters.toUpperCase() + numbers + symbols;
    }

    final rand =
        List.generate(length, (index) {
          final idx =
              (DateTime.now().millisecondsSinceEpoch + index) % chars.length;
          return chars[idx];
        }).join();

    setState(() {
      _generatedPassword = rand;
    });
  }

  void _applyGeneratedPassword() {
    _passwordController.text = _generatedPassword;
    _closePasswordGenerator();
  }

  void _selectSavedLogin(String login) {
    setState(() {
      _loginController.text = login;
    });
  }

  void _selectIconMode(String mode) {
    setState(() {
      _iconSelectionMode = mode;
    });
    if (mode == 'Symbol') {
      _showSymbolSelectionDialog();
    } else if (mode == 'Color') {
      _showColorSelectionDialog();
    }
  }

  void _scanQRCode() {
    // Placeholder for QR code scanning functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Code scanner not implemented')),
    );
  }

  void _showSymbolSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Symbol Icon'),
          content: SizedBox(
            width: double.maxFinite,
            height: 350,
            child: SymbolFamiliesSelector(
              onSymbolSelected: (iconData, color) {
                setState(() {
                  _selectedSymbolIcon = iconData;
                  _selectedSymbolColor = color ?? Colors.black;
                });
                Navigator.of(context).pop();
                _showSymbolColorSelectionDialog();
              },
            ),
          ),
        );
      },
    );
  }

  void _showSymbolColorSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Symbol Color'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.count(
              crossAxisCount: 5,
              shrinkWrap: true,
              children:
                  _availableColors.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSymbolColor = color;
                          _selectedColorIcon =
                              null; // Clear color icon selection
                        });
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                _selectedSymbolColor == color
                                    ? Colors.black
                                    : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        width: 36,
                        height: 36,
                      ),
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showColorSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Color'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.count(
              crossAxisCount: 5,
              shrinkWrap: true,
              children:
                  _availableColors.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColorIcon = color;
                          _selectedSymbolIcon = null; // Clear symbol selection
                          _selectedSymbolColor = null;
                        });
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                _selectedColorIcon == color
                                    ? Colors.black
                                    : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        width: 36,
                        height: 36,
                      ),
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.check, color: Colors.black),
          onPressed: _saveAccount,
        ),
        title: const Text('Web Account'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'organize_fields':
                  // Prepare list of fields to organize
                  List<String> fieldsToOrganize = [
                    'Title',
                    'Login',
                    'Password',
                    'Website',
                    'One-time password (2FA)',
                    'Notes',
                  ];
                  // Add additional fields if any
                  for (var entry in additionalFields) {
                    final labelWidget = entry['label'];
                    if (labelWidget is Text) {
                      final label = labelWidget.data;
                      if (label != null && label.isNotEmpty) {
                        fieldsToOrganize.add(label);
                      }
                    }
                  }
                  // Navigate to OrganizeFieldsPage and await reordered fields
                  final reorderedFields = await Navigator.push<List<String>>(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              OrganizeFieldsPage(fields: fieldsToOrganize),
                    ),
                  );
                  if (reorderedFields != null) {
                    setState(() {
                      _lastReorderedFields = reorderedFields;
                      // Reorder additionalFields based on reorderedFields
                      // We keep main fields fixed, only reorder additionalFields
                      List<String> mainFields = [
                        'Title',
                        'Login',
                        'Password',
                        'Website',
                        'One-time password (2FA)',
                        'Notes',
                      ];
                      // Extract reordered additional fields
                      List<String> reorderedAdditional =
                          reorderedFields
                              .where((f) => !mainFields.contains(f))
                              .toList();
                      // Rebuild additionalFields list in new order
                      List<Map<String, Widget>> newAdditionalFields = [];
                      for (var label in reorderedAdditional) {
                        // Find existing entry with this label
                        var existing = additionalFields.firstWhere((entry) {
                          final labelWidget = entry['label'];
                          if (labelWidget is Text) {
                            return labelWidget.data == label;
                          }
                          return false;
                        }, orElse: () => <String, Widget>{});
                        if (existing.isNotEmpty) {
                          newAdditionalFields.add(existing);
                        }
                      }
                      additionalFields = newAdditionalFields;
                    });
                  }
                  break;
                case 'cancel_changes':
                  Navigator.pop(context);
                  break;
                case 'save_template':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Save as template not implemented yet'),
                    ),
                  );
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'organize_fields',
                    child: Text('Organizza Campi'),
                  ),
                  const PopupMenuItem(
                    value: 'cancel_changes',
                    child: Text('Annulla Modifiche'),
                  ),
                  const PopupMenuItem(
                    value: 'save_template',
                    child: Text('Salva come modello'),
                  ),
                ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (String field in _lastReorderedFields ?? _mainFields) ...[
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
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Opzioni'),
                                    content: const Text('Scegli un\'azione'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _mainFields.remove('Title');
                                          });
                                          _titleController.clear();
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Elimina'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Annulla'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: _selectIconMode,
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'Website Icon',
                              child: Text('Website Icon'),
                            ),
                            const PopupMenuItem(
                              value: 'Symbol',
                              child: Text('Symbol'),
                            ),
                            const PopupMenuItem(
                              value: 'Color',
                              child: Text('Color'),
                            ),
                            const PopupMenuItem(
                              value: 'Custom Icon',
                              child: Text('Custom Icon'),
                            ),
                          ],
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.transparent,
                        child:
                            _iconSelectionMode == 'Website Icon' &&
                                    _websiteController.text.isNotEmpty
                                ? _buildWebsiteFavicon()
                                : _iconSelectionMode == 'Symbol' &&
                                    _selectedSymbolIcon != null
                                ? Icon(
                                  _selectedSymbolIcon,
                                  color: _selectedSymbolColor ?? Colors.black,
                                )
                                : _iconSelectionMode == 'Color' &&
                                    _selectedColorIcon != null
                                ? Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _selectedColorIcon,
                                    shape: BoxShape.circle,
                                  ),
                                )
                                : Icon(_getIconForMode(_iconSelectionMode)),
                      ),
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
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.person),
                          onSelected: _selectSavedLogin,
                          itemBuilder:
                              (context) =>
                                  savedLogins
                                      .map(
                                        (login) => PopupMenuItem(
                                          value: login,
                                          child: Text(login),
                                        ),
                                      )
                                      .toList(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Opzioni'),
                                  content: const Text('Scegli un\'azione'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _mainFields.remove('Login');
                                        });
                                        _loginController.clear();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Elimina'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Annulla'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (field == 'Password') ...[
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                        IconButton(
                          icon: const Icon(Icons.vpn_key),
                          onPressed: _openPasswordGenerator,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Opzioni'),
                                  content: const Text('Scegli un\'azione'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _mainFields.remove('Password');
                                        });
                                        _passwordController.clear();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Elimina'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Annulla'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _passwordStrength,
                  backgroundColor: Colors.grey[300],
                  color:
                      _passwordStrength < 0.5
                          ? Colors.red
                          : _passwordStrength < 0.75
                          ? Colors.orange
                          : Colors.green,
                  minHeight: 6,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_passwordStrengthLabel),
                    Text('Crack time: $_passwordCrackTime'),
                  ],
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
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Opzioni'),
                              content: const Text('Scegli un\'azione'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _mainFields.remove('Website');
                                    });
                                    _websiteController.clear();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Elimina'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Annulla'),
                                ),
                              ],
                            );
                          },
                        );
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
                          onPressed: _scanQRCode,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Opzioni'),
                                  content: const Text('Scegli un\'azione'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _mainFields.remove(
                                            'One-time password (2FA)',
                                          );
                                        });
                                        _otpController.clear();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Elimina'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Annulla'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
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
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Opzioni'),
                              content: const Text('Scegli un\'azione'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _mainFields.remove('Notes');
                                    });
                                    _notesController.clear();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Elimina'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Annulla'),
                                ),
                              ],
                            );
                          },
                        );
                      },
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
            const SizedBox(height: 16),

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
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Opzioni'),
                            content: const Text('Scegli un\'azione'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    additionalFields.remove(entry);
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Elimina'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Annulla'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            }),

            // Attach image and attach file buttons
            Container(
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Attach image not implemented'),
                    ),
                  );
                },
                child: const Text(
                  'ATTACH IMAGE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Attach file not implemented'),
                    ),
                  );
                },
                child: const Text(
                  'ATTACH FILE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Password generator popup
            if (_showPasswordGenerator) _buildPasswordGeneratorPopup(),
          ],
        ),
      ),
    );
  }

  IconData _getIconForMode(String mode) {
    switch (mode) {
      case 'Website Icon':
        return Icons.language;
      case 'Symbol':
        return Icons.star;
      case 'Color':
        return Icons.color_lens;
      case 'Custom Icon':
        return Icons.image;
      default:
        return Icons.language;
    }
  }

  Widget _buildWebsiteFavicon() {
    final websiteUrl = _websiteController.text.trim();
    if (websiteUrl.isEmpty) {
      return Icon(_getIconForMode('Website Icon'));
    }
    final faviconUrl = _getFaviconUrl(websiteUrl);
    return ClipOval(
      child: Image.network(
        faviconUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(_getIconForMode('Website Icon'));
        },
      ),
    );
  }

  String _getFaviconUrl(String websiteUrl) {
    String domain = websiteUrl;
    if (domain.startsWith('http://')) {
      domain = domain.substring(7);
    } else if (domain.startsWith('https://')) {
      domain = domain.substring(8);
    }
    // Remove any path after domain
    if (domain.contains('/')) {
      domain = domain.split('/')[0];
    }
    // Use Google's favicon service for better favicon fetching with larger size
    return 'https://www.google.com/s2/favicons?domain=$domain&sz=64';
  }

  Widget _buildPasswordGeneratorPopup() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Generate Password',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFd4b87a),
                ),
              ),
              const SizedBox(height: 16),

              // Password display with refresh icon
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _generatedPasswordController,
                      readOnly: false,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        hintText: 'Generated password will appear here',
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFFd4b87a)),
                    onPressed: () {
                      _generatePassword();
                      _generatedPasswordController.text = _generatedPassword;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Password strength segmented bar
              Row(
                children: List.generate(4, (index) {
                  Color color;
                  if (_passwordStrength >= (index + 1) * 0.25) {
                    color = Colors.green;
                  } else if (_passwordStrength > index * 0.25) {
                    color = Colors.lightGreen;
                  } else {
                    color = Colors.grey[300]!;
                  }
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 6,
                      color: color,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 4),

              Text(
                'Crack time: $_passwordCrackTime',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),

              const SizedBox(height: 16),

              // Password length slider with label below
              Slider(
                value: _generatedPasswordLength.toDouble(),
                min: 8,
                max: 64,
                divisions: 56,
                label: _generatedPasswordLength.toString(),
                onChanged: (value) {
                  setState(() {
                    _generatedPasswordLength = value.toInt();
                    _generatePassword();
                    _generatedPasswordController.text = _generatedPassword;
                  });
                },
              ),
              Center(child: Text('Length: $_generatedPasswordLength')),

              const SizedBox(height: 16),

              // Password type dropdown with updated options
              DropdownButton<String>(
                value: _generatedPasswordType,
                items: const [
                  DropdownMenuItem(
                    value: 'Memorable',
                    child: Text('Memorable'),
                  ),
                  DropdownMenuItem(
                    value: 'Letters and numbers',
                    child: Text('Letters and numbers'),
                  ),
                  DropdownMenuItem(value: 'Random', child: Text('Random')),
                  DropdownMenuItem(
                    value: 'Numbers only',
                    child: Text('Numbers only'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _generatedPasswordType = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // OK and Cancel buttons aligned to bottom right
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _closePasswordGenerator,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _applyGeneratedPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFd4b87a),
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
