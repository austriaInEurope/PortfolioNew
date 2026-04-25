import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/services/auth_session_service.dart';
import 'core/services/work_entries_store.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/ui_kit.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/employee/employee_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  await AuthSessionService.instance.init();
  await WorkEntriesStore.instance.init();
  runApp(const ShiftFlowApp());
}

class ShiftFlowApp extends StatelessWidget {
  const ShiftFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShiftFlow',
      theme: AppTheme.dark(),
      home: const BootstrapScreen(),
    );
  }
}

class BootstrapScreen extends StatelessWidget {
  const BootstrapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthSessionService.instance.currentUser;
    if (currentUser != null) {
      if (currentUser.isAdmin) {
        return const AdminHomeScreen();
      }
      return const EmployeeHomeScreen(isAdmin: false);
    }
    return const StartScreen();
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  'ShiftFlow',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Учет смен, проверка и выплаты в одном месте',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 28),
                const HeaderCard(
                  title: 'Рабочий кабинет',
                  subtitle: 'Выберите роль для входа в систему',
                  icon: Icons.workspace_premium_outlined,
                ),
                const Spacer(),
                _roleButton(
                  context: context,
                  icon: Icons.person_outline_rounded,
                  title: 'Сотрудник',
                  subtitle: 'Создать запись и отследить статус',
                  index: 0,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(isAdmin: false),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                _roleButton(
                  context: context,
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Администратор',
                  subtitle: 'Проверка записей сотрудников и комментарии',
                  index: 1,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(isAdmin: true),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required int index,
    required VoidCallback onPressed,
  }) {
    return AppActionTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      onTap: onPressed,
      index: index,
    );
  }
}
