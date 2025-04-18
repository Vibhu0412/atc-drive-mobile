class FolderCreationResponse {
  final Detail detail;
  final Meta meta;

  FolderCreationResponse({required this.detail, required this.meta});

  factory FolderCreationResponse.fromJson(Map<String, dynamic> json) {
    return FolderCreationResponse(
      detail: Detail.fromJson(json['detail']),
      meta: Meta.fromJson(json['meta']),
    );
  }
}

class Detail {
  final String id;
  final String name;
  final String? parentFolderId;
  final String ownerId;
  final DateTime createdAt;
  final List<dynamic> files;
  final List<dynamic> subfolders;
  final List<dynamic> children;

  Detail({
    required this.id,
    required this.name,
    this.parentFolderId,
    required this.ownerId,
    required this.createdAt,
    required this.files,
    required this.subfolders,
    required this.children,
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      id: json['id'],
      name: json['name'],
      parentFolderId: json['parent_folder_id'],
      ownerId: json['owner_id'],
      createdAt: DateTime.parse(json['created_at']),
      files: json['files'],
      subfolders: json['subfolders'],
      children: json['children'],
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
