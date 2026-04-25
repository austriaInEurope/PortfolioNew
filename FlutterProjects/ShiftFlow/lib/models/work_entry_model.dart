class WorkEntryModel {
  final String id;
  final String ownerId;
  final String date;
  final String fio;
  final String description;
  final double rate;
  final String start;
  final String end;
  final double dayHours;
  final double nightHours;
  final double salary;
  final String status;
  final String project;
  final String comment;
  final String adminComment;

  WorkEntryModel({
    required this.id,
    required this.ownerId,
    required this.date,
    required this.fio,
    required this.description,
    required this.rate,
    required this.start,
    required this.end,
    required this.dayHours,
    required this.nightHours,
    required this.salary,
    required this.status,
    required this.project,
    required this.comment,
    required this.adminComment,
  });

  WorkEntryModel copyWith({
    String? id,
    String? ownerId,
    String? date,
    String? fio,
    String? description,
    double? rate,
    String? start,
    String? end,
    double? dayHours,
    double? nightHours,
    double? salary,
    String? status,
    String? project,
    String? comment,
    String? adminComment,
  }) {
    return WorkEntryModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      date: date ?? this.date,
      fio: fio ?? this.fio,
      description: description ?? this.description,
      rate: rate ?? this.rate,
      start: start ?? this.start,
      end: end ?? this.end,
      dayHours: dayHours ?? this.dayHours,
      nightHours: nightHours ?? this.nightHours,
      salary: salary ?? this.salary,
      status: status ?? this.status,
      project: project ?? this.project,
      comment: comment ?? this.comment,
      adminComment: adminComment ?? this.adminComment,
    );
  }

  factory WorkEntryModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        return double.tryParse(value.replaceAll(',', '.')) ?? 0;
      }
      return 0;
    }

    return WorkEntryModel(
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      fio: (json['fio'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      rate: parseDouble(json['rate']),
      start: (json['start'] ?? '').toString(),
      end: (json['end'] ?? '').toString(),
      dayHours: parseDouble(json['dayHours']),
      nightHours: parseDouble(json['nightHours']),
      salary: parseDouble(json['salary']),
      status: (json['status'] ?? 'На проверке').toString(),
      project: (json['project'] ?? '').toString(),
      comment: (json['comment'] ?? '').toString(),
      adminComment: (json['adminComment'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'date': date,
      'fio': fio,
      'description': description,
      'rate': rate,
      'start': start,
      'end': end,
      'dayHours': dayHours,
      'nightHours': nightHours,
      'salary': salary,
      'status': status,
      'project': project,
      'comment': comment,
      'adminComment': adminComment,
    };
  }
}
