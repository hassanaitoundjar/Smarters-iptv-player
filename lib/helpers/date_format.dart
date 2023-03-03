part of 'helpers.dart';

String expirationDate(String? timestamp) {
  try {
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp ?? "") * 1000);

    var format = DateFormat("dd MMM, yyy").format(date);

    return format;
  } catch (e) {
    return "error date";
  }
}

String getDurationMovie(String? time) {
  try {
    if (time == null) {
      return "";
    }

    //  List<String> list = time.split(":");
    //debugPrint("time! $list");

    var date = DateTime.parse("2022-12-21 $time");
    // debugPrint("DATE: $date");
    var hour = DateFormat("HH").format(date);
    var minuets = DateFormat("mm").format(date);
    var second = DateFormat("ss").format(date);

    return "${hour == "00" ? "" : "${hour}h"} ${minuets == "00" ? "" : "${minuets}m"} ${second == "00" ? "" : "${second}s"}";
  } catch (e) {
    debugPrint("Error: $e");
    return 'error';
  }
}

String dateNowWelcome() =>
    DateFormat("MMM dd, yyy - hh:mm aa").format(DateTime.now());

String getTimeFromDate(String date) {
  try {
    var format = DateFormat("HH:mm aa").format(DateTime.parse(date));

    return format;
  } catch (e) {
    debugPrint('Error: $e');
    return "";
  }
}

bool checkEpgTimeIsNow(String start, String end) {
  try {
    var startTimeE = DateTime.parse(start);
    var endTimeE = DateTime.parse(end);
    var now = DateTime.now();

    if (now.isAfter(startTimeE) && now.isBefore(endTimeE)) {
      // print('The time is between ${startTime.format(context)} and ${endTime.format(context)}.');
      return true;
    } else {
      // print('The time is not between ${startTime.format(context)} and ${endTime.format(context)}.');
      return false;
    }
  } catch (e) {
    debugPrint('Error: $e');
    return false;
  }
}
