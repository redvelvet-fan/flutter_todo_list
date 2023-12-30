import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list/models/todo_task.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'todo.db';
  static const int _databaseVersion = 1;
  static const String _tableName = 'todo_task';

  static Future<void> initDatabase({
    Future<void> Function()? onLoaded,
  }) async {
    //open database
    _database ??= await openDatabase(
      _databaseName,
      version: _databaseVersion,
      onCreate: (db, version) async {
        debugPrint("Database created");
        //create todos table
        await _createTodoTaskTable(db);
      },
    );
    debugPrint("Database initialized");
    onLoaded?.call();
  }

  static Future<void> _createTodoTaskTable(Database db) async {
    await db.execute('CREATE TABLE todo_task('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'title TEXT,'
        'description TEXT,'
        'deadline INTEGER,'
        'completed_at INTEGER,'
        'order_index INTEGER,'
        'created_at INTEGER,'
        'recently_updated_at INTEGER'
        ')');
  }

  //check is database is initialized
  bool get isInitialized => _database != null;

  Future<Database> get database async {
    if (!isInitialized) {
      throw Exception(
          'Database is not initialized, please call initDatabase()');
    }
    return _database!;
  }

  Future<List<TodoTask>> getAllTodoTask({
    bool? isCompleted,
  }) async {
    final db = await database;

    //get all data from todos table
    //order by order_index
    final maps = await db.query('todo_task',
        orderBy: 'order_index DESC',
        where: isCompleted == null ? null : 'completed_at = ${isCompleted ? 1 : 0}');

    return List.generate(maps.length, (i) {
      print(maps[i]);
      return TodoTask.fromMap(maps[i]);
    });
  }

  Future<int> generateNextOrderIndex(bool isCompleted) async {
    final db = await database;
    final data = await db.query(_tableName,
      columns: ['MAX(order_index) as max_order_index'],
      where: isCompleted ? 'completed_at IS NOT NULL' : 'completed_at IS NULL'
    );
    var result = data[0]['max_order_index'];

    return result == null ? 0 : (result as int) + 1;
  }

  Future<int> insertTodoTask(TodoTask todoTask) async {
    final db = await database;

    //set index to last index
    todoTask.orderIndex = await generateNextOrderIndex(false);

    final data = todoTask.toMap();

    return await db.insert('todo_task', data);
  }

  Future<int> deleteTodoTask(TodoTask todoTask) async {
    final db = await database;

    return await db.delete(
      'todo_task',
      where: 'id = ?',
      whereArgs: [todoTask.id],
    );
  }

  Future<void> switchOrderIndex(TodoTask oldTodoTask, TodoTask newTodoTask) async {
    final db = await database;
    final batch = db.batch();

    batch.update(
      'todo_task',
      {'order_index': newTodoTask.orderIndex},
      where: 'id = ?',
      whereArgs: [oldTodoTask.id],
    );

    batch.update(
      'todo_task',
      {'order_index': oldTodoTask.orderIndex},
      where: 'id = ?',
      whereArgs: [newTodoTask.id],
    );

    await batch.commit(noResult: true);
  }
}
