class User {
  final String id;
  final String username;
  final String email;
  final Role role;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.createdAt,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: Role.fromJson(json['role']),
      createdAt: DateTime.parse(json['created_at']),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
    );
  }
}

class Role {
  final String id;
  final String name;
  final bool canView;
  final bool canEdit;
  final bool canDelete;
  final bool canCreate;
  final bool canShare;

  Role({
    required this.id,
    required this.name,
    required this.canView,
    required this.canEdit,
    required this.canDelete,
    required this.canCreate,
    required this.canShare,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      canView: json['can_view'],
      canEdit: json['can_edit'],
      canDelete: json['can_delete'],
      canCreate: json['can_create'],
      canShare: json['can_share'],
    );
  }
}
