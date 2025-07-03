import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String getTimeLeft(Timestamp endTime) {
  DateTime now = DateTime.now();
  DateTime endDateTime = endTime.toDate();
  Duration difference = endDateTime.difference(now);
  if (difference.inDays > 1) {
    return '${difference.inDays} days';
  } else if (difference.inHours > 1) {
    return '${difference.inHours} hours';
  } else {
    return '${difference.inMinutes} minutes';
  }
}

bool isSameDay(DateTime? a, DateTime? b) {
    return a?.year == b?.year && a?.month == b?.month && a?.day == b?.day;
  }

  String getDayWithOrdinal(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String day = getDayWithOrdinal(dateTime.day);
    String month = DateFormat('MMMM').format(dateTime);
    String time = DateFormat('HH:mm').format(dateTime);

    return '$day $month, $time';
  }
