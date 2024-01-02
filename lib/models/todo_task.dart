class TodoTask {
  int? id;
  String title;
  String? description;
  DateTime? completedAt;
  int? prevId;
  int? nextId;
  final DateTime? createdAt;
  final DateTime? deadline;
  final DateTime? recentlyUpdatedAt;

  TodoTask({
    this.id,
    required this.title,
    this.description,
    this.completedAt,
    DateTime? createdAt,
    this.prevId,
    this.nextId,
    this.deadline,
    this.recentlyUpdatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  TodoTaskStatus get status => completedAt == null ? TodoTaskStatus.inProgress : TodoTaskStatus.completed;

  bool get isCompleted => completedAt != null;
  //convert Map<String, dynamic> for sqflite database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed_at': completedAt?.millisecondsSinceEpoch,
      'prev_id': prevId,
      'next_id': nextId,
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
      completedAt: map['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'])
          : null,
      prevId: map['prev_id'],
      nextId: map['next_id'],
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

  TodoTask copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? completedAt,
    int? prevId,
    int? nextId,
    DateTime? createdAt,
    DateTime? deadline,
    DateTime? recentlyUpdatedAt,
  }) {
    return TodoTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completedAt: completedAt ?? this.completedAt,
      prevId: prevId ?? this.prevId,
      nextId: nextId ?? this.nextId,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      recentlyUpdatedAt: recentlyUpdatedAt ?? this.recentlyUpdatedAt,
    );
  }

  @override
  String toString() {
    return 'TodoTask{id: $id, title: $title, description: $description, completedAt: $completedAt, prevId: $prevId, nextId: $nextId createdAt: $createdAt, deadline: $deadline, recentlyUpdatedAt: $recentlyUpdatedAt}';
  }

  bool isSame(TodoTask other) {
    return id == other.id &&
        title == other.title &&
        description == other.description &&
        completedAt == other.completedAt &&
        prevId == other.prevId &&
        nextId == other.nextId &&
        createdAt == other.createdAt &&
        deadline == other.deadline &&
        recentlyUpdatedAt == other.recentlyUpdatedAt;
  }
}

enum TodoTaskStatus {
  inProgress,
  completed;

  String label() {
    switch (this) {
      case TodoTaskStatus.inProgress:
        return 'In Progress';
      case TodoTaskStatus.completed:
        return 'Completed';
    }
  }
}