import 'package:get/get.dart';

class FileItem {
  String? id;
  final RxString name;
  final String? filePath;
  final String? folderId;
  final String? uploadedById;
  final DateTime? uploadedAt;
  final String? fileType;
  final int? fileSize;
  String? fileUrl;
  final RxDouble uploadProgress;
  RxBool uploadFailed;

  FileItem({
    this.id,
    required String name,
    this.filePath,
    this.folderId,
    this.uploadedById,
    this.uploadedAt,
    this.fileType,
    this.fileSize,
    this.fileUrl,
    double uploadProgress = 1.0,
    bool uploadFailed = false,
  })  : name = RxString(name),
        uploadProgress = RxDouble(uploadProgress),
        uploadFailed = uploadFailed.obs;
}

class Folder {
  String id;
  String name;
  String? parentId;
  RxList<Folder> children = <Folder>[].obs;
  RxList<FileItem> files = <FileItem>[].obs;
  DateTime createdAt;

  Folder({
    required this.id,
    required this.name,
    this.parentId,
    RxList<Folder>? children,
    RxList<FileItem>? files,
    required this.createdAt,
  })  : children = children ?? <Folder>[].obs,
        files = files ?? <FileItem>[].obs;
}
