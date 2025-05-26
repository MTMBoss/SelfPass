import 'package:flutter/material.dart';
import '../models/account.dart';

class WebAccountFormController extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  Account? editingAccount;
  bool passwordVisible = false;
  double passwordStrength = 0;
  String passwordStrengthLabel = '';
  String passwordCrackTime = '';
  String iconSelectionMode = 'Website Icon';
  IconData? selectedSymbolIcon;
  Color? selectedSymbolColor;
  Color? selectedColorIcon;
  String? selectedCustomIconPath;

  List<String> mainFields = [
    'Title',
    'Login',
    'Password',
    'Website',
    'One-time password (2FA)',
    'Notes',
  ];

  List<Map<String, Widget>> additionalFields = [];
  List<String>? lastReorderedFields;

  void setEditingAccount(Account? account) {
    if (account != null) {
      editingAccount = account;
      titleController.text = account.accountName;
      loginController.text = account.username;
      passwordController.text = account.password;
      websiteController.text = account.website;
      iconSelectionMode = account.iconMode;
      selectedSymbolIcon = account.symbolIcon;
      selectedSymbolColor = account.colorIcon;
      selectedColorIcon = account.colorIcon;
      selectedCustomIconPath = account.customIconPath;
      notifyListeners();
    }
  }

  void togglePasswordVisibility() {
    passwordVisible = !passwordVisible;
    notifyListeners();
  }

  void updateIconMode(String mode) {
    iconSelectionMode = mode;
    notifyListeners();
  }

  void updateSymbolIcon(IconData icon, Color? color) {
    selectedSymbolIcon = icon;
    selectedSymbolColor = color;
    selectedColorIcon = null;
    notifyListeners();
  }

  void updateColorIcon(Color color) {
    selectedColorIcon = color;
    selectedSymbolIcon = null;
    selectedSymbolColor = null;
    notifyListeners();
  }

  void reorderFields(List<String> newOrder) {
    lastReorderedFields = newOrder;
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    loginController.dispose();
    passwordController.dispose();
    websiteController.dispose();
    otpController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
