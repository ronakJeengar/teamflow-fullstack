import '../../../auth/data/models/user_model.dart';

class WorkspaceMemberModel {
  final String id;
  final String workspaceId;
  final String userId;
  final String role;
  final String createdAt;
  final UserModel? user;

  WorkspaceMemberModel({
    required this.id,
    required this.workspaceId,
    required this.userId,
    required this.role,
    required this.createdAt,
    this.user,
  });

  factory WorkspaceMemberModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceMemberModel(
      id: json['id'] as String? ?? '',
      workspaceId: json['workspaceId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      role: json['role'] as String? ?? 'MEMBER',
      createdAt: (json['joinedAt'] ?? json['createdAt'] ?? '') as String,
      user: json['user'] != null ? UserModel.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workspaceId': workspaceId,
      'userId': userId,
      'role': role,
      'createdAt': createdAt,
      'user': user?.toJson(),
    };
  }
}
