import 'package:get/get.dart';
import 'package:todo_list/models/todo_task.dart';
import 'package:todo_list/services/database_service.dart';

class TodoTaskController extends GetxController {
  RxList todoTaskList = [].obs;
  //define database service for sync with database
  final DatabaseService _databaseService = DatabaseService();

  @override
  void onInit() {
    super.onInit();
    //sync with database
    _databaseService.getAllTodoTask().then((value) => todoTaskList.value = value);
  }

  void addTodoTask(TodoTask todoTask) {
    todoTaskList.add(todoTask);
    //sync with database
    _databaseService.insertTodoTask(todoTask);
  }

  void removeTodoTask(TodoTask todoTask) {
    todoTaskList.remove(todoTask);
    //sync with database
    _databaseService.deleteTodoTask(todoTask);
  }

  Future<void> getAllTodoTask() async{
    todoTaskList.value = await _databaseService.getAllTodoTask();
  }
}