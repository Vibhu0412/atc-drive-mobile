import 'package:atc_drive/app/controller/home_controller.dart';
import 'package:atc_drive/app/model/home_folder_model.dart';
import 'package:atc_drive/app/ui/home/share_screen.dart';
import 'package:atc_drive/app/utils/app_string_format.dart';
import 'package:atc_drive/app/utils/app_utils.dart';
import 'package:atc_drive/app/utils/snackbar/app_snackbar.dart';
import 'package:atc_drive/app/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          if (controller.isSelectionMode.value) {
            return Text(
              controller.selectedFileIds.length == 1
                  ? '1 item'
                  : '${controller.selectedFileIds.length} items',
              style: Get.textTheme.bodyLarge,
            );
          }
          return _buildPathNavigation();
        }),
        actions: [
          Obx(() {
            if (controller.isSelectionMode.value) {
              return Row(
                children: [
                  IconButton(
                    color: AppColors.primary,
                    icon: const Icon(Icons.download),
                    onPressed: () => controller.downloadMultipleFiles(
                      controller.selectedFileIds.toList(),
                    ),
                  ),
                  IconButton(
                    color: AppColors.primary,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      controller.isSelectionMode.value = false;
                      controller.selectedFileIds.clear();
                    },
                  ),
                ],
              );
            }
            return IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => AppSnackBar.showLogoutConfirmation(controller),
            );
          }),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.isFilesFetchFailed.value) {
          return _buildErrorScreen("Server is busy. Please try again later.");
        }

        final currentItems = _getSortedCurrentItems();
        return RefreshIndicator(
          onRefresh: () async => await controller.getFiles(),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: currentItems.length,
            itemBuilder: (context, index) {
              final item = currentItems[index];
              return item is Folder
                  ? _buildFolderTile(item)
                  : _buildFileTile(item as FileItem);
            },
          ),
        );
      }),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Obx(
      () => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (controller.isFabExpanded.value) ...[
            FloatingActionButton.small(
              backgroundColor: Colors.orangeAccent,
              onPressed: _showCreateFolderDialog,
              heroTag: 'folder',
              child: const Icon(
                Icons.create_new_folder,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            FloatingActionButton.small(
              backgroundColor: Colors.deepOrangeAccent,
              onPressed: () =>
                  controller.uploadFiles(controller.currentFolderId),
              heroTag: 'upload',
              child: const Icon(
                Icons.upload_file_rounded,
                color: Colors.white,
              ),
            ),
          ],
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: controller.toggleFab,
            heroTag: 'toggle',
            child: AnimatedRotation(
              turns: controller.isFabExpanded.value ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                  controller.isFabExpanded.value ? Icons.close : Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _getSortedCurrentItems() {
    if (controller.currentPath.isEmpty) {
      return [];
    }

    final folders = List<Folder>.from(controller.currentFolderChildren);
    final files = List<FileItem>.from(controller.currentPath.last.files);

    folders
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    files.sort((a, b) =>
        a.name.value.toLowerCase().compareTo(b.name.value.toLowerCase()));

    return [...folders, ...files];
  }

  Widget _buildFolderTile(Folder folder) {
    return ListTile(
      leading: const Icon(Icons.folder),
      title: Text(folder.name, overflow: TextOverflow.ellipsis),
      subtitle: Text(AppStringFormat.formatModifiedDate(
          folder.createdAt.toIso8601String())),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () =>
            _showOptionsBottomSheet(folder.name, isFile: false, folder: folder),
      ),
      onTap: () => controller.isSelectionMode.value
          ? null
          : controller.navigateToFolder(folder.id),
    );
  }

  Widget _buildFileTile(FileItem file) {
    return Obx(() {
      final isUploading =
          file.uploadProgress.value < 1.0 && !file.uploadFailed.value;
      final isFailed = file.uploadFailed.value;
      final isSelected = controller.selectedFileIds.contains(file.id);

      return Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Get.theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.isSelectionMode.value)
                GestureDetector(
                  onTap: () => controller.toggleFileSelection(file.id ?? ""),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.grey,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              const SizedBox(width: 8),
              _buildFileLeading(file, isUploading, isFailed),
            ],
          ),
          onTap: () {
            if (controller.isSelectionMode.value) {
              controller.toggleFileSelection(file.id ?? "");
            } else {
              controller.checkAndOpenFile(file);
            }
          },
          onLongPress: () {
            if (!controller.isSelectionMode.value) {
              controller.enterSelectionMode();
              controller.toggleFileSelection(file.id ?? "");
            }
          },
          title: Text(
            file.name.value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          subtitle: isFailed
              ? Text("Upload Failed",
                  style: Get.textTheme.bodyMedium!.copyWith(color: Colors.red))
              : Text(
                  AppStringFormat.formatModifiedDate(
                      file.uploadedAt!.toIso8601String()),
                  style: TextStyle(
                    color: isSelected
                        ? Get.theme.colorScheme.primary
                        : Get.theme.textTheme.bodyMedium?.color,
                  ),
                ),
          trailing: controller.isSelectionMode.value
              ? null
              : _buildFileTrailing(file, isUploading, isFailed),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          minVerticalPadding: 12,
        ),
      );
    });
  }

  Widget _buildFileLeading(FileItem file, bool isUploading, bool isFailed) {
    if (isUploading) {
      return Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: file.uploadProgress.value > 0
                ? file.uploadProgress.value
                : null,
            strokeWidth: 3,
            backgroundColor: AppColors.grey,
            valueColor: AlwaysStoppedAnimation<Color>(
              file.uploadProgress.value == 1.0
                  ? AppColors.accentDark
                  : AppColors.primary,
            ),
          ),
          Text(
            "${(file.uploadProgress.value * 100).toInt()}%",
            style: Get.textTheme.bodyMedium!
                .copyWith(color: Colors.white, fontSize: 11),
          ),
        ],
      );
    }
    return isFailed
        ? const Icon(Icons.error, color: AppColors.grey)
        : AppUtils.getFileIcon(file.name.value);
  }

  Widget _buildFileTrailing(FileItem file, bool isUploading, bool isFailed) {
    if (controller.isSelectionMode.value) {
      return SizedBox.shrink();
    }
    if (isFailed) {
      return IconButton(
        icon: Icon(Icons.close, color: AppColors.lightGrey),
        onPressed: () => controller.removeFailedFile(file),
      );
    }
    if (isUploading) {
      return Text(
        "${(file.uploadProgress.value * 100).toInt()}%",
        style: Get.textTheme.bodySmall,
      );
    }
    return IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () =>
          _showOptionsBottomSheet(file.name.value, isFile: true, file: file),
    );
  }

  void _showOptionsBottomSheet(
    String name, {
    required bool isFile,
    FileItem? file,
    Folder? folder,
  }) {
    final isDark = Get.isDarkMode;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFileFolderInfo(name, isFile, textColor),
            const Divider(),
            if (!isFile)
              _buildShareFolderOption(isFile, file, folder, name, textColor),
            if (isFile)
              _buildShareOption(
                  isFile, file, folder, name, textColor, Get.context!),
            if (isFile) _buildDownloadOption(file, textColor),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  ListTile _buildFileFolderInfo(String name, bool isFile, Color textColor) {
    return ListTile(
      leading: isFile ? AppUtils.getFileIcon(name) : const Icon(Icons.folder),
      title: Text(name,
          style: Get.textTheme.bodyLarge!
              .copyWith(fontWeight: FontWeight.bold, color: textColor)),
    );
  }

  ListTile _buildShareFolderOption(bool isFile, FileItem? file, Folder? folder,
      String name, Color textColor) {
    return ListTile(
      leading: Icon(Icons.share,
          color: Get.isDarkMode ? Colors.blue[300] : Colors.blue),
      title: Text("Share", style: TextStyle(color: textColor)),
      onTap: () {
        Get.back();
        _showShareDialog(
          file ?? FileItem(name: name),
          isFile,
          folder ?? Folder(id: "", name: name, createdAt: DateTime.now()),
        );
      },
    );
  }

  ListTile _buildShareOption(bool isFile, FileItem? file, Folder? folder,
      String name, Color textColor, BuildContext context) {
    return ListTile(
      leading: Icon(Icons.share,
          color: Get.isDarkMode ? Colors.blue[300] : Colors.blue),
      title: Text("Share",
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      subtitle: Text("Choose how you want to share",
          style:
              TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 12)),
      onTap: () {
        Get.back();
        Future.delayed(Duration(milliseconds: 200), () {
          _showShareOptionsBottomSheet(
              Get.context!, isFile, file, folder, name, textColor);
        });
      },
    );
  }

  void _showShareOptionsBottomSheet(BuildContext context, bool isFile,
      FileItem? file, Folder? folder, String name, Color textColor) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.black : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Share Options",
              style: TextStyle(
                  color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildNormalShareOption(file, textColor),
            _buildShareViaAppsOption(file, textColor, isFile, folder),
          ],
        ),
      ),
    );
  }

  ListTile _buildNormalShareOption(FileItem? file, Color textColor) {
    return ListTile(
      leading: Icon(Icons.link, color: Colors.greenAccent),
      title: Text("Share file link", style: TextStyle(color: textColor)),
      subtitle: Text("Share via WhatsApp, Email, or other apps",
          style:
              TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 12)),
      onTap: () {
        Get.back();
        controller.getFileUrlAndShare(file?.id ?? "");
      },
    );
  }

  ListTile _buildShareViaAppsOption(
      FileItem? file, Color textColor, bool isFile, Folder? folder) {
    return ListTile(
      leading: Icon(Icons.people_alt, color: Colors.blueAccent),
      title: Text("Share via App", style: TextStyle(color: textColor)),
      subtitle: Text("Share with users via app permissions",
          style:
              TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 12)),
      onTap: () {
        Get.back();
        Future.delayed(Duration(milliseconds: 200), () {
          _showShareDialog(file ?? FileItem(name: ""), isFile,
              folder ?? Folder(id: "", name: "", createdAt: DateTime.now()));
        });
      },
    );
  }

  ListTile _buildDownloadOption(FileItem? file, Color textColor) {
    return ListTile(
      leading: const Icon(Icons.download),
      title: Text("Download", style: TextStyle(color: textColor)),
      onTap: () {
        Get.back();
        controller.downloadFile(file?.id ?? "", file?.name.value ?? "");
      },
    );
  }

  Widget _buildPathNavigation() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: controller.currentPath.map((folder) {
          final isLast = controller.currentPath.last == folder;
          return Row(
            children: [
              GestureDetector(
                onTap: () => _navigateToFolder(folder),
                child: Text(
                  folder.name,
                  style: TextStyle(
                      color: isLast ? Colors.white54 : AppColors.primary),
                ),
              ),
              if (!isLast)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('/'),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _navigateToFolder(Folder folder) {
    final index = controller.currentPath.indexOf(folder);
    controller.currentPath
        .removeRange(index + 1, controller.currentPath.length);
    controller.update();
  }

  void _showCreateFolderDialog() {
    final nameController = TextEditingController(text: "Untitled Folder");
    final focusNode = FocusNode();

    Get.dialog(
      AlertDialog(
        title: const Text('Create New Folder'),
        content: TextField(
          controller: nameController,
          focusNode: focusNode,
          decoration: const InputDecoration(hintText: 'Folder name'),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                controller.createFolder(
                  nameController.text,
                  parentId: controller.currentFolderId,
                );
                Get.back();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      focusNode.requestFocus();
      nameController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: nameController.text.length,
      );
    });
  }

  void _showShareDialog(FileItem file, bool isFile, Folder folder) {
    final itemId = isFile ? file.id ?? "" : folder.id;
    final itemType = isFile ? 'file' : 'folder';

    Get.to(
      () => ShareScreen(
        users: controller.users,
        file: file,
        onShare: (emails, permissions) {
          controller.shareFile(
            itemId: itemId,
            itemType: itemType,
            sharedWithUserEmails: emails,
            actions: permissions,
          );
        },
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => controller.getFiles(),
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }
}
