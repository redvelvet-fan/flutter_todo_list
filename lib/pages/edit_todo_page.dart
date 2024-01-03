import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list/components/date_input_field.dart';
import 'package:todo_list/components/title_text_field.dart';
import 'package:todo_list/controller/todo_task_controller.dart';
import 'package:todo_list/controller/todo_task_list_controller.dart';
import 'package:todo_list/localization/localization_keys.dart';
import 'package:todo_list/models/todo_task.dart';
import 'package:todo_list/utils/default_values.dart';

//Create or Edit TodoPage
class EditTodoPage extends GetView<TodoTaskListController> {
  const EditTodoPage({Key? key, this.defaultTodoTask}) : super(key: key);

  final TodoTask? defaultTodoTask;

  @override
  Widget build(BuildContext context) {
    final existTodoTask = defaultTodoTask != null;
    final TodoTaskController todoTaskController =
        Get.put(TodoTaskController(defaultTodoTask));

    onChangedTitle(String value) {
      todoTaskController.title = value;
    }

    onChangedDescription(String value) {
      todoTaskController.description = value;
    }

    onTapSave() {
      //check title is not empty
      if (todoTaskController.title.isEmpty) {
        Get.snackbar(LocalizationKeys.error.tr, LocalizationKeys.titleEmpty.tr,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      if (!existTodoTask) {
        TodoTask todoTask = TodoTask(
          title: todoTaskController.title,
          description: todoTaskController.description,
          deadline: todoTaskController.deadline,
        );
        debugPrint(todoTask.toString());
        //add todoTask to TodoTaskListController
        controller.insertTodoTask(0, todoTask);
      } else {
        controller.updateTodoTask(todoTaskController.todoTask);
      }
      //go back to HomePage
      Get.back();
    }

    Future<bool?> showConfirmDialog() async {
      return await Get.dialog<bool?>(
        SimpleDialog(
          title: Text(LocalizationKeys.confirmDelete.tr),
          titlePadding: const EdgeInsets.all(24),
          titleTextStyle: const TextStyle(
            fontSize: DefaultValues.fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
          contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      Get.back(result: true);
                    },
                    child: Text(
                      LocalizationKeys.delete.tr,
                      style: const TextStyle(color: Colors.redAccent),
                    )),
                TextButton(
                  onPressed: () {
                    Get.back(result: false);
                  },
                  child: Text(LocalizationKeys.cancel.tr),
                ),
              ],
            )
          ],
        ),
      );
    }

    onTapDelete() async {
      //find original todoTask object by id
      TodoTask? originalTodoTask =
          controller.findTodoTaskById(todoTaskController.id);
      if (originalTodoTask == null) {
        Get.snackbar(
            LocalizationKeys.error.tr, LocalizationKeys.notFoundTodo.tr,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      //show confirm dialog
      bool? confirm = await showConfirmDialog();
      if (confirm == null || !confirm) {
        return;
      }
      await controller.removeTodoTask(originalTodoTask);
      Get.back();
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(LocalizationKeys.editTodo.tr),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      //Title
                      TitleTextField(
                        title: LocalizationKeys.title.tr,
                        hintText: LocalizationKeys.titleHint.tr,
                        controller: todoTaskController.titleController,
                        onChanged: onChangedTitle,
                      ),
                      //Description it can be optional
                      //and can have multiple lines
                      TitleTextField(
                        title: LocalizationKeys.description.tr,
                        hintText: LocalizationKeys.descriptionHint.tr,
                        controller: todoTaskController.descriptionController,
                        onChanged: onChangedDescription,
                        maxLines: null,
                      ),
                      Obx(
                        () => DateInputField(
                          title: LocalizationKeys.deadline.tr,
                          value: todoTaskController.deadline,
                          onChanged: (value) {
                            todoTaskController.deadline = value;
                          },
                        ),
                      ),
                      if (todoTaskController.isCompleted)
                        Obx(
                          () => DateInputField(
                            title: LocalizationKeys.completedAt.tr,
                            value: todoTaskController.completedAt,
                            onChanged: (value) {
                              todoTaskController.completedAt = value;
                            },
                          ),
                        ),
                    ].fold([], (previousValue, element) {
                      //add SizedBox between elements
                      if (previousValue.isNotEmpty) {
                        previousValue.add(
                            const SizedBox(height: DefaultValues.middleGap));
                      }
                      previousValue.add(element);
                      return previousValue;
                    }),
                  )),
            ),
            //Save Button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  if (existTodoTask) ...[
                    Expanded(
                      child: ElevatedButton(
                        //Delete Button
                        onPressed: onTapDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text(
                          LocalizationKeys.delete.tr,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    )
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onTapSave,
                      child: Text(LocalizationKeys.save.tr),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
