import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../models/work_entry_model.dart';
import 'work_entries_store.dart';

class YandexTableService {
  final WorkEntriesStore _store = WorkEntriesStore.instance;
  static const String _googleSheetsEndpoint = String.fromEnvironment(
    'SHIFTFLOW_SHEETS_URL',
  );
  static const Duration _timeout = Duration(seconds: 8);

  bool get _hasRemoteEndpoint => _googleSheetsEndpoint.trim().isNotEmpty;

  Uri get _endpoint => Uri.parse(_googleSheetsEndpoint);

  Future<void> init() => _store.init();

  Future<void> createRecord(WorkEntryModel data) async {
    await _store.init();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await _store.add(data);
  }

  Future<void> approveRecordByAdmin(String id) async {
    await _store.init();
    final record = _store.getById(id);
    if (record == null) {
      return;
    }
    await _store.updateRecord(
      id,
      status: 'Подтверждено админом',
      adminComment: '',
    );
  }

  Future<bool> confirmPaymentByEmployee(String id) async {
    await _store.init();
    final record = _store.getById(id);
    if (record == null) {
      return false;
    }

    if (record.status != 'Подтверждено админом') {
      return false;
    }

    await _sendConfirmedToCloud(record.copyWith(status: 'Оплата подтверждена'));
    await _store.deleteById(id);
    return true;
  }

  Future<void> resubmitCorrectedRecord(WorkEntryModel updatedRecord) async {
    await _store.init();
    final record = updatedRecord.copyWith(
      status: 'Исправлено',
      adminComment: '',
    );
    await _store.replaceRecord(record);
  }

  Future<void> rejectPayment({
    required String id,
    required String adminComment,
  }) async {
    await _store.init();
    await _store.updateRecord(
      id,
      status: 'Не подтверждено',
      adminComment: adminComment.trim(),
    );
  }

  Future<void> approvePayment(String id) async {
    await approveRecordByAdmin(id);
  }

  Future<List<WorkEntryModel>> getRecords({
    String? ownerId,
    bool isAdmin = false,
  }) async {
    await _store.init();
    await Future<void>.delayed(const Duration(milliseconds: 70));
    return _store.getAll(ownerId: ownerId, isAdmin: isAdmin);
  }

  Future<List<WorkEntryModel>> getHistoryRecords({
    String? ownerId,
    bool isAdmin = false,
  }) async {
    final records = await getRecords(ownerId: ownerId, isAdmin: isAdmin);
    if (isAdmin) {
      return records;
    }
    return records
        .where((entry) => entry.status != 'Оплата подтверждена')
        .toList(growable: false);
  }

  Future<List<WorkEntryModel>> getPaymentRecords({
    String? ownerId,
    bool isAdmin = false,
  }) async {
    final records = await getRecords(ownerId: ownerId, isAdmin: isAdmin);
    if (isAdmin) {
      return records
          .where((entry) => entry.status == 'Подтверждено админом')
          .toList(growable: false);
    }
    return records
        .where((entry) => entry.status == 'Подтверждено админом')
        .toList(growable: false);
  }

  Future<List<WorkEntryModel>> getDeleteScreenRecords({
    String? ownerId,
    bool isAdmin = false,
  }) async {
    final records = await getRecords(ownerId: ownerId, isAdmin: isAdmin);
    return records
        .where((entry) => entry.status == 'Оплата подтверждена')
        .toList(growable: false);
  }

  Future<void> deleteRecord(String id) async {
    await _store.init();
    await Future<void>.delayed(const Duration(milliseconds: 70));
    await _store.deleteById(id);
  }

  Future<void> _sendConfirmedToCloud(WorkEntryModel record) async {
    if (!_hasRemoteEndpoint) {
      return;
    }
    try {
      final response = await http
          .post(
            _endpoint,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'action': 'create', 'record': record.toJson()}),
          )
          .timeout(_timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('Cloud save failed: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Cloud save exception: $error');
    }
  }
}
