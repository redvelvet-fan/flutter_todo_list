import 'package:get/get.dart';
import 'package:todo_list/models/todo_task.dart';
import 'package:todo_list/services/database_service.dart';

class TodoTaskController extends GetxController {
  final todoTaskList = RxList<TodoTask>([]);
  // define is on progress
  final isOnProgress = false.obs;
  //define database service for sync with database
  final DatabaseService _databaseService = DatabaseService();

  @override
  void onInit() {
    super.onInit();
    //sync with database
    _databaseService.getAllTodoTask().then((value) => todoTaskList.value = value);
  }

  void addTodoTask(TodoTask todoTask) async{
    isOnProgress.value = true;
    try {
      // add to top of list
      var taskId = await _databaseService.insertTodoTask(todoTask);

      todoTask.id = taskId;
      //sync with database
      todoTaskList.insert(0, todoTask);
    }catch(e){ rethrow;}
    finally{
      isOnProgress.value = false;
    }
  }

  void removeTodoTask(TodoTask todoTask) async{
    isOnProgress.value = true;
    //remove from database
    try {
      await _databaseService.deleteTodoTask(todoTask);
      //sync with database
      todoTaskList.remove(todoTask);
    }catch(e){ rethrow;}
    finally{
      isOnProgress.value = false;
    }
  }

  void switchOrderIndex(int logicalOldIndex, int logicalNewIndex){
    if (logicalOldIndex < logicalNewIndex) {
      logicalNewIndex -= 1;
    }
    print('oldIndex: $logicalOldIndex, newIndex: $logicalNewIndex');
    //sync with database
    _databaseService.switchOrderIndex(todoTaskList[logicalOldIndex], todoTaskList[logicalNewIndex]);
    //reorder list
    todoTaskList.insert(logicalNewIndex, todoTaskList.removeAt(logicalOldIndex));
  }

  List<TodoTask> getAllTodoTask() {
    return todoTaskList.obs.value;
  }
}