import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list/models/todo_task.dart';
import 'package:todo_list/services/database_service.dart';

class TodoTaskListController extends GetxController {
  final RxList<TodoTask> inProgressTodoTaskList = RxList<TodoTask>([]);
  final RxList<TodoTask> completedTodoTaskList = RxList<TodoTask>([]);
  final _isOnProgress = false.obs;
  final _isLoaded = false.obs;

  //define database service for sync with database
  final DatabaseService _databaseService = DatabaseService();

  @override
  void onInit() {
    super.onInit();
    _initTodoTaskList();
  }

  bool get isOnProgress => _isOnProgress.value;
  bool get isLoaded => _isLoaded.value;

  _initTodoTaskList() {
    //sync with database
    _databaseService.getAllTodoTask().then((value) {
      _splitTodoTaskList(value);
      _isLoaded.value = true;
    });
  }

  _splitTodoTaskList(List<TodoTask> todoTaskList) {
    final newInProgressTodoTaskList = <TodoTask>[];
    final newCompletedTodoTaskList = <TodoTask>[];

    for (var todoTask in todoTaskList) {
      if (todoTask.completedAt == null) {
        newInProgressTodoTaskList.add(todoTask);
      } else {
        newCompletedTodoTaskList.add(todoTask);
      }
    }
    completedTodoTaskList.value = _sortLinkedList(newCompletedTodoTaskList);
    inProgressTodoTaskList.value = _sortLinkedList(newInProgressTodoTaskList);
  }

  List<TodoTask> _sortLinkedList(List<TodoTask> unsortedList) {
    //prev, next를 이용하여 todoTaskList 정렬
    //prev == null인 todoTask를 찾는다.
    TodoTask? firstTodoTask =
        unsortedList.firstWhereOrNull((todoTask) => todoTask.prevId == null);
    if (firstTodoTask == null) {
      return unsortedList;
    }
    for (var todoTask in unsortedList) {
      print(
          '${todoTask.title} : ${todoTask.prevId} -> ${todoTask.id} -> ${todoTask.nextId}');
    }
    return _findAndInsertNextTodoTask(firstTodoTask, unsortedList);
  }

  List<TodoTask> _findAndInsertNextTodoTask(
      TodoTask todoTask, List<TodoTask> unsortedList) {
    //todoTask의 nextId를 이용하여 다음 todoTask를 찾는다.
    //nextId == null이면 정렬이 완료된 것이므로 unsortedList를 반환한다.
    if (todoTask.nextId == null) {
      return unsortedList;
    } else {
      print('nextId: ${todoTask.nextId}');
      TodoTask nextTodoTask =
          unsortedList.firstWhere((td) => td.id == todoTask.nextId);
      unsortedList
        ..remove(nextTodoTask)
        ..add(nextTodoTask);
      return _findAndInsertNextTodoTask(nextTodoTask, unsortedList);
    }
  }

  // Rule: 상태 변경 후, DB와 동기화

  // get list which target includes
  RxList<TodoTask> getTaskIncludeList(TodoTask target) {
    return target.completedAt != null
        ? completedTodoTaskList
        : inProgressTodoTaskList;
  }
  int getTaskIndexById(int targetId) {
    //using indexWhere
    var index = inProgressTodoTaskList.indexWhere((todoTask) => todoTask.id == targetId);
    if (index != -1) {
      return index;
    }
    index = completedTodoTaskList.indexWhere((todoTask) => todoTask.id == targetId);
    if (index != -1) {
      return index;
    }
    return -1;
  }
  TodoTask? findTodoTaskByIndex(List<TodoTask> list, int index) {
    try {
      return list.elementAtOrNull(index);
    } catch (e) {
      if (e is RangeError) {
        return null;
      }
      rethrow;
    }
  }

  TodoTask? findTodoTaskById(int? id) {
    if (id == null) {
      return null;
    }
    var todoTask = inProgressTodoTaskList.firstWhereOrNull((todoTask) => todoTask.id == id);
    todoTask ??= completedTodoTaskList.firstWhereOrNull((todoTask) => todoTask.id == id);
    return todoTask;
  }

  Future<T> _progressWrapper<T>(Future<T> Function() func, {T? errorReturn}) async {
    if (_isOnProgress.value) {
      return errorReturn as T;
    }
    _isOnProgress.value = true;
    try {
      await func();
    } catch (e, s) {
      debugPrintStack(label: e.toString(), stackTrace: s);
      // rollback 등의 처리
      _initTodoTaskList();
      return errorReturn as T;
    } finally {
      _isOnProgress.value = false;
    }
    return errorReturn as T;
  }

