import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list/controller/todo_task_controller.dart';
import 'package:todo_list/pages/add_todo_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final TodoTaskController todoTaskController = Get.put(TodoTaskController());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('ToDo'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Go to AddTodoPage
          Get.to(() => AddTodoPage());
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Center(
          child: GestureDetector(
            onTap: ()async{
              //get all task from database
              await todoTaskController.getAllTodoTask();
              print(todoTaskController.todoTaskList);
              // remove todos table from database

            },
            child: Text(
              'Hello, world!',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}