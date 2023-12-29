class TodoTask {
  int? id;
  String title;
  String? description;
  bool isDone;
  int? orderIndex;
  final DateTime? createdAt;
  final DateTime? deadline;
  final DateTime? recentlyUpdatedAt;

  TodoTask({
    this.id,
    required this.title,
    this.description,
    this.isDone = false,
    DateTime? createdAt,
    this.orderIndex,
    this.deadline,
    this.recentlyUpdatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  //convert Map<String, dynamic> for sqflite database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_done': isDone ? 1 : 0,
      'order_index': orderIndex,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'deadline': deadline?.millisecondsSinceEpoch,
      'recently_updated_at': recentlyUpdatedAt?.millisecondsSinceEpoch,
    };
  }

  //convert TodoTask from sqflite database
  factory TodoTask.fromMap(Map<String, dynamic> map) {
    return TodoTask(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isDone: map['is_done'] == 1,
      orderIndex: map['order_index'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      //deadline can be null
      deadline: map['deadline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deadline'])
          : null,
      //recentlyUpdatedAt can be null
      recentlyUpdatedAt: map['recently_updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['recently_updated_at'])
          : null,
    );
  }

  @override
  String toString() {
    return 'TodoTask{id: $id, title: $title, description: $description, isDone: $isDone, orderIndex: $orderIndex, createdAt: $createdAt, deadline: $deadline, recentlyUpdatedAt: $recentlyUpdatedAt}';
  }
}