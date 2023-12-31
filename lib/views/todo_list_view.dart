import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list/controller/todo_task_controller.dart';
import 'package:todo_list/models/todo_task.dart';

class TodoListView extends GetView<TodoTaskController> {
  const TodoListView(this.status,{Key? key}) : super(key: key);

  final TodoTaskStatus status;

  @override
  Widget build(BuildContext context) {
    final todoTaskList = status == TodoTaskStatus.inProgress
        ? controller.inProgressTodoTaskList
        : controller.completedTodoTaskList;
    return Obx(
      () => ReorderableListView.builder(
        key: PageStorageKey(status),
        itemBuilder: (context, index) {
          return ListTile(
            key: Key('$index'),
            title: Text('${todoTaskList[index].id}'),
            subtitle: Text(todoTaskList[index].description ?? ''),
            trailing: IconButton(
              onPressed: () {
                controller.removeTodoTask(todoTaskList[index]);
              },
              icon: const Icon(Icons.delete),
            ),
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
