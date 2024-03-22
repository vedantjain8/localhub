String timeAgo(String fatchedDateString) {
  DateTime fatchedDate = DateTime.parse(fatchedDateString);
  DateTime currentDate = DateTime.now();

  var different = currentDate.difference(fatchedDate);

  if (different.inDays > 365) {
    return "${(different.inDays / 365).floor()}y ";
  }
  if (different.inDays > 30) {
    return "${(different.inDays / 30).floor()}m ";
  }
  if (different.inDays > 7) {
    return "${(different.inDays / 7).floor()}w ";
  }
  if (different.inDays > 0) {
    return "${different.inDays}d ";
  }
  if (different.inHours > 0) {
    return "${different.inHours}hr ";
  }
  if (different.inMinutes > 0) {
    return "${different.inMinutes}min ";
  }
  if (different.inMinutes == 0) return 'Just Now';

  return fatchedDate.toString();
}
