import 'package:freezed_annotation/freezed_annotation.dart';

part 'membership_model.freezed.dart';
part 'membership_model.g.dart';

@freezed
abstract class MembershipModel with _$MembershipModel {
  const factory MembershipModel({
    required String role,
    required MembershipTeamModel team,
  }) = _MembershipModel;

  factory MembershipModel.fromJson(Map<String, dynamic> json) =>
      _$MembershipModelFromJson(json);
}

@freezed
abstract class MembershipTeamModel with _$MembershipTeamModel {
  const factory MembershipTeamModel({
    required String id,
    required String name,
    String? avatar,
  }) = _MembershipTeamModel;

  factory MembershipTeamModel.fromJson(Map<String, dynamic> json) =>
      _$MembershipTeamModelFromJson(json);
}