String timeAgo(String fatchedDateString) {
  DateTime fatchedDate = DateTime.parse(fatchedDateString);
  DateTime currentDate = DateTime.now();

  var different = currentDate.difference(fatchedDate);

  if (different.inDays > 365) {
    return "${(different.inDays / 365).floor()} ${(different.inDays / 365).floor() == 1 ? "year" : "years"} ago";
  }
  if (different.inDays > 30) {
    return "${(different.inDays / 30).floor()} ${(different.inDays / 30).floor() == 1 ? "month" : "months"} ago";
  }
  if (different.inDays > 7) {
    return "${(different.inDays / 7).floor()} ${(different.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
  }
  if (different.inDays > 0) {
    return "${different.inDays} ${different.inDays == 1 ? "day" : "days"} ago";
  }
  if (different.inHours > 0) {
    return "${different.inHours} ${different.inHours == 1 ? "hour" : "hours"} ago";
  }
  if (different.inMinutes > 0) {
    return "${different.inMinutes} ${different.inMinutes == 1 ? "minute" : "minutes"} ago";
  }
  if (different.inMinutes == 0) return 'Just Now';

  return fatchedDate.toString();
}