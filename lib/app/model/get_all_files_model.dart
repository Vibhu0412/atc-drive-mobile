class GetAllFiles {
  final Detail detail;
  final Meta meta;

  GetAllFiles({required this.detail, required this.meta});

  factory GetAllFiles.fromJson(Map<String, dynamic> json) {
    return GetAllFiles(
      detail: Detail.fromJson(json['detail']),
      meta: Meta.fromJson(json['meta']),
    );
  }
}

class Detail {
  final List<ApiFolder> folders;
  final List<ApiFile> files;

  Detail({required this.folders, required this.files});

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      folders:
          (json['folders'] as List).map((e) => ApiFolder.fromJson(e)).toList(),
      files: (json['files'] as List).map((e) => ApiFile.fromJson(e)).toList(),
    );
  }
}

class ApiFolder {
  final String id;
  final String name;
  final String? parentFolderId;
  final String ownerId;
  final DateTime createdAt;
  final List<ApiFile> files;
  final List<ApiFolder> subfolders;
  final List<ApiFolder> children;

  ApiFolder({
    required this.id,
    required this.name,
    this.parentFolderId,
    required this.ownerId,
    required this.createdAt,
    required this.files,
    required this.subfolders,
    required this.children,
  });

  factory ApiFolder.fromJson(Map<String, dynamic> json) {
    return ApiFolder(
      id: json['id'],
      name: json['name'],
      parentFolderId: json['parent_folder_id'],
      ownerId: json['owner_id'],
      createdAt: DateTime.parse(json['created_at']),
      files: (json['files'] as List).map((e) => ApiFile.fromJson(e)).toList(),
      subfolders: (json['subfolders'] as List)
          .map((e) => ApiFolder.fromJson(e))
          .toList(),
      children:
          (json['children'] as List).map((e) => ApiFolder.fromJson(e)).toList(),
    );
  }
}

class ApiFile {
  final String id;
  final String filename;
  final String filePath;
  final String folderId;
  final String uploadedById;
  final DateTime uploadedAt;
  final String fileType;
  final int fileSize;
  final String? fileUrl;

  ApiFile({
    required this.id,
    required this.filename,
    required this.filePath,
    required this.folderId,
    required this.uploadedById,
    required this.uploadedAt,
    required this.fileType,
    required this.fileSize,
    this.fileUrl,
  });

  factory ApiFile.fromJson(Map<String, dynamic> json) {
    return ApiFile(
      id: json['id'],
      filename: json['filename'],
      filePath: json['file_path'],
      folderId: json['folder_id'],
      uploadedById: json['uploaded_by_id'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
      fileType: json['file_type'],
      fileSize: json['file_size'],
      fileUrl: json['file_url'],
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