  List<TodoTask?> _insertTodoTaskInState(
    int index,
    TodoTask todoTask,
  ) {
    var targetList = getTaskIncludeList(todoTask);

    //삽입될 index를 기준으로 prev, next TodoTask를 찾는다.
    //삽입될 TodoTask의 앞에 있는 prevTodoTask
    var prevTodoTask = findTodoTaskByIndex(targetList, index - 1);
    //삽입될 TodoTask의 뒤에 있는 nextTodoTask
    var nextTodoTask = findTodoTaskByIndex(targetList, index);

    todoTask.prevId = prevTodoTask?.id;
    todoTask.nextId = nextTodoTask?.id;
    prevTodoTask?.nextId = todoTask.id;
    nextTodoTask?.prevId = todoTask.id;
    targetList.insert(index, todoTask);
    return [prevTodoTask, todoTask, nextTodoTask];
  }

  Future<void> insertTodoTask(
    int index,
    TodoTask todoTask,
  ) async {
    return await _progressWrapper(() async {
      var [prev, todo!, next] = _insertTodoTaskInState(index, todoTask);

      //in method, todoTask.id is updated
      await _databaseService.insertTodoTask(todo);

      next?.prevId = todoTask.id;
      prev?.nextId = todoTask.id;
    });
  }

  TodoTask _removeTodoTaskInState(TodoTask todoTask) {
    var targetTodoTaskList = getTaskIncludeList(todoTask);

    var todoTaskIndex = targetTodoTaskList.indexOf(todoTask);

    //todoTask의 앞뒤 TodoTask를 찾는다.
    var prevTodoTask =
        findTodoTaskByIndex(targetTodoTaskList, todoTaskIndex - 1);
    var nextTodoTask =
        findTodoTaskByIndex(targetTodoTaskList, todoTaskIndex + 1);
    //todoTask의 앞뒤 TodoTask의 prevId, nextId를 수정
    prevTodoTask?.nextId = nextTodoTask?.id;
    nextTodoTask?.prevId = prevTodoTask?.id;

    //todoTask를 삭제
    targetTodoTaskList.remove(todoTask);
    return todoTask;
  }

  Future<TodoTask> removeTodoTask(TodoTask todoTask) async {
    return await _progressWrapper<TodoTask>(() async {
      var removedTodoTask = _removeTodoTaskInState(todoTask);
      await _databaseService.deleteTodoTask(todoTask);
      return removedTodoTask;
    }, errorReturn: todoTask);
  }

  Future<void> reorderTodoTask(
    TodoTask targetTodoTask,
    int newIndex,
  ) async {
    await _progressWrapper(()async{
      var oldPrevId = targetTodoTask.prevId;
      var oldNextId = targetTodoTask.nextId;
      var [prev, todo!, next] = _insertTodoTaskInState(
          newIndex, _removeTodoTaskInState(targetTodoTask));
      await _databaseService.reorderTodoTask(
          todo.id!, oldPrevId, oldNextId, prev?.id, next?.id);
    });
    return;
  }

  Future<void> toggleTodoTaskStatus(
      TodoTask todoTask,
      )async {
    return await _progressWrapper(() async{
      var result = _removeTodoTaskInState(todoTask);
      var oldPrevId = result.prevId;
      var oldNextId = result.nextId;
      result.completedAt = result.completedAt == null ? DateTime.now() : null;
      var [prev, todo!, next] = _insertTodoTaskInState(0, result);
      await _databaseService.reorderTodoTask(
          todo.id!, oldPrevId, oldNextId, prev?.id, next?.id);
      await _databaseService.updateTodoTask(result);
    });
  }

  Future<TodoTask> updateTodoTask(TodoTask todoTask) async {
    if (todoTask.id == null) {
      return todoTask;
    }
    return await _progressWrapper<TodoTask>(() async{
      //get list of todoTask included
      var targetList = getTaskIncludeList(todoTask);
      var index = getTaskIndexById(todoTask.id!);
      var updatedTodoTask = targetList[index].copyWith(
        title: todoTask.title,
        description: todoTask.description,
        deadline: todoTask.deadline,
        completedAt: todoTask.completedAt,
      );
      targetList[index] = updatedTodoTask;
      await _databaseService.updateTodoTask(updatedTodoTask);
      return updatedTodoTask;
    },errorReturn: todoTask);
  }
}
