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

String dateNowWelcome() =>
    DateFormat("MMM dd, yyy - hh:mm aa").format(DateTime.now());
