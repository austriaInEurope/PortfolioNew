import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/services/yandex_table_service.dart';
import '../../core/widgets/ui_kit.dart';
import '../../models/work_entry_model.dart';

class ReviewEntriesScreen extends StatefulWidget {
  final String? ownerId;
  final bool isAdminView;

  const ReviewEntriesScreen({super.key, this.ownerId, this.isAdminView = true});

  @override
  State<ReviewEntriesScreen> createState() => _ReviewEntriesScreenState();
}

class _ReviewEntriesScreenState extends State<ReviewEntriesScreen> {
  final YandexTableService _service = YandexTableService();
  late Future<List<WorkEntryModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getDeleteScreenRecords(
      ownerId: widget.ownerId,
      isAdmin: widget.isAdminView,
    );
  }

  Future<void> _reload() async {
    setState(() {
      _future = _service.getDeleteScreenRecords(
        ownerId: widget.ownerId,
        isAdmin: widget.isAdminView,
      );
    });
    await _future;
  }

  Future<void> _delete(String id) async {
    await _service.deleteRecord(id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Удалить запись')),
      body: AppGradientBackground(
        child: FutureBuilder<List<WorkEntryModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data ?? [];
            if (data.isEmpty) {
              return const Center(
                child: Text('Подтвержденных записей пока нет'),
              );
            }
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  const HeaderCard(
                    title: 'Удаление подтвержденных записей',
                    subtitle:
                        'Запись удалится из приложения, но останется в облаке',
                    icon: Icons.delete_outline,
                  ),
                  const SizedBox(height: 12),
                  ...data.map((entry) => _buildEntry(entry)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEntry(WorkEntryModel entry) {
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
                    '${entry.fio} • ${entry.project}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '${NumberFormat('#,##0.##', 'ru').format(entry.salary)} ₽',
                  style: const TextStyle(
                    color: Color(0xFF9BE7FF),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${entry.date} • ${entry.start}-${entry.end}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              entry.description,
              style: const TextStyle(color: Colors.white70),
            ),
            if (entry.comment.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                'Комментарий: ${entry.comment}',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _delete(entry.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE75A5A),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Удалить запись'),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Оплата подтверждена',
                  style: TextStyle(
                    color: statusColor('Оплата подтверждена'),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
