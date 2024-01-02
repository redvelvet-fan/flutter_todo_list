import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list/models/todo_task.dart';

class TodoTaskController extends GetxController{
  final TodoTask? _todoTask;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  late final Rx<DateTime?> _deadline;
  late final Rx<DateTime?> _completedAt;

  TodoTaskController(this._todoTask){
    titleController.text = _todoTask?.title ?? '';
    descriptionController.text = _todoTask?.description ?? '';
    _deadline = Rx<DateTime?>(_todoTask?.deadline);
    _completedAt = Rx<DateTime?>(_todoTask?.completedAt);
  }

  TodoTask get todoTask {
    return _todoTask?.copyWith(
    title: title,
    description: description,
    deadline: deadline,
    completedAt: completedAt,
  ) ?? TodoTask(
    title: title,
    description: description,
    deadline: deadline,
    completedAt: completedAt,
  );
  }

  int? get id => _todoTask?.id;

  String get title => titleController.text;
  set title(String value) => titleController.text = value;

  String get description => descriptionController.text;
  set description(String value) => descriptionController.text = value;

  DateTime? get deadline => _deadline.value;
  set deadline(DateTime? value) => _deadline.value = value;

  DateTime? get completedAt => _completedAt.value;
  set completedAt(DateTime? value) => _completedAt.value = value;

  bool get isCompleted => completedAt != null;
}