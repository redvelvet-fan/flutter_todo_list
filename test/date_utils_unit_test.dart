import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:todo_list/localization/localization.dart';
import 'package:todo_list/utils/todo_date_utils.dart';

void main(){

  changeLocale(Locale l){
    Get.updateLocale(l);
  }
  testWidgets('Date Formatted with Localization', (WidgetTester tester) async {
    final commonCase = DateTime(2024, 1, 3, 11, 9);
    final midnightCase = DateTime(2024, 1, 3, 0, 0);
    final noonCase = DateTime(2024, 1, 3, 12, 0);

    const unRegisteredLocale = Locale('ja', 'JP');
    const koLocate = Locale('ko', 'KR');
    const enLocate = Locale('en', 'US');


    await tester.pumpWidget(GetMaterialApp(
      locale: unRegisteredLocale,
      translations: Localization(),
      fallbackLocale: enLocate,
      home: const Scaffold(
        body: Center(
          child: Text("Test Localization need GetMaterialApp")
        ),
      )
    ));
    // unRegisteredLocale
    // Common Case
    expect(TodoDateUtils.getFormattedDate(commonCase), "2024.01.03 AM 11:09");
    // 00:00 to AM 12:00 Case (midnight)
    expect(TodoDateUtils.getFormattedDate(midnightCase), "2024.01.03 AM 12:00");
    // 12:00 to PM 12:00 Case (noon)
    expect(TodoDateUtils.getFormattedDate(noonCase), "2024.01.03 PM 12:00");

    // change Locale to 'ko_KR'
    changeLocale(koLocate);
    await tester.pumpAndSettle();
    // Common Case
    expect(TodoDateUtils.getFormattedDate(commonCase), "2024.01.03 오전 11:09");
    // 00:00 to AM 12:00 Case (midnight)
    expect(TodoDateUtils.getFormattedDate(midnightCase), "2024.01.03 오전 12:00");
    // 12:00 to PM 12:00 Case (noon)
    expect(TodoDateUtils.getFormattedDate(noonCase), "2024.01.03 오후 12:00");

    // change Locale to 'en_US'
    changeLocale(enLocate);
    await tester.pumpAndSettle();
    // Common Case
    expect(TodoDateUtils.getFormattedDate(commonCase), "2024.01.03 AM 11:09");
    // 00:00 to AM 12:00 Case (midnight)
    expect(TodoDateUtils.getFormattedDate(midnightCase), "2024.01.03 AM 12:00");
    // 12:00 to PM 12:00 Case (noon)
    expect(TodoDateUtils.getFormattedDate(noonCase), "2024.01.03 PM 12:00");
  });
}