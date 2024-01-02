import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list/localization/localization_keys.dart';

class DateUtils{
  static String getFormattedDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    //format like 2023.12.29 오후 5:30
    String year = dateTime.year.toString();
    String month = dateTime.month.toString().padLeft(2,'0');
    String day = dateTime.day.toString().padLeft(2,'0');
    // 24시간제를 12시간제로 변환
    // 다만 오전 00시와, 오후 00시는 12시로 표기
    int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    String hourString = hour.toString().padLeft(2,'0');
    String minute = dateTime.minute.toString().padLeft(2,'0');

    String datOrNight = dateTime.hour < 12 ? LocalizationKeys.am.tr : LocalizationKeys.pm.tr;

    return '$year.$month.$day $datOrNight $hourString:$minute';
  }

  static Future<DateTime?> selectDate({required BuildContext context}) async {
    DateTime today = DateTime.now();
    DateTime? selectedTime = await showDatePicker(
      context: context,
      firstDate: today.subtract(const Duration(days: 365 * 18)),
      lastDate: DateTime(today.year + 36),
      initialDate: today,
    );

    return selectedTime;
  }

  static Future<DateTime?> selectTime({required BuildContext context}) async {
    DateTime now = DateTime.now();
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
    );

    if (selectedTime != null) {
      return DateTime(now.year, now.month, now.day, selectedTime.hour,
          selectedTime.minute);
    }

    return null;
  }

  static Future<DateTime?> selectDateTime(BuildContext context) async {
    DateTime? selectedDate = await selectDate(context: context);
    if (selectedDate != null && context.mounted) {
      DateTime? selectedTime = await selectTime(context: context);
      if (selectedTime != null) {
        DateTime selectedDeadline = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute);
        return selectedDeadline;
      }
    }
    return null;
  }
}