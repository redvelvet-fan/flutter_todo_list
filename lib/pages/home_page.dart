import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list/controller/todo_task_controller.dart';
import 'package:todo_list/models/todo_task.dart';
import 'package:todo_list/pages/add_todo_page.dart';
import 'package:todo_list/views/todo_list_view.dart';

class HomePage extends GetView<TodoTaskController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todoTaskList = controller.inProgressTodoTaskList;
    final isOnProgress = controller.isOnProgress;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: true,
            title: GestureDetector(
                onTap: () {
                  for (int i = 0; i < todoTaskList.length; i++) {
                    print(
                        '${todoTaskList[i].title} : ${todoTaskList[i].prevId} -> ${todoTaskList[i].id} -> ${todoTaskList[i].nextId}');
                  }
                },
                child: Text('ToDo')),
            bottom: TabBar(
              tabs: const [
                Tab(
                  text: 'In Progress',
                ),
                Tab(
                  text: 'Completed',
                ),
              ],
            )),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Go to AddTodoPage
            Get.toNamed('/add');
          },
          child: const Icon(Icons.add),
        ),
        body: SafeArea(
            child: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            TodoListView(TodoTaskStatus.inProgress),
            TodoListView(TodoTaskStatus.completed),
          ],
        )),
      ),
    );
  }
}
