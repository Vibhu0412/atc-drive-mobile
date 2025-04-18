import 'package:atc_drive/app/model/get_all_user_model.dart';
import 'package:atc_drive/app/model/home_folder_model.dart';
import 'package:atc_drive/app/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShareScreen extends StatefulWidget {
  final List<User> users;
  final FileItem file;
  final Function(List<String>, List<String>) onShare;

  const ShareScreen({
    super.key,
    required this.users,
    required this.file,
    required this.onShare,
  });

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedEmails = [];
  final List<String> _selectedPermissions = [];
  List<User> _filteredUsers = [];
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterUsers);
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _showSearchResults = query.isNotEmpty;
      _filteredUsers = widget.users.where((user) {
        return user.email.toLowerCase().contains(query) ||
            user.username.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _onSend() {
    widget.onShare(_selectedEmails, _selectedPermissions);
    Get.back();
  }

  void _onUserSelected(User user) {
    setState(() {
      if (_selectedEmails.contains(user.email)) {
        _selectedEmails.remove(user.email);
      } else {
        _selectedEmails.add(user.email);
      }
      _searchController.clear();
      _showSearchResults = false;
    });
  }

  Color _getUserColor(String email) {
    final int index = email.hashCode % AppColors.userColors.length;
    return AppColors.userColors[index];
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Get.isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        title: const Text('Share'),
        actions: [
          IconButton(
            onPressed: _selectedEmails.isEmpty ? null : _onSend,
            icon: Icon(
              Icons.send,
              color: AppColors.primaryLight,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Wrap(
              spacing: 8,
              children: _selectedEmails.map((email) {
                final user = widget.users.firstWhere((u) => u.email == email);
                final Color userColor = _getUserColor(user.email);
                return Chip(
                  avatar: Transform.scale(
                    scale: 1.8,
                    child: CircleAvatar(
                      backgroundColor: userColor,
                      child: Center(
                        child: Text(
                          user.email[0],
                          style: Get.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: AppColors.grey,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  label: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      user.email,
                      style: Get.textTheme.bodyMedium,
                    ),
                  ),
                  deleteIcon:
                      const Icon(Icons.close, size: 16, color: Colors.white),
                  onDeleted: () {
                    setState(() => _selectedEmails.remove(email));
                  },
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Icon(Icons.person_add_alt, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Add people and share',
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.grey),
          if (_showSearchResults)
            Expanded(
              child: ListView.builder(
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  // final isSelected = _selectedEmails.contains(user.email);
                  final Color userColor = _getUserColor(user.email);

                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          user.email,
                          style: Get.textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon(
                            //   isSelected
                            //       ? Icons.check_circle
                            //       : Icons.add_circle,
                            //   color: isSelected ? Colors.blue : Colors.black54,
                            //   size: 20,
                            // ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              maxRadius: 16,
                              backgroundColor: userColor,
                              child: Text(
                                user.email[0],
                                style: Get.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _onUserSelected(user),
                      ),
                      const Divider(color: AppColors.grey),
                    ],
                  );
                },
              ),
            ),
          if (_selectedEmails.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Text(
                'Permissions:',
                style: Get.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            const Divider(color: AppColors.grey),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                children: ['can_edit', 'can_share', 'can_delete', 'can_create']
                    .map((permission) {
                  final isSelected = _selectedPermissions.contains(permission);
                  return FilterChip(
                    label: Text(
                      permission
                          .split('_')
                          .map((word) => word.toLowerCase() == 'can'
                              ? ''
                              : word.capitalizeFirst!)
                          .where((word) => word.isNotEmpty)
                          .join(' '),
                      style: Get.textTheme.bodyMedium,
                    ),
                    selected: isSelected,
                    backgroundColor: Colors.transparent,
                    selectedColor: Colors.transparent,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.grey,
                      width: 1.5,
                    ),
                    checkmarkColor: AppColors.primary,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedPermissions.add(permission);
                        } else {
                          _selectedPermissions.remove(permission);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
