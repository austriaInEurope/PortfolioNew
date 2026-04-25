import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../../models/work_entry_model.dart';

class WorkEntriesStore {
  WorkEntriesStore._();

  static final WorkEntriesStore instance = WorkEntriesStore._();
  static const String _entriesKey = 'shiftflow_entries_v1';

  SharedPreferences? _prefs;
  final List<WorkEntryModel> _entries = [];
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) {
      return;
    }
    _prefs ??= await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_entriesKey);
    try {
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final loaded = <WorkEntryModel>[];
          for (final item in decoded) {
            if (item is! Map) {
              continue;
            }
            try {
              loaded.add(
                WorkEntryModel.fromJson(Map<String, dynamic>.from(item)),
              );
            } catch (error) {
              debugPrint('Skip broken entry: $error');
            }
          }
          _entries
            ..clear()
            ..addAll(loaded);
        }
      }
    } catch (error) {
      debugPrint('Entries storage reset due to parse error: $error');
      _entries.clear();
      await _prefs!.remove(_entriesKey);
    }
    _initialized = true;
  }

  List<WorkEntryModel> getAll({String? ownerId, bool isAdmin = false}) {
    final records = isAdmin || ownerId == null || ownerId.isEmpty
        ? _entries
        : _entries.where((entry) => entry.ownerId == ownerId);
    return List.unmodifiable(records.toList(growable: false).reversed);
  }

  List<WorkEntryModel> getByStatus(
    String status, {
    String? ownerId,
    bool isAdmin = false,
  }) {
    final records = getAll(ownerId: ownerId, isAdmin: isAdmin);
    return records
        .where((entry) => entry.status == status)
        .toList(growable: false);
  }

  Future<void> add(WorkEntryModel entry) async {
    _entries.add(entry);
    await _save();
  }

  Future<void> updateStatus(String id, String status) async {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index == -1) {
      return;
    }
    _entries[index] = _entries[index].copyWith(status: status);
    await _save();
  }

  WorkEntryModel? getById(String id) {
    for (final entry in _entries) {
      if (entry.id == id) {
        return entry;
      }
    }
    return null;
  }

  Future<void> updateRecord(
    String id, {
    String? status,
    String? adminComment,
  }) async {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index == -1) {
      return;
    }
    _entries[index] = _entries[index].copyWith(
      status: status,
      adminComment: adminComment,
    );
    await _save();
  }

  Future<void> replaceRecord(WorkEntryModel updated) async {
    final index = _entries.indexWhere((entry) => entry.id == updated.id);
    if (index == -1) {
      _entries.add(updated);
    } else {
      _entries[index] = updated;
    }
    await _save();
  }

  Future<void> deleteById(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    await _save();
  }

  Future<void> _save() async {
    final encoded = jsonEncode(
      _entries.map((entry) => entry.toJson()).toList(),
    );
    await _prefs?.setString(_entriesKey, encoded);
  }
}
