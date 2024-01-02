import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list/models/todo_task.dart';

class DatabaseService {
  static bool _isTest = false;

  static set isTest(bool value) => _isTest = value;

  static Database? _database;

  static String _databaseName = _isTest ? 'test_todo.db' : 'todo.db';

  static String get databaseName => _databaseName;

  static const int _databaseVersion = 1;
  static const String _tableName = 'todo_task';

  static Future<Database?> initDatabase({String? databaseName}) async {
    print(DatabaseService.databaseName);
    // deleteDatabase(_databaseName);
    if (databaseName != null) _databaseName = databaseName;
    //open database
    _database ??= await openDatabase(
      _databaseName,
      version: _databaseVersion,
      onCreate: (db, version) async {
        debugPrint("Database created, name: $_databaseName");
        _databaseName = _databaseName;
        //create todos table
        await _createTodoTaskTable(db);
      },
    );
    debugPrint("Database initialized successfully, name: $_databaseName");
    return _database;
  }

  //close database
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      if (_isTest) {
        deleteDatabase(_databaseName);
      }
    }
  }

  static Future<void> _createTodoTaskTable(Database db) async {
    await db.execute('CREATE TABLE $_tableName('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'title TEXT,'
        'description TEXT,'
        'deadline INTEGER,'
        'prev_id INTEGER,'
        'next_id INTEGER,'
        'completed_at INTEGER,'
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

  Future<List<TodoTask>> getAllTodoTask() async {
    final db = await database;

    //get all data from todos table
    String query = 'SELECT * FROM $_tableName';
    final List<Map<String, dynamic>> results = await db.rawQuery(query);
    return results.map((map) => TodoTask.fromMap(map)).toList();
  }

  Future<void> _updatePrevId(Transaction txn, int id, int? prevId) async {
    await txn.update(
      _tableName,
      {'prev_id': prevId},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> _updateNextId(Transaction txn, int id, int? nextId) async {
    await txn.update(
      _tableName,
      {'next_id': nextId},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> _connectTask(Transaction txn, int? prevId, int? nextId) async {
    if (prevId != null) await _updateNextId(txn, prevId, nextId);
    if (nextId != null) await _updatePrevId(txn, nextId, prevId);
  }

  //맨 앞에 있는 즉, prev_id가 null인 TodoTask의 id를 가져옴
  Future<void> insertTodoTask(TodoTask todoTask) async {
    final db = await database;

    //To maintain consistency, use transaction
    await db.transaction((txn) async {
      final data = todoTask.toMap();
      var id = await txn.insert(_tableName, data);
      todoTask.id = id;
      await _connectTask(txn, todoTask.prevId, todoTask.id);
      await _connectTask(txn, todoTask.id, todoTask.nextId);
    });
  }

  Future<void> deleteTodoTask(TodoTask todoTask) async {
    final db = await database;

    //To maintain consistency, use transaction
    await db.transaction((txn) async {
      await txn.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [todoTask.id],
      );
      await _connectTask(txn, todoTask.prevId, todoTask.nextId);
    });
  }

  Future<void> reorderTodoTask(
    int targetTodoTaskId,
    int? oldPrevTodoTaskId,
    int? oldNextTodoTaskId,
    int? newPrevTodoTaskId,
    int? newNextTodoTaskId,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      // old Prev, Next TodoTask의 prev_id, next_id를 서로 연결
      await _connectTask(txn, oldPrevTodoTaskId, oldNextTodoTaskId);
      await _connectTask(txn, newPrevTodoTaskId, targetTodoTaskId);
      await _connectTask(txn, targetTodoTaskId, newNextTodoTaskId);
    });
  }

  Future<void> updateTodoTask(TodoTask todoTask) async {
    final db = await database;
    await db.update(
      _tableName,
      todoTask.toMap(),
      where: 'id = ?',
      whereArgs: [todoTask.id],
    );
  }
}
