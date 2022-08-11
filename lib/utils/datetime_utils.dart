import 'package:intl/intl.dart';

class MyDateUtils {
  static String formatMyDateTime(String dateString) {
    print("DATE : ${dateString}" );
    DateTime dt = DateTime.parse(dateString);
    print("dt : " +dt.toString());
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
    String formattedTime = DateFormat.jm() // 5:08 PM
    .format(dt)
    .split(' ')[0]; // 5:08
    print("formattedTime: "+  formattedTime);
    String? dayNight = {"AM": "오전", "PM": "오후"}[DateFormat("a").format(dt)];
    return "$formattedDate$formattedWeekDay  $dayNight $formattedTime"; // "22.08.01.월  오후 2:29"
  }

  static String sendMyDateTime(String dateString, String timeString){
    print("sendMyDateTime 으로 전달된 dateString은 : "+dateString);
    print("sendMyDateTime 으로 전달된 timeString은 : "+timeString);
    // dateString 의 형식 : "22.08.14.일"
    // timeString 의 형식 : "오후 3:45"
    String? dayNight = timeString.split(' ')[0]; // 오전, 오후
    String? dayNightEnglish = {"오전": "AM", "오후": "PM"}[timeString.split(' ')[0]]; // AM, PM
    String formattedTime = timeString.split(' ')[1]; // 오전인 경우(+ 오후 12시인 경우), 그 값 그대로 전달
    if (dayNight ==   "오후") { // 오후인 경우, 시간에 12시간 더해서 처리
      var hour = formattedTime.split(":")[0]; // 시
      var minute = formattedTime.split(":")[1]; // 분
      if (hour != "12") {
        formattedTime = (int.parse(hour) + 12).toString()+":" + minute;
      }
    }
    String tempDateTime = "20"+ dateString.substring(0, 8).replaceAll(".", "-") + " "+ formattedTime; // tempDate의 형식 : "2022-08-14"
    
    return tempDateTime;
  }

  static String formatMyDateTimeDone(String dateString) {
    DateTime dt = DateTime.parse(dateString);
    DateTime ddt = DateTime(dt.year, dt.month, dt.day - 4);
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
    String formattedTime = DateFormat.jm() // 5:08 PM
    .format(dt)
    .split(' ')[0];    
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
      "Sun": "일",
    }[DateFormat("E").format(dt)];
    String formattedTime = DateFormat.jm() // 5:08 PM
    .format(dt)
    .split(' ')[0];    
    String? dayNight = {"AM": "오전", "PM": "오후"}[DateFormat("a").format(dt)];
    return "$formattedDate$formattedWeekDay";
  }

  static String formatMyTime(String dateString) {
    DateTime dt = DateTime.parse(dateString);
    String formattedTime = DateFormat.jm() // 5:08 PM
    .format(dt)
    .split(' ')[0];    
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
