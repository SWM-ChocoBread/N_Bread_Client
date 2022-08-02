import 'package:intl/intl.dart';

class MyDateUtils {
  static String formatMyDateTime(String dateString) {
    DateTime dt = DateTime.parse(dateString);
    String formattedDate = DateFormat('yy.MM.dd.').format(dt);
    String? formattedWeekDay = {
      "Mon": "월",
      "Tue": "화",
      "Wed": "수",
      "Thu": "목",
      "Fri": "금",
      "Sat": "토",
      "Sun": "일"
    }[DateFormat("E").format(dt)];
    String formattedTime = DateFormat('hh:MM').format(dt);
    String? dayNight = {"AM": "오전", "PM": "오후"}[DateFormat("a").format(dt)];
    return "$formattedDate$formattedWeekDay  $dayNight $formattedTime"; // "22.08.01.월  오후 2:29"
  }

  static String formatMyDateTimeDone(String dateString) {
    DateTime dt = DateTime.parse(dateString);
    DateTime ddt = DateTime(dt.year, dt.month, dt.day - 3);
    String formattedDate = DateFormat('yy.MM.dd.').format(ddt);
    String? formattedWeekDay = {
      "Mon": "월",
      "Tue": "화",
      "Wed": "수",
      "Thu": "목",
      "Fri": "금",
      "Sat": "토",
      "Sun": "일"
    }[DateFormat("E").format(dt)];
    String formattedTime = DateFormat('hh:MM').format(dt);
    String? dayNight = {"AM": "오전", "PM": "오후"}[DateFormat("a").format(dt)];
    return "$formattedDate$formattedWeekDay  $dayNight $formattedTime";
  }

  static String formatMyDate(String dateString) {
    DateTime dt = DateTime.parse(dateString);
    String formattedDate = DateFormat('yy.MM.dd.').format(dt);
    String? formattedWeekDay = {
      "Mon": "월",
      "Tue": "화",
      "Wed": "수",
      "Thu": "목",
      "Fri": "금",
      "Sat": "토",
      "Sun": "일"
    }[DateFormat("E").format(dt)];
    String formattedTime = DateFormat('hh:MM').format(dt);
    String? dayNight = {"AM": "오전", "PM": "오후"}[DateFormat("a").format(dt)];
    return "$formattedDate$formattedWeekDay";
  }

  static String formatMyTime(String dateString) {
    DateTime dt = DateTime.parse(dateString);
    String formattedTime = DateFormat('hh:MM').format(dt);
    String? dayNight = {"AM": "오전", "PM": "오후"}[DateFormat("a").format(dt)];
    return "$dayNight $formattedTime";
  }

  static String dateTimeDifference(String dateString) {
    var newDateString =
        '${dateString.substring(0, 10)} ${dateString.substring(11, 23)}';
    DateTime dt = DateTime.parse(newDateString);
    DateTime now = DateTime.now();
    final seconds = now.difference(dt).inSeconds;
    final minutes = now.difference(dt).inMinutes;
    final hours = now.difference(dt).inHours;
    final days = now.difference(dt).inDays;
    final years = days ~/ 365;
    final months = (days - years * 365) ~/ 30;
    if (seconds < 60) {
      return "${seconds.toString()}초 전";
    } else if (minutes < 60) {
      return "${minutes.toString()}분 전";
    } else if (hours < 24) {
      return "${hours.toString()}시간 전";
    } else if (days < 30) {
      return "${days.toString()}일 전";
    } else if (months < 12) {
      return "${months.toString()}달 전";
    } else {
      return "${years.toString()}년 전";
    }
  }
}
