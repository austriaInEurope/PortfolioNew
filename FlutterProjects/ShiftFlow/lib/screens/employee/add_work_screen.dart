import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/services/auth_session_service.dart';
import '../../core/services/yandex_table_service.dart';
import '../../core/utils/salary_calculator.dart';
import '../../core/widgets/ui_kit.dart';
import '../../models/work_entry_model.dart';

class AddWorkScreen extends StatefulWidget {
  final String ownerId;
  final String ownerName;
  final WorkEntryModel? existingEntry;

  const AddWorkScreen({
    super.key,
    required this.ownerId,
    required this.ownerName,
    this.existingEntry,
  });

  @override
  State<AddWorkScreen> createState() => _AddWorkScreenState();
}

class _AddWorkScreenState extends State<AddWorkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = YandexTableService();
  final _auth = AuthSessionService.instance;

  late final TextEditingController _fioController;
  final TextEditingController _dateController = TextEditingController(
    text: DateFormat('dd.MM.yyyy').format(DateTime.now()),
  );
  final TextEditingController _workController = TextEditingController();
  final TextEditingController _rateController = TextEditingController(
    text: '850',
  );
  final TextEditingController _startController = TextEditingController(
    text: '09:00',
  );
  final TextEditingController _endController = TextEditingController(
    text: '18:00',
  );
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _projectController = TextEditingController();

  bool _isSaving = false;
  DateTime? _pickedDate;
  bool _rememberProject = true;

  bool get _isEditMode => widget.existingEntry != null;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    _fioController = TextEditingController(
      text: user?.displayName ?? widget.ownerName,
    );
    if (user != null) {
      _rateController.text = user.defaultRate.toStringAsFixed(0);
      _projectController.text = user.defaultProject;
    } else {
      _projectController.text = '';
    }
    if (_isEditMode) {
      final entry = widget.existingEntry!;
      _dateController.text = entry.date;
      _workController.text = entry.description;
      _rateController.text = entry.rate.toStringAsFixed(0);
      _startController.text = entry.start;
      _endController.text = entry.end;
      _commentController.text = entry.comment;
      _projectController.text = entry.project;
    }
    _pickedDate = DateFormat('dd.MM.yyyy').tryParseStrict(_dateController.text);
  }

  @override
  void dispose() {
    _fioController.dispose();
    _dateController.dispose();
    _workController.dispose();
    _rateController.dispose();
    _startController.dispose();
    _endController.dispose();
    _commentController.dispose();
    _projectController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _pickedDate = picked;
      _dateController.text = DateFormat('dd.MM.yyyy').format(picked);
    });
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _parseTime(controller.text) ?? TimeOfDay.now(),
    );
    if (selected == null) {
      return;
    }
    controller.text =
        '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
  }

  TimeOfDay? _parseTime(String input) {
    final parts = input.split(':');
    if (parts.length != 2) {
      return null;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  String get _dateChipLabel {
    final date = _pickedDate;
    if (date == null) {
      return 'Выбрать дату';
    }
    return DateFormat('d MMMM yyyy', 'ru').format(date);
  }

  ({double day, double night}) _calculateHours(TimeOfDay start, TimeOfDay end) {
    int toMinutes(TimeOfDay value) => value.hour * 60 + value.minute;
    final startMin = toMinutes(start);
    var endMin = toMinutes(end);
    if (endMin <= startMin) {
      endMin += 24 * 60;
    }

    var day = 0.0;
    var night = 0.0;
    for (var minute = startMin; minute < endMin; minute += 30) {
      final hour = (minute % (24 * 60)) ~/ 60;
      final isNight = hour >= 22 || hour < 6;
      if (isNight) {
        night += 0.5;
      } else {
        day += 0.5;
      }
    }
    return (day: day, night: night);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final rate = double.tryParse(_rateController.text.replaceAll(',', '.'));
    final start = _parseTime(_startController.text);
    final end = _parseTime(_endController.text);
    final projectName = _projectController.text.trim();
    if (rate == null || start == null || end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Проверьте ставку и формат времени')),
      );
      return;
    }
    if (projectName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите название проекта')));
      return;
    }

    final hours = _calculateHours(start, end);
    final salary = SalaryCalculator.calculateSalary(
      rate: rate,
      dayHours: hours.day,
      nightHours: hours.night,
    );

    setState(() => _isSaving = true);
    final newRecord = WorkEntryModel(
      id:
          widget.existingEntry?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      ownerId: widget.ownerId,
      date: _dateController.text,
      fio: _fioController.text.trim(),
      description: _workController.text.trim(),
      rate: rate,
      start: _startController.text,
      end: _endController.text,
      dayHours: hours.day,
      nightHours: hours.night,
      salary: salary,
      status: _isEditMode ? 'Исправлено' : 'На проверке',
      project: projectName,
      comment: _commentController.text.trim(),
      adminComment: '',
    );

    if (_isEditMode) {
      await _service.resubmitCorrectedRecord(newRecord);
    } else {
      await _service.createRecord(newRecord);
    }
    final currentUser = _auth.currentUser;
    await _auth.updateDefaultsForCurrentUser(
      defaultRate: rate,
      defaultProject: _rememberProject
          ? projectName
          : (currentUser?.defaultProject ?? ''),
    );
    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditMode
              ? 'Запись исправлена и переотправлена администратору'
              : 'Запись добавлена и отправлена на проверку',
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF151C2B),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'GO DECOR bot',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
              children: [
                _sectionLabel('ФИО'),
                _themedField(
                  controller: _fioController,
                  hint: 'ФИО',
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Введите ФИО'
                      : null,
                ),
                const SizedBox(height: 16),
                _sectionLabel('СТАВКА'),
                _themedField(
                  controller: _rateController,
                  hint: 'Сумма в час',
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      double.tryParse((value ?? '').replaceAll(',', '.')) ==
                          null
                      ? 'Число'
                      : null,
                ),
                const SizedBox(height: 16),
                _sectionLabel('ДАТА'),
                _themedField(
                  controller: _dateController,
                  hint: 'Дата',
                  keyboardType: TextInputType.datetime,
                  onChanged: (value) {
                    setState(() {
                      _pickedDate = DateFormat(
                        'dd.MM.yyyy',
                      ).tryParseStrict(value);
                    });
                  },
                  suffix: _actionPill(label: _dateChipLabel, onTap: _pickDate),
                  validator: (value) {
                    final raw = (value ?? '').trim();
                    final parsed = DateFormat('dd.MM.yyyy').tryParseStrict(raw);
                    if (parsed == null) {
                      return 'Формат дд.мм.гггг';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _sectionLabel('НАЧАЛО РАБОТЫ'),
                _themedField(
                  controller: _startController,
                  hint: 'Время',
                  keyboardType: TextInputType.datetime,
                  suffix: _actionPill(
                    label: _startController.text,
                    onTap: () => _pickTime(_startController),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                _sectionLabel('ОКОНЧАНИЕ РАБОТЫ'),
                _themedField(
                  controller: _endController,
                  hint: 'Время',
                  keyboardType: TextInputType.datetime,
                  suffix: _actionPill(
                    label: _endController.text,
                    onTap: () => _pickTime(_endController),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                _sectionLabel('ОПИСАНИЕ РАБОТ'),
                _themedField(
                  controller: _workController,
                  hint: 'Напишите что делали',
                  maxLines: 2,
                  validator: (value) => value == null || value.trim().length < 5
                      ? 'Опишите работу подробнее'
                      : null,
                ),
                const SizedBox(height: 16),
                _sectionLabel('ПРОЕКТ'),
                _themedField(
                  controller: _projectController,
                  hint: 'Напишите название проекта',
                  onChanged: (_) => setState(() {}),
                  suffix: _projectController.text.trim().isEmpty
                      ? null
                      : _clearPill(
                          onTap: () {
                            setState(() {
                              _projectController.clear();
                            });
                          },
                        ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Введите проект'
                      : null,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(
                        checkboxTheme: const CheckboxThemeData(
                          side: BorderSide(color: Color(0xFF666B78)),
                        ),
                      ),
                      child: Checkbox(
                        value: _rememberProject,
                        onChanged: (value) =>
                            setState(() => _rememberProject = value ?? false),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'Запомнить проект для автозаполнения',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _sectionLabel('КОММЕНТАРИЙ'),
                _themedField(
                  controller: _commentController,
                  maxLines: 2,
                  hint: 'Комментарий (необязательно)',
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 62,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A84FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _isSaving
                          ? 'Отправка...'
                          : _isEditMode
                          ? 'Исправить и переотправить'
                          : 'Отправить ответ',
                      style: const TextStyle(
                        fontSize: 34 / 2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF8E8F93),
          fontSize: 28 / 2,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF7C7D84), fontSize: 18),
      filled: true,
      fillColor: const Color(0xFF2A2D34),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffix == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
              child: suffix,
            ),
      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
    );
  }

  Widget _themedField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    Widget? suffix,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 34 / 2),
      decoration: _fieldDecoration(hint, suffix: suffix),
    );
  }

  Widget _actionPill({required String label, required VoidCallback onTap}) {
    return Material(
      color: const Color(0xFF3A3E47),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF1D9BF0), fontSize: 15),
          ),
        ),
      ),
    );
  }

  Widget _clearPill({required VoidCallback onTap}) {
    return Material(
      color: const Color(0xFF3A3E47),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Icon(Icons.close_rounded, size: 18, color: Color(0xFFB9BCC5)),
        ),
      ),
    );
  }
}
