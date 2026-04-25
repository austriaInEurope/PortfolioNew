import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_account_model.dart';

class AuthSessionService {
  AuthSessionService._();

  static final AuthSessionService instance = AuthSessionService._();

  static const String _accountsKey = 'shiftflow_accounts_v1';
  static const String _sessionKey = 'shiftflow_session_v1';

  SharedPreferences? _prefs;
  List<UserAccountModel> _accounts = [];
  String? _currentUserId;

  bool get hasAdminAccount => _accounts.any((account) => account.isAdmin);

  UserAccountModel? get currentUser {
    if (_currentUserId == null) {
      return null;
    }
    for (final account in _accounts) {
      if (account.id == _currentUserId) {
        return account;
      }
    }
    return null;
  }

  bool get isLoggedIn => currentUser != null;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    final rawAccounts = _prefs!.getString(_accountsKey);
    if (rawAccounts != null && rawAccounts.isNotEmpty) {
      final decoded = jsonDecode(rawAccounts);
      if (decoded is List) {
        _accounts = decoded
            .whereType<Map>()
            .map(
              (item) =>
                  UserAccountModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(growable: true);
      }
    }

    _currentUserId = _prefs!.getString(_sessionKey);
  }

  Future<String?> createAdminOnce({
    required String password,
    required String confirmPassword,
    String displayName = 'Администратор',
  }) async {
    if (hasAdminAccount) {
      return 'Администратор уже создан';
    }
    if (password.trim().isEmpty || confirmPassword.trim().isEmpty) {
      return 'Введите пароль и подтверждение';
    }
    if (password.length < 4) {
      return 'Пароль должен быть не короче 4 символов';
    }
    if (password != confirmPassword) {
      return 'Пароли не совпадают';
    }

    final admin = UserAccountModel(
      id: 'admin-root',
      username: 'admin',
      password: password,
      displayName: displayName,
      isAdmin: true,
    );
    _accounts.add(admin);
    await _saveAccounts();
    await _setSession(admin.id);
    return null;
  }

  Future<String?> registerEmployee({
    required String username,
    required String password,
    required String confirmPassword,
    required String displayName,
    double defaultRate = 850,
    String defaultProject = '',
  }) async {
    final normalized = username.trim().toLowerCase();
    if (normalized.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        displayName.trim().isEmpty) {
      return 'Заполните все поля';
    }
    if (normalized.length < 3) {
      return 'Логин должен быть не короче 3 символов';
    }
    if (password.length < 4) {
      return 'Пароль должен быть не короче 4 символов';
    }
    if (password != confirmPassword) {
      return 'Пароли не совпадают';
    }

    final exists = _accounts.any(
      (account) => account.username.toLowerCase() == normalized,
    );
    if (exists) {
      return 'Логин уже занят';
    }

    final account = UserAccountModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: normalized,
      password: password,
      displayName: displayName.trim(),
      isAdmin: false,
      defaultRate: defaultRate,
      defaultProject: defaultProject.trim(),
    );
    _accounts.add(account);
    await _saveAccounts();
    await _setSession(account.id);
    return null;
  }

  Future<String?> login({
    required String username,
    required String password,
    required bool isAdmin,
  }) async {
    final normalized = username.trim().toLowerCase();
    UserAccountModel? user;
    for (final account in _accounts) {
      final sameLogin = account.username.toLowerCase() == normalized;
      if (sameLogin && account.isAdmin == isAdmin) {
        user = account;
        break;
      }
    }

    if (user == null) {
      return isAdmin
          ? 'Аккаунт администратора не найден'
          : 'Пользователь с таким логином не найден';
    }

    if (user.password != password) {
      return 'Неверный пароль';
    }

    await _setSession(user.id);
    return null;
  }

  Future<void> logout() async {
    _currentUserId = null;
    await _prefs?.remove(_sessionKey);
  }

  Future<void> updateDefaultsForCurrentUser({
    required double defaultRate,
    required String defaultProject,
  }) async {
    if (_currentUserId == null) {
      return;
    }
    final index = _accounts.indexWhere(
      (account) => account.id == _currentUserId,
    );
    if (index == -1) {
      return;
    }
    _accounts[index] = _accounts[index].copyWith(
      defaultRate: defaultRate,
      defaultProject: defaultProject.trim(),
    );
    await _saveAccounts();
  }

  Future<void> _setSession(String id) async {
    _currentUserId = id;
    await _prefs?.setString(_sessionKey, id);
  }

  Future<void> _saveAccounts() async {
    final jsonValue = jsonEncode(_accounts.map((e) => e.toJson()).toList());
    await _prefs?.setString(_accountsKey, jsonValue);
  }
}
