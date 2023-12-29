import 'package:flutter/material.dart' hide DateUtils;
import 'package:get/get.dart';
import 'package:todo_list/controller/todo_task_controller.dart';
import 'package:todo_list/models/todo_task.dart';
import 'package:todo_list/utils/date_utils.dart';

//Create a New TodoTask
class AddTodoPage extends StatelessWidget {
  const AddTodoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleObserver = ''.obs;
    final descriptionObserver = ''.obs;
    final deadlineObserver = Rx<DateTime?>(null);

    Future<DateTime?> selectDate() async {
      DateTime today = DateTime.now();
      DateTime? selectedTime = await showDatePicker(
        context: context,
        firstDate: today,
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
                      snackPosition: SnackPosition.BOTTOM );
                  return;
                }
                TodoTask todoTask = TodoTask(
                  title: titleObserver.value,
                  description: descriptionObserver.value,
                  deadline: deadlineObserver.value,
                );
                debugPrint(todoTask.toString());
                //add todoTask to TodoTaskListController
                Get.find<TodoTaskController>().addTodoTask(todoTask);
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
