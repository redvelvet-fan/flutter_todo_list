import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list/pages/home_page.dart';
import 'package:todo_list/services/database_service.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // Using GetMaterialApp for State Management
  await DatabaseService().database;
  runApp(const GetMaterialApp(home: TodoApp()));
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),

    );
  }
}