import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list/models/todo_task.dart';

class DatabaseService {
  static Database? _database;

  Future<void> initDatabase({Future<void> Function()? onLoaded}) async {
    //open database
    if (!isInitialized) {
      _database = await openDatabase(
        'todo.db',
        version: 1,
        onOpen: (db) async {
          debugPrint("Database opened");
          //check is database has todos table
          final hasTable = await db.rawQuery(
              'SELECT name FROM sqlite_master WHERE type="table" AND name="todo_task"');
          if (hasTable.isNotEmpty) {
            return;
          }
          //if db dose not has todos table, create todos table
          await db.execute('CREATE TABLE todo_task('
              'id INTEGER PRIMARY KEY AUTOINCREMENT,'
              'title TEXT,'
              'description TEXT,'
              'deadline INTEGER,'
              'is_done INTEGER,'
              'order_index INTEGER,'
              'created_at INTEGER,'
              'recently_updated_at INTEGER'
              ')');
        },
      );
    }
    debugPrint("Database initialized");
    onLoaded?.call();
  }

  //check is database is initialized
  bool get isInitialized => _database != null;

  Future<Database> get database async {
    if (!isInitialized) {
      await initDatabase();
    }
    return _database!;
  }

  Future<List<TodoTask>> getAllTodoTask({
    bool? isDone,
  }) async {
    final db = await database;

    //get all data from todos table
    //order by order_index
    final maps = await db.query('todo_task',
        orderBy: 'order_index DESC',
        where: isDone == null ? null : 'is_done = ${isDone ? 1 : 0}');

    return List.generate(maps.length, (i) {
      return TodoTask.fromMap(maps[i]);
    });
  }

  Future<int> getTodoTaskCount({bool? isDone}) async {
    final db = await database;
    String queryText = 'SELECT COUNT(*) FROM todo_task';
    queryText = isDone == null
        ? queryText
        : '$queryText WHERE is_done = ${isDone ? 1 : 0}';
    final data = await db.rawQuery(queryText);

    return data[0]['COUNT(*)'] as int;
  }

  Future<void> insertTodoTask(TodoTask todoTask) async {
    final db = await database;

    //set index to last index
    todoTask.orderIndex = await getTodoTaskCount(isDone: false);

    final data = todoTask.toMap();

    await db.insert('todo_task', data);
  }

  Future<void> deleteTodoTask(TodoTask todoTask) async {
    final db = await database;

    await db.delete(
      'todo_task',
      where: 'id = ?',
      whereArgs: [todoTask.id],
    );
  }
}
