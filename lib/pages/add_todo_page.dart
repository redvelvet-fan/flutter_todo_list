import 'package:flutter/material.dart' hide DateUtils;
import 'package:get/get.dart';
import 'package:todo_list/controller/todo_task_controller.dart';
import 'package:todo_list/models/todo_task.dart';
import 'package:todo_list/utils/date_utils.dart';

//Create a New TodoTask
class AddTodoPage extends GetView<TodoTaskController> {
  const AddTodoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleObserver = ''.obs;
    final descriptionObserver = ''.obs;
    final deadlineObserver = Rx<DateTime?>(null);
    final completedAtObserver = Rx<DateTime?>(null);
    final isCompletedObserver = false.obs
      ..listen((p0) {
        print('isCompletedObserver : $p0');
        completedAtObserver.value = p0 ? DateTime.now() : null;
      });

    Future<DateTime?> selectDate() async {
      DateTime today = DateTime.now();
      DateTime? selectedTime = await showDatePicker(
        context: context,
        firstDate: today.subtract(const Duration(days: 365 * 18)),
        lastDate: DateTime(today.year + 36),
        initialDate: today,
      );

      return selectedTime;
    }

    Future<DateTime?> selectTime(DateTime selectedDate) async {
      DateTime now = DateTime.now();
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
      );

      if (selectedTime != null) {
        return DateTime(now.year, now.month, now.day, selectedTime.hour,
            selectedTime.minute);
      }

      return null;
    }

    Future<DateTime?> selectDeadline() async {
      DateTime? selectedDate = await selectDate();
      if (selectedDate != null) {
        DateTime? selectedTime = await selectTime(selectedDate);
        if (selectedTime != null) {
          DateTime selectedDeadline = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute);
          return selectedDeadline;
        }
      }
      return null;
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Add Todo'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
                child: Column(
              children: [
                //Title
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      titleObserver.value = value;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Title',
                    ),
                  ),
                ),
                //Description it can be optional
                //and can have multiple lines
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      descriptionObserver.value = value;
                    },
                    maxLines: null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Description',
                    ),
                  ),
                ),
                Row(
                  children: [
                    //show selected deadline date yyyy.MM.dd am/pm hh:mm
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Obx(() => Text(
                              deadlineObserver.value != null
                                  ? DateUtils.getFormattedDate(
                                      deadlineObserver.value!)
                                  : 'No Deadline',
                              style: const TextStyle(fontSize: 20),
                            )),
                      ),
                    ),
                    //Deadline setting button
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          DateTime? selectedDeadline = await selectDeadline();
                          if (selectedDeadline != null) {
                            deadlineObserver.value = selectedDeadline;
                          }
                        },
                        child: const Text('Set Deadline'),
                      ),
                    ),
                  ],
                ),
                //Completed
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Obx(() => CheckboxListTile(
                        title: const Text('Completed'),
                        value: isCompletedObserver.value,
                        onChanged: (value) {
                          isCompletedObserver.value = value!;
                        },
                      )),
                ),
                Obx(
                  () => isCompletedObserver.value
                      ? Row(
                        children: [
                          Expanded(
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Obx(() => Text(
                                      completedAtObserver.value != null
                                          ? DateUtils.getFormattedDate(
                                              completedAtObserver.value!)
                                          : 'No Completed Date',
                                      style: const TextStyle(fontSize: 20),
                                    )),
                              ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                DateTime? selectedCompletedAt =
                                    await selectDeadline();
                                if (selectedCompletedAt != null) {
                                  completedAtObserver.value =
                                      selectedCompletedAt;
                                }
                              },
                              child: const Text('Set Completed Date'),
                            ),
                          ),
                        ],
                      )
                      : const SizedBox(),
                )
              ],
            )),
          ),
          //Save Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                //check title is not empty
                if (titleObserver.value.isEmpty) {
                  Get.snackbar('Error', 'Title is empty',
                      snackPosition: SnackPosition.BOTTOM);
                  return;
                }
                TodoTask todoTask = TodoTask(
                  title: titleObserver.value,
                  description: descriptionObserver.value,
                  deadline: deadlineObserver.value,
                  completedAt: completedAtObserver.value,
                );
                debugPrint(todoTask.toString());
                //add todoTask to TodoTaskListController
                Get.find<TodoTaskController>().insertTodoTask(0,todoTask);
                //go back to HomePage
                Get.back();
              },
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
