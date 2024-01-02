import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:todo_list/controller/todo_task_controller.dart';
import 'package:todo_list/controller/todo_task_list_controller.dart';
import 'package:todo_list/models/todo_task.dart';
import 'package:todo_list/services/database_service.dart';

void main() {

  listContains(List<TodoTask> list, TodoTask todoTask) {
    return list.any((todo) => todo.isSame(todoTask));
  }
  setUpAll(() async {
    databaseFactory = databaseFactoryFfi;
    DatabaseService.isTest = true;
    //for separate database for each test
    await DatabaseService.initDatabase(databaseName: 'unit_test.db');
    Get.put(TodoTaskListController());
  });
  group('Todo Task Test : ', () {
    test('Insert First Item', () async {
      final todoController = Get.put(TodoTaskController(null));
      todoController.title = "First Title";
      todoController.description = "Test Description";
      todoController.deadline = DateTime.now();
      //call TodoTaskController
      TodoTask newTask = todoController.todoTask;
      final controller = Get.find<TodoTaskListController>();
      await controller.insertTodoTask(0, newTask);
      expect(
          controller.inProgressTodoTaskList.any((todo) => todo.isSame(newTask)),
          isTrue, reason: "newTask must be in inProgressTodoTaskList");
      expect(
        controller.completedTodoTaskList.any((todo) => todo.isSame(newTask)),
        isFalse, reason: "newTask must not be in completedTodoTaskList",);
      Get.delete<TodoTaskController>();
    });

    test('Insert New Item', () async {
      final todoController = Get.put(TodoTaskController(null));
      todoController.title = "Second Title";
      todoController.description = "Test Description";
      todoController.deadline = DateTime.now();
      TodoTask newTask = todoController.todoTask;
      final controller = Get.find<TodoTaskListController>();
      await controller.insertTodoTask(0, newTask);
      expect(
          controller.inProgressTodoTaskList.any((todo) => todo.isSame(newTask)),
          isTrue, reason: "newTask must be in inProgressTodoTaskList");
      //index check (0)
      expect(controller.inProgressTodoTaskList[0].id, newTask.id,
          reason: "newTask.id must be first item in inProgressTodoTaskList");
      Get.delete<TodoTaskController>();
    });

    test('Insert Multiple TodoTask', ()async{
      for (var i = 2; i < 32; i++) {
        final todoController = Get.put(TodoTaskController(null));
        todoController.title = "Test Title $i";
        todoController.description = "Test Description $i";
        todoController.deadline = DateTime.now();
        TodoTask newTask = todoController.todoTask;
        final controller = Get.find<TodoTaskListController>();
        await controller.insertTodoTask(0, newTask);
        expect(listContains(controller.inProgressTodoTaskList, newTask),isTrue,
            reason: "newTask must be in inProgressTodoTaskList");
        //index check (0)
        expect(controller.inProgressTodoTaskList[0].id, newTask.id,
            reason: "newTask.id must be first item in inProgressTodoTaskList");
        Get.delete<TodoTaskController>();
      }
    });

    test('Toggle TodoTask Status', ()async{
      final controller = Get.find<TodoTaskListController>();
      //index가 odd인 TodoTask를 complete 처리하여 completedTodoTaskList로 이동
      for (var i = 1; i < controller.inProgressTodoTaskList.length; i+=2) {
        var todoTask = controller.inProgressTodoTaskList[i];
        await controller.toggleTodoTaskStatus(todoTask);
        expect(listContains(controller.inProgressTodoTaskList, todoTask), isFalse,
            reason: "todoTask must not be in inProgressTodoTaskList");
        expect(todoTask, isNotNull,
            reason: "todoTask must not be null");
        expect(todoTask.status, TodoTaskStatus.completed,
            reason: "todoTask.status must be completed");
        expect(todoTask.completedAt, isNotNull,
            reason: "todoTask.completedAt must not be null");
        expect(listContains(controller.inProgressTodoTaskList, todoTask), isFalse,
            reason: "todoTask must not be in inProgressTodoTaskList");
        expect(listContains(controller.completedTodoTaskList, todoTask), isTrue,
            reason: "todoTask must be in completedTodoTaskList");
      }
    });

    test('Reorder TodoTask',()async{
      final controller = Get.find<TodoTaskListController>();
      reorderTest(list,index,{
        oppositeIndex = true,
      })async{
        var todoTask = list[index];
        var prevTask = controller.findTodoTaskById(todoTask.prevId);
        var nextTask = controller.findTodoTaskById(todoTask.nextId);
        var targetIndex = oppositeIndex ? (list.length - 1) - index : index;
        await controller.reorderTodoTask(todoTask, targetIndex);
        expect(list[targetIndex].id, todoTask.id, reason: "list[$targetIndex].id must be todoTask.id");
        if (index == targetIndex){
          return;
        }
        //빠진 자리에 앞뒤로 연결된 TodoTask의 prevId, nextId가 제대로 설정되었는지 확인
        prevTask = controller.findTodoTaskById(prevTask?.id);
        nextTask = controller.findTodoTaskById(nextTask?.id);

        if (prevTask != null) {
          expect(prevTask.nextId, nextTask?.id, reason: "prevTask.nextId must be nextTask?.id");
        }
        if (nextTask != null) {
          expect(nextTask.prevId, prevTask?.id, reason: "nextTask.prevId must be prevTask?.id");
        }
      }
      upDownReorder(list)async{
        var halfLength = list.length~/2;
        //down reorder
        for (var i = 0; i < halfLength; i++) {
          await reorderTest(list, i);
        }
        //up reorder
        for (var i = list.length-1 ; i >= halfLength; i--) {
          await reorderTest(list, i);
        }
        //stay reorder
        for (var i= 0; i < list.length; i++){
          await reorderTest(list, i,oppositeIndex: false);
        }
      }
      await upDownReorder(controller.inProgressTodoTaskList);
      await upDownReorder(controller.completedTodoTaskList);
    });

    test('Update TodoTask',()async{
      final controller = Get.find<TodoTaskListController>();
      updateTest(List<TodoTask>list,int index)async{
        TodoTask todoTask = list[index];
        final todoController = Get.put(TodoTaskController(todoTask));
        todoController.title = "Updated Title $index";
        todoController.description = "Updated Description $index";
        todoController.deadline = DateTime.now();
        if (todoController.todoTask.status == TodoTaskStatus.completed){
          todoController.completedAt = DateTime.now();
        }
        var newTodoTask = todoController.todoTask;
        newTodoTask = await controller.updateTodoTask(newTodoTask);
        if (newTodoTask.status == TodoTaskStatus.completed){
          expect(listContains(controller.inProgressTodoTaskList, newTodoTask), isFalse,
              reason: "newTodoTask must not be in inProgressTodoTaskList");
          expect(listContains(controller.completedTodoTaskList, newTodoTask), isTrue,
              reason: "newTodoTask must be in completedTodoTaskList");
        }
        expect(list[index].id, newTodoTask.id,
            reason: "list[$index].id must be newTodoTask.id");
        expect(list[index].title, newTodoTask.title,
            reason: "list[$index].title must be newTodoTask.title");
        expect(list[index].description, newTodoTask.description,
            reason: "list[$index].description must be newTodoTask.description");
        expect(list[index].deadline, newTodoTask.deadline,
            reason: "list[$index].deadline must be newTodoTask.deadline");
        Get.delete<TodoTaskController>();
      }
      updateAllItem(list)async{
        for (var i = 0; i < list.length; i++) {
          await updateTest(list, i);
        }
      }
      await updateAllItem(controller.inProgressTodoTaskList);
      await updateAllItem(controller.completedTodoTaskList);
    });

    test('Remove TodoTask', ()async{
      final controller = Get.find<TodoTaskListController>();
      removeAllItem(list)async{
        for (var i = 0; i < list.length; i++) {
          var todoTask = list[i];
          await controller.removeTodoTask(todoTask);
          expect(listContains(list, todoTask), isFalse,
              reason: "todoTask must not be in inProgressTodoTaskList");
          expect(listContains(list, todoTask), isFalse,
              reason: "todoTask must not be in completedTodoTaskList");
        }
      }
      await removeAllItem(controller.inProgressTodoTaskList);
      await removeAllItem(controller.completedTodoTaskList);
    });
  });

  tearDownAll(() async {
    await DatabaseService.closeDatabase();
  });
}
