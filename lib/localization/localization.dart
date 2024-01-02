import 'package:get/get.dart';
import 'package:todo_list/localization/translation/en_US.dart';
import 'package:todo_list/localization/translation/ko_KR.dart';

class Localization extends Translations{

  @override
  Map<String, Map<String, String>> get keys => {
    'en_US' : en_US,
    'ko_KR' : ko_KR
  };
}