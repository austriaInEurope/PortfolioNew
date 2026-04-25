import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/services/yandex_table_service.dart';
import '../../core/widgets/ui_kit.dart';
import '../../models/work_entry_model.dart';

class PaymentsScreen extends StatefulWidget {
  final String? ownerId;
  final bool isAdminView;

  const PaymentsScreen({super.key, this.ownerId, this.isAdminView = true});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final YandexTableService _service = YandexTableService();
  late Future<List<WorkEntryModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getPaymentRecords(
      ownerId: widget.ownerId,
      isAdmin: widget.isAdminView,
    );
  }

  Future<void> _reload() async {
    setState(() {
      _future = _service.getPaymentRecords(
        ownerId: widget.ownerId,
        isAdmin: widget.isAdminView,
      );
    });
    await _future;
  }

  Future<void> _requestPayment(WorkEntryModel entry) async {
    final ok = await _service.confirmPaymentByEmployee(entry.id);
    if (!mounted) {
      return;
    }
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Сначала дождитесь подтверждения записи администратором',
          ),
        ),
      );
    }
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Оплаты')),
      body: AppGradientBackground(
        child: FutureBuilder<List<WorkEntryModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data ?? [];
            if (data.isEmpty) {
              return Center(
                child: Text(
                  widget.isAdminView
                      ? 'Нет записей, ожидающих подтверждения сотрудником'
                      : 'Нет записей для подтверждения оплаты',
                ),
              );
            }

            final total = data.fold<double>(
              0,
              (sum, item) => sum + item.salary,
            );
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  HeaderCard(
                    title: widget.isAdminView
                        ? 'Запросов на оплату: ${data.length}'
                        : 'Мои заявки: ${data.length}',
                    subtitle:
                        'Сумма: ${NumberFormat('#,##0.##', 'ru').format(total)} ₽',
                    icon: widget.isAdminView
                        ? Icons.assignment_turned_in_outlined
                        : Icons.account_balance_wallet_outlined,
                  ),
                  const SizedBox(height: 12),
                  ...data.map(_paymentCard),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _paymentCard(WorkEntryModel entry) {
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
                  statusLabel(entry.status),
                  style: TextStyle(
                    color: statusColor(entry.status),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
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
            const SizedBox(height: 8),
            Text(
              '${NumberFormat('#,##0.##', 'ru').format(entry.salary)} ₽',
              style: const TextStyle(
                color: Color(0xFF9BE7FF),
                fontWeight: FontWeight.w700,
              ),
            ),
            if (entry.adminComment.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Комментарий администратора: ${entry.adminComment}',
                style: const TextStyle(color: Color(0xFFFFA8A8), fontSize: 12),
              ),
            ],
            if (widget.isAdminView)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Ожидает подтверждения оплаты сотрудником',
                  style: TextStyle(
                    color: statusColor(entry.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  onPressed: entry.status != 'Подтверждено админом'
                      ? null
                      : () => _requestPayment(entry),
                  child: Text(
                    entry.status != 'Подтверждено админом'
                        ? 'Ожидает проверки'
                        : 'Подтвердить оплату',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
