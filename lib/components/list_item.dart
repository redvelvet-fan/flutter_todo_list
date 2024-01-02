import 'package:flutter/material.dart' hide DateUtils;
import 'package:get/get.dart';
import 'package:todo_list/controller/list_item_controller.dart';
import 'package:todo_list/controller/todo_task_list_controller.dart';
import 'package:todo_list/localization/localization_keys.dart';
import 'package:todo_list/models/todo_task.dart';
import 'package:todo_list/utils/date_utils.dart';
import 'package:todo_list/utils/default_values.dart';

class ListItem extends GetView<TodoTaskListController> {
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

    onChanged(bool? value) async {
      await itemController.toggle();
      await itemController.animationController.forward();
      await controller.toggleTodoTaskStatus(todoTask);
    }

    String dateInfo(String title, DateTime? dateTime) {
      if(todoTask.deadline != null){
        return "${LocalizationKeys.deadline.tr} : ${DateUtils.getFormattedDate(todoTask.deadline)}";
      }
      if(todoTask.completedAt != null){
        return "${LocalizationKeys.completedAt.tr} : ${DateUtils.getFormattedDate(todoTask.completedAt)}";
      }
      return "";
    }

    TextStyle dateInfoStyle(DateTime? dateTime){
      var defaultStyle = TextStyle(
        fontSize: DefaultValues.fontSizeSmall,
        color: Theme.of(context).hintColor,
      );
      if(todoTask.deadline != null){
        defaultStyle = defaultStyle.copyWith(
          color: Colors.red,
        );
      }
      if(todoTask.completedAt != null){
        defaultStyle = defaultStyle.copyWith(
          color: Colors.green,
        );
      }
      return defaultStyle;
    }

    return Obx(() => GestureDetector(
          onTap: onTap,
          child: SizeTransition(
            sizeFactor: CurvedAnimation(
                    parent: itemController.animationController,
                    curve: Curves.fastOutSlowIn)
                .drive(Tween<double>(begin: 1.0, end: 0.0)),
            axis: Axis.vertical,
            axisAlignment: -1.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: DefaultValues.gap),
              child: Row(
                children: [
                  Checkbox(
                    value: itemController.isChecked.value,
                    onChanged: onChanged,
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (todoTask.deadline != null &&
                          todoTask.status == TodoTaskStatus.inProgress)
                        Text(
                          dateInfo(LocalizationKeys.deadline, todoTask.deadline),
                          style: dateInfoStyle(todoTask.deadline),
                        ),
                      if (todoTask.completedAt != null &&
                          todoTask.status == TodoTaskStatus.completed)
                        Text(
                          dateInfo(LocalizationKeys.completedAt, todoTask.completedAt),
                          style: dateInfoStyle(todoTask.completedAt),
                        ),
                      Text(
                        todoTask.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (todoTask.description != null &&
                          todoTask.description!.isNotEmpty)
                        Text(
                          todoTask.description
                                  ?.replaceAllMapped("\n", (match) => " ") ??
                              "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  )),
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
