class FileUploadResponse {
  final FileDetail detail;
  final FileMeta meta;

  FileUploadResponse({required this.detail, required this.meta});

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      detail: FileDetail.fromJson(json['detail']),
      meta: FileMeta.fromJson(json['meta']),
    );
  }
}

class FileDetail {
  final String id;
  final String filename;
  final String filePath;
  final String folderId;
  final String uploadedById;
  final DateTime uploadedAt;
  final String fileType;
  final int fileSize;
  final String? fileUrl;

  FileDetail({
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

  factory FileDetail.fromJson(Map<String, dynamic> json) {
    return FileDetail(
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

class FileMeta {
  final String message;
  final int code;
  final String fileName;
  final int fileSize;

  FileMeta({
    required this.message,
    required this.code,
    required this.fileName,
    required this.fileSize,
  });

  factory FileMeta.fromJson(Map<String, dynamic> json) {
    return FileMeta(
      message: json['message'],
      code: json['code'],
      fileName: json['file_name'],
      fileSize: json['file_size'],
    );
  }
}
