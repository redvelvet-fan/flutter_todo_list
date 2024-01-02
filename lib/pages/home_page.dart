import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list/controller/todo_tab_controller.dart';
import 'package:todo_list/controller/todo_task_list_controller.dart';
import 'package:todo_list/localization/localization_keys.dart';
import 'package:todo_list/models/todo_task.dart';
import 'package:todo_list/views/todo_list_view.dart';

import 'edit_todo_page.dart';

class HomePage extends GetView<TodoTabController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(TodoTaskListController());
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(LocalizationKeys.todo.tr),
          bottom: TabBar(
            controller: controller.tabController,
            onTap: (index) {
              //get current index
              if (controller.prevIndex.value != index) {
                controller.prevIndex.value = index;
                return;
              }
              //scroll to Top
              controller.scrollToTop(index);
            },
            tabs: [
              Tab(
                text: LocalizationKeys.inProgress.tr,
              ),
              Tab(
                text: LocalizationKeys.completed.tr,
              ),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Go to AddTodoPage
          Get.to(() => const EditTodoPage());
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
          child: TabBarView(
        controller: controller.tabController,
        children: [
          TodoListView(TodoTaskStatus.inProgress,
              scrollController: controller.inProgressScrollController),
          TodoListView(TodoTaskStatus.completed,
              scrollController: controller.completedScrollController),
        ],
      )),
    );
  }
}
