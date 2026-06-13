import 'package:freezed_annotation/freezed_annotation.dart';

part 'membership_entity.freezed.dart';

@freezed
abstract class MembershipEntity with _$MembershipEntity {
  const factory MembershipEntity({
    required String role,
    required MembershipTeamEntity team,
  }) = _MembershipEntity;
}

@freezed
abstract class MembershipTeamEntity with _$MembershipTeamEntity {
  const factory MembershipTeamEntity({
    required String id,
    required String name,
    String? avatar,
  }) = _MembershipTeamEntity;
}