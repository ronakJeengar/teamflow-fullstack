class ActivityUser {
  final String id;
  final String name;
  final String? avatar;

  ActivityUser({
    required this.id,
    required this.name,
    this.avatar,
  });

  factory ActivityUser.fromJson(Map<String, dynamic> json) {
    return ActivityUser(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
    );
  }
}

class ActivityModel {
  final String id;
  final String type;
  final String content;
  final String userId;
  final String? taskId;
  final String? projectId;
  final String createdAt;
  final ActivityUser user;

  ActivityModel({
    required this.id,
    required this.type,
    required this.content,
    required this.userId,
    this.taskId,
    this.projectId,
    required this.createdAt,
    required this.user,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      userId: json['userId'] as String,
      taskId: json['taskId'] as String?,
      projectId: json['projectId'] as String?,
      createdAt: json['createdAt'] as String,
      user: ActivityUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
