import 'package:flutter/material.dart';
import '../../core/services/auth_session_service.dart';
import '../../core/services/yandex_table_service.dart';
import '../../core/widgets/ui_kit.dart';
import '../../screens/admin/payments_screen.dart';
import '../../screens/admin/review_entries_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/employee/add_work_screen.dart';
import '../../screens/employee/history_screen.dart';

class EmployeeHomeScreen extends StatefulWidget {
  final bool isAdmin;

  const EmployeeHomeScreen({super.key, this.isAdmin = false});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  final YandexTableService _service = YandexTableService();
  final AuthSessionService _auth = AuthSessionService.instance;

  int _all = 0;
  int _pending = 0;
  int _approved = 0;

  @override
  void initState() {
    super.initState();
    _reloadStats();
  }

  Future<void> _reloadStats() async {
    final currentUser = _auth.currentUser;
    final records = await _service.getRecords(
      ownerId: currentUser?.id,
      isAdmin: widget.isAdmin,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _all = records.length;
      _pending = records
          .where(
            (e) =>
                e.status == 'На проверке' ||
                e.status == 'Подтверждено админом' ||
                e.status == 'Исправлено',
          )
          .length;
      _approved = records
          .where((e) => e.status == 'Оплата подтверждена')
          .length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    final displayName = currentUser?.displayName ?? 'Пользователь';
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          widget.isAdmin
              ? 'ShiftFlow • Администратор'
              : 'ShiftFlow • $displayName',
        ),
        actions: [
          IconButton(
            tooltip: 'Выход',
            onPressed: () async {
              await _auth.logout();
              if (!context.mounted) {
                return;
              }
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(isAdmin: widget.isAdmin),
                ),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _reloadStats,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                HeaderCard(
                  title: 'ShiftFlow',
                  subtitle: 'Shift and payroll tracker',
                  icon: widget.isAdmin
                      ? Icons.assignment_turned_in_outlined
                      : Icons.work_outline_rounded,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _metricCard(
                        'Всего',
                        _all.toString(),
                        Icons.layers_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _metricCard(
                        'На проверке',
                        _pending.toString(),
                        Icons.schedule,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _metricCard(
                        'Подтверждено',
                        _approved.toString(),
                        Icons.check_circle_outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _menuButton(
                  text: 'Заполнить бланк',
                  subtitle: 'Новая смена и описание проделанной работы',
                  icon: Icons.playlist_add_rounded,
                  index: 0,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddWorkScreen(
                          ownerId: currentUser?.id ?? '',
                          ownerName: displayName,
                        ),
                      ),
                    );
                    _reloadStats();
                  },
                ),
                const SizedBox(height: 12),
                _menuButton(
                  text: 'История работы',
                  subtitle: widget.isAdmin
                      ? 'Подтверждайте записи сотрудников прямо в истории'
                      : 'Статусы записей и комментарии администратора',
                  icon: Icons.history_rounded,
                  index: 1,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HistoryScreen(
                          ownerId: currentUser?.id,
                          isAdmin: widget.isAdmin,
                        ),
                      ),
                    );
                    _reloadStats();
                  },
                ),
                if (!widget.isAdmin) ...[
                  const SizedBox(height: 12),
                  _menuButton(
                    text: 'Подтвердить оплату',
                    subtitle: 'Подтвердите после проверки записи администратором',
                    icon: Icons.payments_outlined,
                    index: 2,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentsScreen(
                            ownerId: currentUser?.id,
                            isAdminView: false,
                          ),
                        ),
                      );
                      _reloadStats();
                    },
                  ),
                ],
                const SizedBox(height: 12),
                _menuButton(
                  text: 'Удалить запись',
                  subtitle: 'Удаление подтвержденных записей из приложения',
                  icon: Icons.delete_outline,
                  index: widget.isAdmin ? 2 : 3,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReviewEntriesScreen(
                          ownerId: currentUser?.id,
                          isAdminView: widget.isAdmin,
                        ),
                      ),
                    );
                    _reloadStats();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFF11131A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2E3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFD0C7FF)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _menuButton({
    required String text,
    required String subtitle,
    required IconData icon,
    required int index,
    required VoidCallback onTap,
  }) {
    return AppActionTile(
      title: text,
      subtitle: subtitle,
      icon: icon,
      onTap: onTap,
      index: index,
    );
  }
}
