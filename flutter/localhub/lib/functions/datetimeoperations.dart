String timeAgo(String fatchedDateString) {
  DateTime fatchedDate = DateTime.parse(fatchedDateString);
  DateTime currentDate = DateTime.now();

  var different = currentDate.difference(fatchedDate);

  if (different.inDays > 365) {
    return "${(different.inDays / 365).floor()}y ago";
  }
  if (different.inDays > 30) {
    return "${(different.inDays / 30).floor()}m ago";
  }
  if (different.inDays > 7) {
    return "${(different.inDays / 7).floor()}w ago";
  }
  if (different.inDays > 0) {
    return "${different.inDays}d ago";
  }
  if (different.inHours > 0) {
    return "${different.inHours}hr ago";
  }
  if (different.inMinutes > 0) {
    return "${different.inMinutes}min ago";
  }
  if (different.inMinutes == 0) return 'Just Now';

  return fatchedDate.toString();
}
