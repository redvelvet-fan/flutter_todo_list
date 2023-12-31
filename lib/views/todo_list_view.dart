import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list/components/list_item.dart';
import 'package:todo_list/controller/todo_task_controller.dart';
import 'package:todo_list/models/todo_task.dart';

class TodoListView extends GetView<TodoTaskController> {
  const TodoListView(this.status, {Key? key,this.scrollController}) : super(key: key);

  final TodoTaskStatus status;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final todoTaskList = status == TodoTaskStatus.inProgress
        ? controller.inProgressTodoTaskList
        : controller.completedTodoTaskList;
    return Obx(
      () => ReorderableListView.builder(
        key: PageStorageKey(status),
        scrollController: scrollController,
        itemBuilder: (context, index) {
          final id = todoTaskList[index].id;
          return ListItem(
            todoTask:todoTaskList[index],
            key: Key("${status}_$id"),
            onTap: () {
              print("tap $index");
              //go to detail page
            },
          );
        },
        itemCount: todoTaskList.length,
        buildDefaultDragHandles: !controller.isOnProgress.value,
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          controller.reorderTodoTask(todoTaskList[oldIndex], newIndex);
        },
      ),
    );
  }
}
