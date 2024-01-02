import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/pages/edit_todo_page.dart';
import 'package:todo_list/services/database_service.dart';

void main() {
  setUpAll(() async{
    WidgetsFlutterBinding.ensureInitialized();
    databaseFactory = databaseFactoryFfi;
    DatabaseService.isTest = true;
    await DatabaseService.initDatabase(databaseName: 'widget_test.db');
  });
  testWidgets('Navigate to EditTodoPage on FAB tap', (WidgetTester tester) async {
    // Initialize the app
    await tester.pumpWidget(const TodoApp());

    // Find the FloatingActionButton
    final fabFinder = find.byType(FloatingActionButton);

    // Tap the FloatingActionButton
    await tester.tap(fabFinder);

    // Rebuild the widget after the state has changed.
    await tester.pumpAndSettle();

    // Check if EditTodoPage is present
    expect(find.byType(EditTodoPage), findsOneWidget);
  });
  tearDownAll(() async {
    print("tearDown (widget_test.dart)");
    await DatabaseService.closeDatabase();
  });
}