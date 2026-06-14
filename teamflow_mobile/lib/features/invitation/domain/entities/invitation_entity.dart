import 'package:freezed_annotation/freezed_annotation.dart';

part 'invitation_entity.freezed.dart';

@freezed
abstract class InvitationEntity with _$InvitationEntity {
  const factory InvitationEntity({
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
    required TeamEntity team,
  }) = _InvitationEntity;
}

@freezed
abstract class TeamEntity with _$TeamEntity {
  const factory TeamEntity({
    required String id,
    required String name,
    String? avatar,
  }) = _TeamEntity;
}