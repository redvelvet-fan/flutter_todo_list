class DateUtils{
  static String getFormattedDate(DateTime dateTime) {
    //format like 2023.12.29 오후 5:30
    String year = dateTime.year.toString();
    String month = dateTime.month.toString().padLeft(2,'0');
    String day = dateTime.day.toString().padLeft(2,'0');
    String hour = dateTime.hour.toString().padLeft(2,'0');
    String minute = dateTime.minute.toString().padLeft(2,'0');

    String datOrNight = dateTime.hour < 12 ? '오전' : '오후';

    return '$year.$month.$day $datOrNight $hour:$minute';
  }
}