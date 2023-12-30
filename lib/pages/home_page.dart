import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list/controller/todo_task_controller.dart';
import 'package:todo_list/pages/add_todo_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TodoTaskController todoTaskController = Get.put(TodoTaskController());
    final todoTaskList = todoTaskController.todoTaskList;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title:  GestureDetector(
          onTap: (){
                  print(todoTaskController.todoTaskList);
          },
            child: Text('ToDo')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Go to AddTodoPage
          Get.to(() => AddTodoPage());
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child : Obx(() {
          if (todoTaskList.isEmpty) {
            return const Center(
              child: Text('No data'),
            );
          }
          return ReorderableListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  key: Key('$index'),
                  title: Text(todoTaskList[index].title),
                  subtitle: Text(todoTaskList[index].description ?? ''),
                  trailing: IconButton(
                    onPressed: () {
                      todoTaskController.removeTodoTask(
                          todoTaskList[index]);
                    },
                    icon: const Icon(Icons.delete),
                  ),
                );
              },
              itemCount: todoTaskList.length,
              buildDefaultDragHandles: !todoTaskController.isOnProgress.value,
              onReorder: todoTaskController.switchOrderIndex);
        }),
      ),
    );
  }
}
