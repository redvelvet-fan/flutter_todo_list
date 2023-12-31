import 'package:flutter/animation.dart';
import 'package:get/get.dart';

class ListItemController extends GetxController with GetSingleTickerProviderStateMixin{
  final isChecked = false.obs;
  late final AnimationController animationController;

  ListItemController({required bool isChecked}){
    this.isChecked.value = isChecked;
  }


  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    animationController.addStatusListener(_afterFinishAnimation);
  }

  _afterFinishAnimation(AnimationStatus status){
    if(status == AnimationStatus.completed){
      animationController.reset();
    }
  }

  @override
  void dispose() {
    animationController.removeStatusListener(_afterFinishAnimation);
    animationController.dispose();
    super.dispose();
  }

  void toggle(){
    isChecked.value = !isChecked.value;
  }
}