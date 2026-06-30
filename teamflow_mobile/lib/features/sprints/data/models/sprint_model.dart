import '../../../tasks/data/models/task_model.dart';

enum SprintStatus {
  PLANNED,
  ACTIVE,
  COMPLETED,
  CANCELLED,
}

class SprintModel {
  final String id;
  final String name;
  final String? goal;
  final DateTime startDate;
  final DateTime endDate;
  final SprintStatus status;
  final String projectId;
  final String createdById;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TaskModel>? tasks;

  SprintModel({
    required this.id,
    required this.name,
    this.goal,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.projectId,
    required this.createdById,
    required this.createdAt,
    required this.updatedAt,
    this.tasks,
  });

  factory SprintModel.fromJson(Map<String, dynamic> json) {
    SprintStatus parseStatus(String s) {
      switch (s) {
        case 'ACTIVE':
          return SprintStatus.ACTIVE;
        case 'COMPLETED':
          return SprintStatus.COMPLETED;
        case 'CANCELLED':
          return SprintStatus.CANCELLED;
        case 'PLANNED':
        default:
          return SprintStatus.PLANNED;
      }
    }

    return SprintModel(
      id: json['id'] as String,
      name: json['name'] as String,
      goal: json['goal'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: parseStatus(json['status'] as String),
      projectId: json['projectId'] as String,
      createdById: json['createdById'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tasks: json['tasks'] != null
          ? (json['tasks'] as List)
              .map((t) => TaskModel.fromJson(t as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    String statusStr(SprintStatus s) {
      switch (s) {
        case SprintStatus.ACTIVE:
          return 'ACTIVE';
        case SprintStatus.COMPLETED:
          return 'COMPLETED';
        case SprintStatus.CANCELLED:
          return 'CANCELLED';
        case SprintStatus.PLANNED:
        default:
          return 'PLANNED';
      }
    }

    return {
      'id': id,
      'name': name,
      'goal': goal,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': statusStr(status),
      'projectId': projectId,
      'createdById': createdById,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tasks': tasks?.map((t) => t.toJson()).toList(),
    };
  }
}

class SprintStatsModel {
  final int totalTasks;
  final int completed;
  final int remaining;
  final int completionPercentage;
  final int overdue;
  final int totalPoints;
  final int completedPoints;

  SprintStatsModel({
    required this.totalTasks,
    required this.completed,
    required this.remaining,
    required this.completionPercentage,
    required this.overdue,
    required this.totalPoints,
    required this.completedPoints,
  });

  factory SprintStatsModel.fromJson(Map<String, dynamic> json) {
    return SprintStatsModel(
      totalTasks: json['totalTasks'] as int,
      completed: (json['completedTasks'] ?? json['completed'] ?? 0) as int,
      remaining: (json['remainingTasks'] ?? json['remaining'] ?? 0) as int,
      completionPercentage: (json['completionPercent'] ?? json['completionPercentage'] ?? 0) as int,
      overdue: (json['overdueTasks'] ?? json['overdue'] ?? 0) as int,
      totalPoints: (json['totalPoints'] ?? 0) as int,
      completedPoints: (json['completedPoints'] ?? 0) as int,
    );
  }
}

class BurndownEntryModel {
  final String date;
  final num actual;
  final num ideal;

  BurndownEntryModel({
    required this.date,
    required this.actual,
    required this.ideal,
  });

  factory BurndownEntryModel.fromJson(Map<String, dynamic> json) {
    return BurndownEntryModel(
      date: json['date'] as String,
      actual: json['actual'] as num,
      ideal: json['ideal'] as num,
    );
  }
}

class VelocityHistoryEntry {
  final String sprintId;
  final String sprintName;
  final int completedPoints;

  VelocityHistoryEntry({
    required this.sprintId,
    required this.sprintName,
    required this.completedPoints,
  });

  factory VelocityHistoryEntry.fromJson(Map<String, dynamic> json) {
    return VelocityHistoryEntry(
      sprintId: json['sprintId'] as String,
      sprintName: json['sprintName'] as String,
      completedPoints: json['completedPoints'] as int,
    );
  }
}

class VelocityModel {
  final int averageVelocity;
  final List<VelocityHistoryEntry> history;

  VelocityModel({
    required this.averageVelocity,
    required this.history,
  });

  factory VelocityModel.fromJson(Map<String, dynamic> json) {
    return VelocityModel(
      averageVelocity: json['averageVelocity'] as int,
      history: (json['history'] as List)
          .map((h) => VelocityHistoryEntry.fromJson(h as Map<String, dynamic>))
          .toList(),
    );
  }
}
