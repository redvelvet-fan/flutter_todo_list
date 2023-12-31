import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list/controller/list_item_controller.dart';
import 'package:todo_list/controller/todo_task_controller.dart';
import 'package:todo_list/models/todo_task.dart';

class ListItem extends GetView<TodoTaskController> {
  const ListItem({
    Key? key,
    required this.todoTask,
    this.onTap,
  }) : super(key: key);

  final TodoTask todoTask;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final itemController = Get.put(
        ListItemController(isChecked: todoTask.completedAt != null),
        tag: todoTask.id.toString());

    return Obx(()=>GestureDetector(
          onTap: onTap,
          child: SizeTransition(
            sizeFactor: CurvedAnimation(
                    parent: itemController.animationController,
                    curve: Curves.fastOutSlowIn)
                .drive(Tween<double>(begin: 1.0, end: 0.0)),
            axis: Axis.vertical,
            axisAlignment: -1.0,
            child: SizedBox(
              height: 180,
              child: Row(
                children: [
                  Checkbox(
                    value: itemController.isChecked.value,
                    onChanged: (bool? value) {
                      itemController.toggle();
                      Future.delayed(const Duration(milliseconds: 500),
                          () async {
                        try {
                          await itemController.animationController.forward();
                          await controller.toggleTodoTaskStatus(todoTask);
                        }catch(e){
                          print(e);
                        }
                      });
                    },
                  ),
                  Expanded(child: Text(todoTask.title)),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.drag_handle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
