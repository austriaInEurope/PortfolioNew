class UserAccountModel {
  final String id;
  final String username;
  final String password;
  final String displayName;
  final bool isAdmin;
  final double defaultRate;
  final String defaultProject;

  const UserAccountModel({
    required this.id,
    required this.username,
    required this.password,
    required this.displayName,
    required this.isAdmin,
    this.defaultRate = 850,
    this.defaultProject = '',
  });

  factory UserAccountModel.fromJson(Map<String, dynamic> json) {
    return UserAccountModel(
      id: (json['id'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      password: (json['password'] ?? '').toString(),
      displayName: (json['displayName'] ?? '').toString(),
      isAdmin: json['isAdmin'] == true,
      defaultRate: (json['defaultRate'] is num)
          ? (json['defaultRate'] as num).toDouble()
          : 850,
      defaultProject: (json['defaultProject'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'displayName': displayName,
      'isAdmin': isAdmin,
      'defaultRate': defaultRate,
      'defaultProject': defaultProject,
    };
  }

  UserAccountModel copyWith({
    String? id,
    String? username,
    String? password,
    String? displayName,
    bool? isAdmin,
    double? defaultRate,
    String? defaultProject,
  }) {
    return UserAccountModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      isAdmin: isAdmin ?? this.isAdmin,
      defaultRate: defaultRate ?? this.defaultRate,
      defaultProject: defaultProject ?? this.defaultProject,
    );
  }
}
