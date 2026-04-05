// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_invitation_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TeamInvitationEntity {

 String get id; String get teamId; String get email; TeamMemberRoleEntity get role; String get token; InvitationStatusEntity get status; String get invitedBy; String get expiresAt; String get createdAt; TeamEntity? get team;
/// Create a copy of TeamInvitationEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamInvitationEntityCopyWith<TeamInvitationEntity> get copyWith => _$TeamInvitationEntityCopyWithImpl<TeamInvitationEntity>(this as TeamInvitationEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamInvitationEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.token, token) || other.token == token)&&(identical(other.status, status) || other.status == status)&&(identical(other.invitedBy, invitedBy) || other.invitedBy == invitedBy)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.team, team) || other.team == team));
}


@override
int get hashCode => Object.hash(runtimeType,id,teamId,email,role,token,status,invitedBy,expiresAt,createdAt,team);

@override
String toString() {
  return 'TeamInvitationEntity(id: $id, teamId: $teamId, email: $email, role: $role, token: $token, status: $status, invitedBy: $invitedBy, expiresAt: $expiresAt, createdAt: $createdAt, team: $team)';
}


}

/// @nodoc
abstract mixin class $TeamInvitationEntityCopyWith<$Res>  {
  factory $TeamInvitationEntityCopyWith(TeamInvitationEntity value, $Res Function(TeamInvitationEntity) _then) = _$TeamInvitationEntityCopyWithImpl;
@useResult
$Res call({
 String id, String teamId, String email, TeamMemberRoleEntity role, String token, InvitationStatusEntity status, String invitedBy, String expiresAt, String createdAt, TeamEntity? team
});


$TeamEntityCopyWith<$Res>? get team;

}
/// @nodoc
class _$TeamInvitationEntityCopyWithImpl<$Res>
    implements $TeamInvitationEntityCopyWith<$Res> {
  _$TeamInvitationEntityCopyWithImpl(this._self, this._then);

  final TeamInvitationEntity _self;
  final $Res Function(TeamInvitationEntity) _then;

/// Create a copy of TeamInvitationEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? teamId = null,Object? email = null,Object? role = null,Object? token = null,Object? status = null,Object? invitedBy = null,Object? expiresAt = null,Object? createdAt = null,Object? team = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as TeamMemberRoleEntity,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvitationStatusEntity,invitedBy: null == invitedBy ? _self.invitedBy : invitedBy // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,team: freezed == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as TeamEntity?,
  ));
}
/// Create a copy of TeamInvitationEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamEntityCopyWith<$Res>? get team {
    if (_self.team == null) {
    return null;
  }

  return $TeamEntityCopyWith<$Res>(_self.team!, (value) {
    return _then(_self.copyWith(team: value));
  });
}
}


/// Adds pattern-matching-related methods to [TeamInvitationEntity].
extension TeamInvitationEntityPatterns on TeamInvitationEntity {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamInvitationEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamInvitationEntity() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamInvitationEntity value)  $default,){
final _that = this;
switch (_that) {
case _TeamInvitationEntity():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamInvitationEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TeamInvitationEntity() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String teamId,  String email,  TeamMemberRoleEntity role,  String token,  InvitationStatusEntity status,  String invitedBy,  String expiresAt,  String createdAt,  TeamEntity? team)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamInvitationEntity() when $default != null:
return $default(_that.id,_that.teamId,_that.email,_that.role,_that.token,_that.status,_that.invitedBy,_that.expiresAt,_that.createdAt,_that.team);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String teamId,  String email,  TeamMemberRoleEntity role,  String token,  InvitationStatusEntity status,  String invitedBy,  String expiresAt,  String createdAt,  TeamEntity? team)  $default,) {final _that = this;
switch (_that) {
case _TeamInvitationEntity():
return $default(_that.id,_that.teamId,_that.email,_that.role,_that.token,_that.status,_that.invitedBy,_that.expiresAt,_that.createdAt,_that.team);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String teamId,  String email,  TeamMemberRoleEntity role,  String token,  InvitationStatusEntity status,  String invitedBy,  String expiresAt,  String createdAt,  TeamEntity? team)?  $default,) {final _that = this;
switch (_that) {
case _TeamInvitationEntity() when $default != null:
return $default(_that.id,_that.teamId,_that.email,_that.role,_that.token,_that.status,_that.invitedBy,_that.expiresAt,_that.createdAt,_that.team);case _:
  return null;

}
}

}

/// @nodoc


class _TeamInvitationEntity implements TeamInvitationEntity {
  const _TeamInvitationEntity({required this.id, required this.teamId, required this.email, required this.role, required this.token, required this.status, required this.invitedBy, required this.expiresAt, required this.createdAt, this.team});
  

@override final  String id;
@override final  String teamId;
@override final  String email;
@override final  TeamMemberRoleEntity role;
@override final  String token;
@override final  InvitationStatusEntity status;
@override final  String invitedBy;
@override final  String expiresAt;
@override final  String createdAt;
@override final  TeamEntity? team;

/// Create a copy of TeamInvitationEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamInvitationEntityCopyWith<_TeamInvitationEntity> get copyWith => __$TeamInvitationEntityCopyWithImpl<_TeamInvitationEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamInvitationEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.token, token) || other.token == token)&&(identical(other.status, status) || other.status == status)&&(identical(other.invitedBy, invitedBy) || other.invitedBy == invitedBy)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.team, team) || other.team == team));
}


@override
int get hashCode => Object.hash(runtimeType,id,teamId,email,role,token,status,invitedBy,expiresAt,createdAt,team);

@override
String toString() {
  return 'TeamInvitationEntity(id: $id, teamId: $teamId, email: $email, role: $role, token: $token, status: $status, invitedBy: $invitedBy, expiresAt: $expiresAt, createdAt: $createdAt, team: $team)';
}


}

/// @nodoc
abstract mixin class _$TeamInvitationEntityCopyWith<$Res> implements $TeamInvitationEntityCopyWith<$Res> {
  factory _$TeamInvitationEntityCopyWith(_TeamInvitationEntity value, $Res Function(_TeamInvitationEntity) _then) = __$TeamInvitationEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String teamId, String email, TeamMemberRoleEntity role, String token, InvitationStatusEntity status, String invitedBy, String expiresAt, String createdAt, TeamEntity? team
});


@override $TeamEntityCopyWith<$Res>? get team;

}
/// @nodoc
class __$TeamInvitationEntityCopyWithImpl<$Res>
    implements _$TeamInvitationEntityCopyWith<$Res> {
  __$TeamInvitationEntityCopyWithImpl(this._self, this._then);

  final _TeamInvitationEntity _self;
  final $Res Function(_TeamInvitationEntity) _then;

/// Create a copy of TeamInvitationEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? teamId = null,Object? email = null,Object? role = null,Object? token = null,Object? status = null,Object? invitedBy = null,Object? expiresAt = null,Object? createdAt = null,Object? team = freezed,}) {
  return _then(_TeamInvitationEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as TeamMemberRoleEntity,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvitationStatusEntity,invitedBy: null == invitedBy ? _self.invitedBy : invitedBy // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,team: freezed == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as TeamEntity?,
  ));
}

/// Create a copy of TeamInvitationEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamEntityCopyWith<$Res>? get team {
    if (_self.team == null) {
    return null;
  }

  return $TeamEntityCopyWith<$Res>(_self.team!, (value) {
    return _then(_self.copyWith(team: value));
  });
}
}

// dart format on
