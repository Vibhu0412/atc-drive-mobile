import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:atc_drive/app/model/file_upload_model.dart';
import 'package:atc_drive/app/model/folder_creation_model.dart';
import 'package:atc_drive/app/model/get_all_files_model.dart';
import 'package:atc_drive/app/model/get_all_user_model.dart';
import 'package:atc_drive/app/model/home_folder_model.dart';
import 'package:atc_drive/app/routes/app_routes.dart';
import 'package:atc_drive/app/services/network_service.dart';
import 'package:atc_drive/app/services/notification_service.dart';
import 'package:atc_drive/app/services/storage_service.dart';
import 'package:atc_drive/app/utils/app_utils.dart';
import 'package:atc_drive/app/utils/snackbar/app_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class HomeController extends GetxController {
  final NetworkService _networkService = Get.find();

  final String rootId = 'root';

  final RxBool isLoading = false.obs;
  RxBool isUserFetchFailed = false.obs;
  RxBool isFilesFetchFailed = false.obs;
  RxBool isFabExpanded = false.obs;
  RxBool isSelectionMode = false.obs;

  final RxList<Folder> folders = <Folder>[].obs;
  final RxList<Folder> currentPath = <Folder>[].obs;

  List<User> users = <User>[];
  RxList<String> selectedFileIds = <String>[].obs;

  // Get current folder ID
  String get currentFolderId => currentPath.last.id;

  // Get current folder contents
  RxList<Folder> get currentFolderChildren {
    if (currentPath.isEmpty) {
      return <Folder>[].obs;
    }
    return currentPath.last.children;
  }

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    getFiles();
  }

  void toggleFab() {
    isFabExpanded.value = !isFabExpanded.value;
  }

  Future<void> getFiles() async {
    isLoading.value = true;
    isFilesFetchFailed.value = false;
    try {
      GetAllFiles? filesData = await _networkService.fetchFiles();
      if (filesData != null) {
        folders.clear();

        // Create root folder
        final rootFolder = Folder(
          id: rootId,
          name: 'My Drive',
          createdAt: DateTime.now(),
        );

        // Process API response using the new model structure
        _processApiResponse(
            filesData.detail.folders, filesData.detail.files, rootFolder);

        folders.add(rootFolder);
        currentPath.clear();
        currentPath.add(rootFolder);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch files: $e");
      isFilesFetchFailed.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void _processApiResponse(
      List<ApiFolder> apiFolders, List<ApiFile> apiFiles, Folder parentFolder) {
    // Process folders
    for (var apiFolder in apiFolders) {
      final files = apiFolder.files
          .map((f) => FileItem(
                id: f.id,
                name: f.filename,
                uploadedAt: f.uploadedAt,
                filePath: f.filePath,
                folderId: f.folderId,
                uploadedById: f.uploadedById,
                fileType: f.fileType,
                fileSize: f.fileSize,
                fileUrl: f.fileUrl,
              ))
          .toList()
          .obs;

      final folder = Folder(
        id: apiFolder.id,
        name: apiFolder.name,
        parentId: apiFolder.parentFolderId,
        createdAt: apiFolder.createdAt,
        files: files,
      );

      // Recursively process subfolders and children
      _processApiResponse(apiFolder.subfolders, [], folder);
      _processApiResponse(apiFolder.children, [], folder);

      parentFolder.children.add(folder);
    }

    // Process root-level files
    for (var apiFile in apiFiles) {
      parentFolder.files.add(FileItem(
        id: apiFile.id,
        name: apiFile.filename,
        uploadedAt: apiFile.uploadedAt,
        filePath: apiFile.filePath,
        folderId: apiFile.folderId,
        uploadedById: apiFile.uploadedById,
        fileType: apiFile.fileType,
        fileSize: apiFile.fileSize,
        fileUrl: apiFile.fileUrl,
      ));
    }
  }

  Future<void> createFolder(String name, {String? parentId}) async {
    try {
      final folderParentId = (parentId == rootId) ? null : parentId;

      final response = await _networkService.createFolder(
        'folder/folders',
        body: {
          "name": name,
          "parent_folder_id": folderParentId,
        },
      );

      final folderResponse = FolderCreationResponse.fromJson(response);

      final newFolder = Folder(
        id: folderResponse.detail.id,
        name: folderResponse.detail.name,
        parentId: folderResponse.detail.parentFolderId,
        createdAt: folderResponse.detail.createdAt,
      );
      log("Folder created: ${folderResponse.detail.id}");
      if (folderParentId == null) {
        final rootFolder = folders.firstWhere((folder) => folder.id == rootId);
        rootFolder.children.add(newFolder);
      } else {
        final parent = _findFolder(folderParentId);
        parent?.children.add(newFolder);
      }

      refresh();
      update();
      // Get.snackbar("Success", "Folder created successfully");
    } catch (e) {
      log("Failed to create folder: $e");
      Get.snackbar("Error", "Failed to create folder: $e");
    }
  }

  // Navigate into folder
  void navigateToFolder(String folderId) {
    final folder = _findFolder(folderId);
    if (folder != null) {
      currentPath.add(folder);
      update();
    }
  }

  // Navigate back
  void navigateBack() {
    if (currentPath.length > 1) {
      currentPath.removeLast();
      update();
    }
  }

  // Helper function to find folder
  Folder? _findFolder(String folderId) {
    Folder? foundFolder;

    void search(List<Folder> folders) {
      for (final folder in folders) {
        if (folder.id == folderId) {
          foundFolder = folder;
          return;
        }
        if (folder.children.isNotEmpty) {
          search(folder.children);
        }
      }
    }

    search(folders);
    return foundFolder;
  }

  // Delete folder
  void deleteFolder(String folderId) {
    final folder = _findFolder(folderId);
    if (folder != null) {
      // Remove from parent's children
      final parent = _findFolder(folder.parentId ?? rootId);
      parent?.children.removeWhere((f) => f.id == folderId);

      // Remove from main list
      folders.removeWhere((f) => f.id == folderId);
      update();
    }
  }

  Future<void> uploadFiles(String? folderId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) return;

      for (var file in result.files) {
        if (file.size > 500 * 1024 * 1024) {
          Get.snackbar("Error", "${file.name} exceeds 500 MB limit.");
          continue;
        }

        final fileItem = FileItem(
          id: UniqueKey().toString(),
          name: file.name,
          filePath: file.path!,
          folderId: folderId ?? "",
          uploadedAt: DateTime.now(),
          uploadedById: "user_id",
          fileType: file.extension ?? "unknown",
          fileSize: file.size,
          fileUrl: "",
          uploadProgress: 0.0,
        );

        final folder = _findFolder(folderId ?? "");
        folder?.files.add(fileItem);

        _uploadFileWithProgress(fileItem, folderId);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick files: $e");
    }
  }

  Future<void> _uploadFileWithProgress(
      FileItem fileItem, String? folderId) async {
    try {
      await _attemptFileUpload(fileItem, folderId);
    } catch (e) {
      if (e is http.ClientException || e.toString().contains("401")) {
        log("Unauthorized! Trying to refresh token...");

        bool refreshed = await _networkService.refreshToken();
        if (refreshed) {
          await _attemptFileUpload(fileItem, folderId);
        } else {
          Get.snackbar("Session Expired", "Please log in again.");
        }
      } else {
        log("Upload error: $e");
        fileItem.uploadFailed.value = true;
        Get.snackbar("Error", "Failed to upload file: $e");
        fileItem.uploadProgress.value = -1.0;
      }
    }
  }

  Future<void> _attemptFileUpload(FileItem fileItem, String? folderId) async {
    final file = File(fileItem.filePath ?? "");
    final fileStream = file.openRead();
    final totalBytes = file.lengthSync();
    int uploadedBytes = 0;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://93.127.137.160/v1/folder/file/upload'),
    );

    request.headers['Authorization'] =
        'Bearer ${StorageService.getAccessToken()}';

    final fileStreamWithProgress = fileStream.transform(
      StreamTransformer<List<int>, List<int>>.fromHandlers(
        handleData: (chunk, sink) {
          uploadedBytes += chunk.length;
          fileItem.uploadProgress.value = uploadedBytes / totalBytes;
          sink.add(chunk);
        },
      ),
    );

    final multipartFile = http.MultipartFile(
      'file',
      fileStreamWithProgress,
      totalBytes,
      filename: fileItem.name.value,
    );

    request.files.add(multipartFile);

    if (folderId != null && folderId != rootId) {
      request.fields['folder_id'] = folderId;
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      log("UPLOAD FILE RESPONSE: $responseData");

      final fileResponse =
          FileUploadResponse.fromJson(json.decode(responseData));

      fileItem.id = fileResponse.detail.id;
      fileItem.fileUrl = fileResponse.detail.fileUrl;
      fileItem.uploadProgress.value = 1.0;
    } else {
      throw Exception(
          "Failed to upload file, status code: ${response.statusCode}");
    }
  }

  Future<void> fetchUsers() async {
    try {
      isUserFetchFailed.value = false;
      users = await _networkService.getAllUsers();
    } catch (e) {
      isUserFetchFailed.value = true;
      log('Error fetching users: $e');
    }
  }

  Future<void> shareFile({
    required String itemId,
    required String itemType,
    required List<String> sharedWithUserEmails,
    required List<String> actions,
  }) async {
    try {
      await _networkService.shareItem(
        itemId: itemId,
        itemType: itemType,
        sharedWithUserEmails: sharedWithUserEmails,
        actions: actions,
      );
      Get.snackbar("Success", "File shared successfully");
    } catch (e) {
      log('Error sharing file: $e');
    }
  }

  void removeFailedFile(FileItem file) {
    final folder = _findFolder(file.folderId ?? "");
    folder?.files.removeWhere((f) => f.id == file.id);
  }

  Future<void> logout() async {
    try {
      StorageService.clearAll();

      Get.offAllNamed(
        AppRoutes.login,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to logout: $e");
    }
  }

  Future<void> getFileUrlAndShare(String fileId) async {
    try {
      var dio = Dio();

      var response = await dio.get(
        'http://93.127.137.160/v1/folder/files/$fileId/download',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer ${StorageService.getAccessToken()}',
          },
          responseType: ResponseType.json,
        ),
      );

      if (response.statusCode == 200) {
        String? fileUrl = response.data['detail']['file_url'];
        if (fileUrl != null) {
          Share.share(
            "Download this file: $fileUrl",
          );
        } else {
          Get.snackbar("Error", "Failed to get file URL");
        }
      } else {
        Get.snackbar(
            "Error", "Failed to fetch file URL: ${response.statusCode}");
      }
    } catch (e) {
      log("Error fetching file URL: $e");
      Get.snackbar("Error", "Failed to fetch file URL: $e");
    }
  }

  Future<String?> shortenUrl(String longUrl) async {
    try {
      var response =
          await Dio().get('https://tinyurl.com/api-create.php?url=$longUrl');
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      log("URL Shortening Error: $e");
    }
    return null;
  }

  Future<void> downloadFile(String fileId, String fileName) async {
    try {
      if (await AppUtils.requestStoragePermission()) {
        Directory? downloadsDirectory;

        if (Platform.isAndroid) {
          downloadsDirectory = Directory('/storage/emulated/0/Download');
        } else if (Platform.isIOS) {
          downloadsDirectory = await getApplicationDocumentsDirectory();
        }

        if (downloadsDirectory == null) {
          Get.snackbar("Error", "Failed to access download directory");
          return;
        }

        final savePath = '${downloadsDirectory.path}/$fileName';

        AppSnackBar.showDownloadSnackbar(fileName);

        var dio = Dio();

        var response = await dio.get(
          'http://93.127.137.160/v1/folder/files/$fileId/download',
          options: Options(
            method: 'GET',
            headers: {
              'Authorization': 'Bearer ${StorageService.getAccessToken()}',
            },
            responseType: ResponseType.json,
          ),
        );

        if (response.statusCode == 200) {
          String? fileUrl = response.data['detail']['file_url'];

          if (fileUrl != null) {
            var fileResponse = await dio.download(
              fileUrl,
              savePath,
              options: Options(
                responseType: ResponseType.bytes,
              ),
              onReceiveProgress: (count, total) {
                // double progress = (count / total) * 100;
                // log("Downloading: ${progress.toStringAsFixed(2)}%");
              },
            );

            if (fileResponse.statusCode == 200) {
              NotificationService.showDownloadNotification(fileName, savePath);
            } else {
              log("File Download Error: ${fileResponse.statusCode}");
              Get.snackbar("Error", "Failed to download file from S3");
            }
          } else {
            log("API Error: No file URL found in response");
            Get.snackbar("Error", "Failed to get file URL");
          }
        } else {
          log("API Error: ${response.statusCode} - ${response.data}");
          Get.snackbar(
              "Error", "Failed to download file: ${response.statusCode}");
        }
      } else {
        Get.snackbar("Permission Denied",
            "Storage permission is required to download files");
      }
    } catch (e) {
      log("Download error: $e");
      Get.snackbar("Error", "Failed to download file: $e");
    }
  }

  Future<void> downloadMultipleFiles(List<String> fileIds) async {
    try {
      if (fileIds.isEmpty) return;

      if (await AppUtils.requestStoragePermission()) {
        Directory? downloadsDirectory = Platform.isAndroid
            ? Directory('/storage/emulated/0/Download')
            : await getApplicationDocumentsDirectory();

        var dio = Dio();
        var response = await dio.post(
          'http://93.127.137.160/v1/folder/files/download',
          options: Options(
            headers: {
              'Authorization': 'Bearer ${StorageService.getAccessToken()}',
              'Content-Type': 'application/json',
            },
          ),
          data: {'file_ids': fileIds},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> fileUrls =
              response.data['detail']['file_urls'];

          final totalFiles = fileUrls.length;
          Get.showSnackbar(
            GetSnackBar(
              message:
                  "$totalFiles ${totalFiles == 1 ? 'item will be downloaded' : 'items will be downloaded'}. See notification for details.",
              duration: const Duration(seconds: 3),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.black87,
              margin: const EdgeInsets.all(10),
              borderRadius: 8,
              isDismissible: true,
            ),
          );

          for (var entry in fileUrls.entries) {
            final fileData = entry.value;
            final fileUrl = fileData['file_url'];
            final fileName = fileData['file_name'];

            final savePath = '${downloadsDirectory.path}/$fileName';

            try {
              await dio.download(
                fileUrl,
                savePath,
                onReceiveProgress: (count, total) {},
              );

              NotificationService.showDownloadNotification(fileName, savePath);
            } catch (e) {
              log("Error downloading $fileName: $e");
              Get.snackbar("Error", "Failed to download $fileName");
            }
          }
        } else {
          Get.snackbar(
              "Error", "Failed to get download URLs: ${response.statusCode}");
        }
      } else {
        Get.snackbar("Permission Denied", "Storage permission required");
      }
    } catch (e) {
      log("Download error: $e");
      Get.snackbar("Error", "Download failed: $e");
    } finally {
      isSelectionMode.value = false;
      selectedFileIds.clear();
    }
  }

  Future<void> checkAndOpenFile(FileItem file) async {
    Directory? dir = Platform.isAndroid
        ? Directory('/storage/emulated/0/Download')
        : await getApplicationDocumentsDirectory();

    String path = '${dir.path}/${file.name.value}';
    if (await File(path).exists()) {
      OpenFilex.open(path);
    } else {
      downloadFile(file.id ?? "", file.name.value);
    }
  }

  void toggleFileSelection(String fileId) {
    if (selectedFileIds.contains(fileId)) {
      selectedFileIds.remove(fileId);
    } else {
      selectedFileIds.add(fileId);
    }

    if (selectedFileIds.isEmpty) isSelectionMode.value = false;
  }

  void enterSelectionMode() {
    isSelectionMode.value = true;
  }
}
