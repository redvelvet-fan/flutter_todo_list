import 'package:get/get.dart';
import 'package:todo_list/controller/todo_task_controller.dart';
import 'package:todo_list/pages/add_todo_page.dart';
import 'package:todo_list/pages/home_page.dart';

final List<GetPage> appRoutes = [
  GetPage(
    name: '/',
    page: () => const HomePage(),
    binding: BindingsBuilder(() {
      Get.put(TodoTaskController());
    }),
  ),
  //Add Page
  GetPage(
    name: '/add',
    page: () => const AddTodoPage(),
    binding: BindingsBuilder(() {
      Get.put(TodoTaskController());
    }),
  ),
];