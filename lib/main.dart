import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list/controller/todo_tab_controller.dart';
import 'package:todo_list/localization/localization.dart';
import 'package:todo_list/pages/home_page.dart';
import 'package:todo_list/services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize DatabaseService
  await DatabaseService.initDatabase();
  // Using GetMaterialApp for State Management
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(TodoTabController());
    return GetMaterialApp(
      title: 'Todo App',
      locale: Get.deviceLocale,
      translations: Localization(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      ),
      home: const HomePage(),
      // getPages: appRoutes,
    );
  }
}
