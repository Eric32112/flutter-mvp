import 'package:tempo_official/consts/events_conts.dart';

class DateHelper {
  static String formateDate(DateTime date) {
    int hour = date.hour > 12 ? date.hour - 12 : date.hour;
    String pmOrAM = date.hour > 12 ? 'PM' : "AM";
    String minute = date.minute > 10 ? date.minute.toString() : '0' + date.minute.toString();
    return monthNames[date.month - 1] +
        ' ${date.day}, ${date.year} at ${hour < 10 ? '0' + hour.toString() : hour.toString()}:$minute' +
        ' ' +
        pmOrAM;
  }

  static List<String> monthNames = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  static String formateDay(DateTime date) {
    return monthNames[date.month - 1] + ' ${date.day}, ${date.year} ';
  }

  static String parseDuration(String value) {
    if (value == null) {
      return Duration(minutes: 5).inMinutes.toString() + 'minutes';
    }
    Duration duration;

    int indexOfEvent = EventConstants.notificationOptions.indexOf(value);
    if (indexOfEvent != -1) {
      return Duration(
              days: value == EventConstants.notificationOptions[0] ? 1 : 0,
              hours: value == EventConstants.notificationOptions[1]
                  ? 1
                  : EventConstants.notificationOptions[2] == value ? 2 : 0,
              minutes: value.startsWith("30")
                  ? 30
                  : value.startsWith('15') ? 15 : value.startsWith('5') ? 5 : 0)
          .inSeconds
          .toString();
    } else {
      duration = Duration(milliseconds: int.parse(value));
      return duration.inHours < 1
          ? duration.inMinutes.toString() + ' minutes'
          : duration.inHours.toString() + (duration.inHours > 1 ? ' hour' : ' hours');
    }
  }

  static String getEventHelper(String e, DateTime parse) {
    Duration duration = Duration(
        days: e.contains('day') ? 1 : 0,
        hours: e.contains('hour') ? int.parse(e.replaceAll('_hour', '')) : 0,
        minutes: e.contains('minute') ? int.parse(e.replaceAll('_minute', '')) : 0);
    return duration.inMilliseconds.toString();
  }

  static String parseTime(DateTime date) {
    int hour = date.hour > 12 ? date.hour - 12 : date.hour;
    String pmOrAM = date.hour > 12 ? 'PM' : "AM";
    String minute = date.minute > 10 ? date.minute.toString() : '0' + date.minute.toString();
    return '${hour < 10 ? '0' + hour.toString() : hour.toString()}:$minute' + ' ' + pmOrAM;
  }

  static formateStartAndEndTime(DateTime dateTime, DateTime endDateTime) {
    int hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    int endHour = endDateTime.hour > 12 ? endDateTime.hour - 12 : endDateTime.hour;
    String pmOrAM = dateTime.hour > 12 ? 'PM' : "AM";
    String endPmOrAm = endDateTime.hour > 12 ? 'PM' : "AM";
    String minute = dateTime.minute > 10 ? dateTime.minute.toString() : '0' + dateTime.minute.toString();
    String endMinute =
        endDateTime.minute > 10 ? endDateTime.minute.toString() : '0' + endDateTime.minute.toString();

    return '$hour:$minute $pmOrAM' + ' - ' + '$endHour:$endMinute $endPmOrAm';
  }

  static DateTime parseFromMilliseconds(String startDate) {
    return DateTime.fromMillisecondsSinceEpoch(int.parse(startDate));
  }

  static String formatTime(DateTime date) {
    int hour = date.hour > 12 ? date.hour - 12 : date.hour;
    String pmOrAM = date.hour > 12 ? 'PM' : "AM";
    String minute = date.minute > 10 ? date.minute.toString() : '0' + date.minute.toString();
    return ' ${hour < 10 ? '0' + hour.toString() : hour.toString()}:$minute' + ' ' + pmOrAM;
  }

  static getDisplayableDuration(String duration) {
    Duration dur = Duration(milliseconds: int.parse(duration));
    if (dur.inHours == 24) {
      return 'All-day';
    } else if (dur.inHours > 0) {
      return '${dur.inHours} hour';
    } else if (dur.inHours == 0 && dur.inMinutes > 0) {
      return '${dur.inMinutes} minute';
    }
    return '${dur.inMinutes} minute';
  }
}
