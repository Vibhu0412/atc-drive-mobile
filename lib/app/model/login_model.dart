class LoginResponse {
  final Detail detail;
  final Meta meta;

  LoginResponse({required this.detail, required this.meta});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      detail: Detail.fromJson(json['detail']),
      meta: Meta.fromJson(json['meta']),
    );
  }
}

class Detail {
  final User user;
  final Role role;
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  Detail({
    required this.user,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      user: User.fromJson(json['user']),
      role: Role.fromJson(json['role']),
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'],
    );
  }
}

class User {
  final String id;
  final String username;
  final String email;
  final String roleId;
  final DateTime createdAt;
  final DateTime lastLogin;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.roleId,
    required this.createdAt,
    required this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      roleId: json['role_id'],
      createdAt: DateTime.parse(json['created_at']),
      lastLogin: DateTime.parse(json['last_login']),
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

class Meta {
  final String message;
  final int code;

  Meta({required this.message, required this.code});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      message: json['message'],
      code: json['code'],
    );
  }
}
