import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TodoTabController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final TabController tabController;
  final inProgressScrollController = ScrollController();
  final completedScrollController = ScrollController();
  var prevIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
  }

  int get currentIndex => tabController.index;

  void scrollToTop(int index) {
    var targetScrollController =
        index == 0 ? inProgressScrollController : completedScrollController;
    targetScrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }
}
