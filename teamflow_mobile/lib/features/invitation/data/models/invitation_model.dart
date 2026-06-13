import 'package:freezed_annotation/freezed_annotation.dart';

part 'invitation_model.freezed.dart';

part 'invitation_model.g.dart';

@freezed
abstract class InvitationModel with _$InvitationModel {
  const factory InvitationModel({
    required String id,
    required String teamId,
    required String email,
    required String invitedById,
    required String role,
    required String token,
    required String status,
    required DateTime expiresAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    required TeamInfo team,
  }) = _InvitationModel;

  factory InvitationModel.fromJson(Map<String, dynamic> json) =>
      _$InvitationModelFromJson(json);
}

@freezed
abstract class TeamInfo with _$TeamInfo {
  const factory TeamInfo({
    required String id,
    required String name,
    String? avatar,
  }) = _TeamInfo;

  factory TeamInfo.fromJson(Map<String, dynamic> json) =>
      _$TeamInfoFromJson(json);
}
