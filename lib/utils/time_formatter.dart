import 'package:intl/intl.dart';

String timeAgo(String dateString) {
  DateTime inputDate = DateTime.parse(dateString);
  DateTime now = DateTime.now();
  Duration difference = now.difference(inputDate);

  if (difference.inMinutes < 1) {
    return 'just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} minutes ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hours ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else {
    return DateFormat('yyyy-MM-dd').format(inputDate);
  }
}
