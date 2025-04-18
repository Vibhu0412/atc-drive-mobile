import 'package:atc_drive/app/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppBottomSheets {
  static void showOptionsBottomSheet({
    required BuildContext context,
    required String title,
    required List<BottomSheetOption> options,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              shrinkWrap: true,
              itemCount: options.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final option = options[index];
                final isEnabled =
                    option.label == "Folder" || option.label == "Upload";
                return InkWell(
                  onTap: isEnabled ? option.onTap : null,
                  child: Opacity(
                    opacity: isEnabled ? 1.0 : 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.grey.withValues(alpha: 0.5),
                            ),
                            borderRadius: BorderRadius.circular(24),
                            color: AppColors.floatingActionButtonColor,
                          ),
                          child: Icon(
                            option.icon,
                            color: AppColors.grey.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          option.label,
                          style: TextStyle(
                            color: isEnabled
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  static void showCustomBottomSheet({
    required BuildContext context,
    required Widget child,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: child,
        );
      },
    );
  }
}

class BottomSheetOption {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  BottomSheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
