import 'package:intl/intl.dart';

class AppStringFormat {
  static String formatModifiedDate(String uploadedAt) {
    DateTime createdAt = DateTime.parse(uploadedAt).toLocal();
    DateTime now = DateTime.now();

    if (createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day) {
      return "Modified ${DateFormat.jm().format(createdAt)}";
    } else {
      return "Modified ${DateFormat('dd MMM yyyy').format(createdAt)}";
    }
  }
}
