import 'package:flutter/material.dart';

import '../../core/services/auth_session_service.dart';
import '../../core/widgets/ui_kit.dart';
import '../admin/admin_home_screen.dart';
import '../employee/employee_home_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool isAdmin;

  const LoginScreen({super.key, required this.isAdmin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool _isRegisterMode = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isAdmin) {
      loginController.text = 'admin';
    }
  }

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final isAdminSetup =
        widget.isAdmin && !AuthSessionService.instance.hasAdminAccount;
    final username = widget.isAdmin ? 'admin' : loginController.text.trim();
    final password = passwordController.text;
    if ((!widget.isAdmin && username.isEmpty) || password.isEmpty) {
      final text = widget.isAdmin ? 'Введите пароль' : 'Введите логин и пароль';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
      return;
    }

    setState(() => _isLoading = true);
    String? error;
    if (isAdminSetup) {
      error = await AuthSessionService.instance.createAdminOnce(
        password: password,
        confirmPassword: confirmPasswordController.text,
      );
    } else if (!widget.isAdmin && _isRegisterMode) {
      error = await AuthSessionService.instance.registerEmployee(
        username: username,
        password: password,
        confirmPassword: confirmPasswordController.text,
        displayName: nameController.text.trim(),
        defaultRate: 850,
        defaultProject: '',
      );
    } else {
      error = await AuthSessionService.instance.login(
        username: username,
        password: password,
        isAdmin: widget.isAdmin,
      );
    }

    if (!mounted) {
      return;
    }
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => widget.isAdmin
            ? const AdminHomeScreen()
            : const EmployeeHomeScreen(),
      ),
    );
  }

  Widget _authField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white30),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildEmployeeAuth() {
    return Column(
      children: [
        _authField(controller: loginController, hint: 'Логин'),
        const SizedBox(height: 12),
        _authField(
          controller: passwordController,
          hint: _isRegisterMode ? 'Придумайте пароль' : 'Пароль',
          obscure: true,
        ),
        if (_isRegisterMode) ...[
          const SizedBox(height: 12),
          _authField(
            controller: confirmPasswordController,
            hint: 'Повторите пароль',
            obscure: true,
          ),
          const SizedBox(height: 12),
          _authField(
            controller: nameController,
            hint: 'Ваше имя (для отчетов)',
          ),
        ],
      ],
    );
  }

  Widget _buildAdminAuth() {
    final isAdminSetup = !AuthSessionService.instance.hasAdminAccount;
    return Column(
      children: [
        _authField(
          controller: passwordController,
          hint: isAdminSetup
              ? 'Создайте пароль администратора'
              : 'Пароль администратора',
          obscure: true,
        ),
        if (isAdminSetup) ...[
          const SizedBox(height: 12),
          _authField(
            controller: confirmPasswordController,
            hint: 'Повторите пароль',
            obscure: true,
          ),
        ],
      ],
    );
  }

  Widget _modeSwitcher() {
    return Column(
      children: [
        if (!widget.isAdmin)
          TextButton(
            onPressed: () {
              setState(() {
                _isRegisterMode = !_isRegisterMode;
                passwordController.clear();
                confirmPasswordController.clear();
              });
            },
            child: Text(
              _isRegisterMode
                  ? 'Уже есть аккаунт? Войти'
                  : 'Нет аккаунта? Зарегистрироваться',
            ),
          ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => LoginScreen(isAdmin: !widget.isAdmin),
              ),
            );
          },
          child: Text(
            widget.isAdmin ? 'Войти как сотрудник' : 'Войти как администратор',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(widget.isAdmin ? 'Вход администратора' : 'Вход сотрудника'),
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderCard(
                  title: widget.isAdmin ? 'Администратор' : 'Сотрудник',
                  subtitle: widget.isAdmin
                      ? AuthSessionService.instance.hasAdminAccount
                            ? 'Вход в админский аккаунт'
                            : 'Первичная настройка администратора'
                      : _isRegisterMode
                      ? 'Создайте аккаунт сотрудника'
                      : 'Войдите в свой аккаунт',
                  icon: widget.isAdmin
                      ? Icons.verified_user_outlined
                      : Icons.badge_outlined,
                ),
                const SizedBox(height: 24),
                widget.isAdmin ? _buildAdminAuth() : _buildEmployeeAuth(),
                if (widget.isAdmin) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x1A9BE7FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AuthSessionService.instance.hasAdminAccount
                          ? 'Логин администратора: admin'
                          : 'Создайте пароль один раз. Логин администратора будет: admin',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                _modeSwitcher(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7D8CFF),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _isLoading
                        ? 'Проверка...'
                        : widget.isAdmin &&
                              !AuthSessionService.instance.hasAdminAccount
                        ? 'Создать пароль администратора'
                        : _isRegisterMode
                        ? 'Создать аккаунт'
                        : 'Войти',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
