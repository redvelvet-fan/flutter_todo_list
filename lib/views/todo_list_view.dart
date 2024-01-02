import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list/components/list_item.dart';
import 'package:todo_list/controller/todo_task_list_controller.dart';
import 'package:todo_list/models/todo_task.dart';
import 'package:todo_list/pages/edit_todo_page.dart';

class TodoListView extends GetView<TodoTaskListController> {
  const TodoListView(this.status, {Key? key, this.scrollController})
      : super(key: key);

  final TodoTaskStatus status;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final todoTaskList = status == TodoTaskStatus.inProgress
        ? controller.inProgressTodoTaskList
        : controller.completedTodoTaskList;
    return Obx(
      () {
        if (!controller.isLoaded) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (todoTaskList.isEmpty) {
          return const Center(
            child: Text("No Todo Task"),
          );
        }
        return ReorderableListView.builder(
        key: PageStorageKey(status),
        scrollController: scrollController,
        itemBuilder: (context, index) {
          final todoTask = todoTaskList[index];
          return Container(
            key: Key("${status}_${todoTask.id}"),
              color: index.isEven ? Theme.of(context).hoverColor : Theme.of(context).cardColor,
            child: ListItem(
              todoTask: todoTaskList[index],
              onTap: () {
                print("tap $index");
                //go to detail page
                Get.to(() => EditTodoPage(
                      defaultTodoTask: todoTask,
                    ));
              },
            ),
          );
        },
        itemCount: todoTaskList.length,
        buildDefaultDragHandles: !controller.isOnProgress,

        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          controller.reorderTodoTask(todoTaskList[oldIndex], newIndex);
        },
      );
      },
    );
  }
}
