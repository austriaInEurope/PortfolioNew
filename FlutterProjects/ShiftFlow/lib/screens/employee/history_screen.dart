import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/services/auth_session_service.dart';
import '../../core/services/yandex_table_service.dart';
import '../../core/widgets/ui_kit.dart';
import '../../models/work_entry_model.dart';
import '../auth/login_screen.dart';
import 'add_work_screen.dart';

class HistoryScreen extends StatefulWidget {
  final String? ownerId;
  final bool isAdmin;

  const HistoryScreen({super.key, this.ownerId, this.isAdmin = false});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final YandexTableService _service = YandexTableService();
  final AuthSessionService _auth = AuthSessionService.instance;
  late Future<List<WorkEntryModel>> _future;

  bool get _isAdminView => widget.isAdmin || (_auth.currentUser?.isAdmin ?? false);

  @override
  void initState() {
    super.initState();
    _future = _service.getHistoryRecords(
      ownerId: widget.ownerId,
      isAdmin: _isAdminView,
    );
  }

  Future<void> _reload() async {
    setState(() {
      _future = _service.getHistoryRecords(
        ownerId: widget.ownerId,
        isAdmin: _isAdminView,
      );
    });
    await _future;
  }

  Future<void> _approve(WorkEntryModel entry) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтвердить запись?'),
        content: const Text('Вы уверены, что хотите подтвердить запись?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Нет'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Да'),
          ),
        ],
      ),
    );
    if (ok != true) {
      return;
    }
    await _service.approveRecordByAdmin(entry.id);
    _reload();
  }

  Future<void> _reject(WorkEntryModel entry) async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отклонить запись'),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Оставьте комментарий сотруднику',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Отправить'),
          ),
        ],
      ),
    );
    if (text == null || text.isEmpty) {
      return;
    }
    await _service.rejectPayment(id: entry.id, adminComment: text);
    _reload();
  }

  Future<void> _editAndResubmit(WorkEntryModel entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddWorkScreen(
          ownerId: entry.ownerId,
          ownerName: entry.fio,
          existingEntry: entry,
        ),
      ),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isAdminView ? 'История записей (Админ)' : 'История работ',
        ),
        actions: _isAdminView
            ? [
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
                        builder: (_) => const LoginScreen(isAdmin: true),
                      ),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded),
                ),
              ]
            : null,
      ),
      body: AppGradientBackground(
        child: FutureBuilder<List<WorkEntryModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text('Не удалось загрузить историю. Потяните вниз для повтора.'),
              );
            }
            final records = snapshot.data ?? [];
            if (records.isEmpty) {
              return const Center(
                child: Text('История пуста. Добавьте новую запись.'),
              );
            }
            final total = records.fold<double>(
              0,
              (sum, item) => sum + item.salary,
            );

            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  HeaderCard(
                    title: 'Всего записей: ${records.length}',
                    subtitle:
                        'Сумма начислений: ${NumberFormat('#,##0', 'ru').format(total)} ₽',
                    icon: Icons.insights_outlined,
                  ),
                  const SizedBox(height: 12),
                  ...records.map((entry) => _entryCard(entry)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _entryCard(WorkEntryModel entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${entry.date} • ${entry.project}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor(entry.status).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusLabel(entry.status),
                    style: TextStyle(
                      color: statusColor(entry.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entry.fio,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              entry.description,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              '${entry.start} - ${entry.end} | День: ${entry.dayHours} ч | Ночь: ${entry.nightHours} ч',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              'Начислено: ${NumberFormat('#,##0.##', 'ru').format(entry.salary)} ₽',
              style: const TextStyle(
                color: Color(0xFF9BE7FF),
                fontWeight: FontWeight.w700,
              ),
            ),
            if (entry.adminComment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Комментарий администратора: ${entry.adminComment}',
                style: const TextStyle(color: Color(0xFFFFA8A8), fontSize: 12),
              ),
            ],
            if (_isAdminView &&
                (entry.status == 'На проверке' ||
                    entry.status == 'Исправлено' ||
                    entry.status == 'Запрос оплаты')) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => _approve(entry),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4FAF93),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Подтвердить запись'),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => _reject(entry),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9A7BCE),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Отклонить'),
                    ),
                  ),
                ],
              ),
            ],
            if (!_isAdminView && entry.status == 'Не подтверждено') ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _editAndResubmit(entry),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B7BFF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Исправить и переотправить'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
