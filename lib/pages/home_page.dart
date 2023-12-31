import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list/controller/todo_tab_controller.dart';
import 'package:todo_list/controller/todo_task_controller.dart';
import 'package:todo_list/models/todo_task.dart';
import 'package:todo_list/views/todo_list_view.dart';

class HomePage extends GetView<TodoTaskController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todoTaskList = controller.inProgressTodoTaskList;
    final todoTabController = Get.put(TodoTabController());
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          title: GestureDetector(
              onTap: () {
                for (int i = 0; i < todoTaskList.length; i++) {
                  print(
                      '${todoTaskList[i].title}(${todoTaskList[i].status}: ${todoTaskList[i].completedAt}) : ${todoTaskList[i].prevId} -> ${todoTaskList[i].id} -> ${todoTaskList[i].nextId}');
                }
              },
              child: Text('ToDo')),
          bottom: TabBar(
            controller: todoTabController.controller,

            onTap: (index) {
              //get current index
              if (todoTabController.prevIndex.value != index) {
                todoTabController.prevIndex.value = index;
                return;
              }
              //scroll to Top
              todoTabController.scrollToTop(index);
            },
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
        controller: todoTabController.controller,
        children: [
          TodoListView(TodoTaskStatus.inProgress,
              scrollController: todoTabController.inProgressScrollController),
          TodoListView(TodoTaskStatus.completed,
              scrollController: todoTabController.completedScrollController),
        ],
      )),
    );
  }
}
