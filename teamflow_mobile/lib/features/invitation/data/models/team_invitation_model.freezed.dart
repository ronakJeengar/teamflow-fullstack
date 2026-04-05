// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_invitation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TeamInvitation {

 String get id; String get teamId; String get email; TeamMemberRole get role; String get token; InvitationStatus get status; String get invitedBy; String get expiresAt; String get createdAt; Team? get team;
/// Create a copy of TeamInvitation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamInvitationCopyWith<TeamInvitation> get copyWith => _$TeamInvitationCopyWithImpl<TeamInvitation>(this as TeamInvitation, _$identity);

  /// Serializes this TeamInvitation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamInvitation&&(identical(other.id, id) || other.id == id)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.token, token) || other.token == token)&&(identical(other.status, status) || other.status == status)&&(identical(other.invitedBy, invitedBy) || other.invitedBy == invitedBy)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.team, team) || other.team == team));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,teamId,email,role,token,status,invitedBy,expiresAt,createdAt,team);

@override
String toString() {
  return 'TeamInvitation(id: $id, teamId: $teamId, email: $email, role: $role, token: $token, status: $status, invitedBy: $invitedBy, expiresAt: $expiresAt, createdAt: $createdAt, team: $team)';
}


}

/// @nodoc
abstract mixin class $TeamInvitationCopyWith<$Res>  {
  factory $TeamInvitationCopyWith(TeamInvitation value, $Res Function(TeamInvitation) _then) = _$TeamInvitationCopyWithImpl;
@useResult
$Res call({
 String id, String teamId, String email, TeamMemberRole role, String token, InvitationStatus status, String invitedBy, String expiresAt, String createdAt, Team? team
});


$TeamCopyWith<$Res>? get team;

}
/// @nodoc
class _$TeamInvitationCopyWithImpl<$Res>
    implements $TeamInvitationCopyWith<$Res> {
  _$TeamInvitationCopyWithImpl(this._self, this._then);

  final TeamInvitation _self;
  final $Res Function(TeamInvitation) _then;

/// Create a copy of TeamInvitation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? teamId = null,Object? email = null,Object? role = null,Object? token = null,Object? status = null,Object? invitedBy = null,Object? expiresAt = null,Object? createdAt = null,Object? team = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as TeamMemberRole,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvitationStatus,invitedBy: null == invitedBy ? _self.invitedBy : invitedBy // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,team: freezed == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as Team?,
  ));
}
/// Create a copy of TeamInvitation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamCopyWith<$Res>? get team {
    if (_self.team == null) {
    return null;
  }

  return $TeamCopyWith<$Res>(_self.team!, (value) {
    return _then(_self.copyWith(team: value));
  });
}
}


/// Adds pattern-matching-related methods to [TeamInvitation].
extension TeamInvitationPatterns on TeamInvitation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamInvitation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamInvitation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamInvitation value)  $default,){
final _that = this;
switch (_that) {
case _TeamInvitation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamInvitation value)?  $default,){
final _that = this;
switch (_that) {
case _TeamInvitation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String teamId,  String email,  TeamMemberRole role,  String token,  InvitationStatus status,  String invitedBy,  String expiresAt,  String createdAt,  Team? team)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamInvitation() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String teamId,  String email,  TeamMemberRole role,  String token,  InvitationStatus status,  String invitedBy,  String expiresAt,  String createdAt,  Team? team)  $default,) {final _that = this;
switch (_that) {
case _TeamInvitation():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String teamId,  String email,  TeamMemberRole role,  String token,  InvitationStatus status,  String invitedBy,  String expiresAt,  String createdAt,  Team? team)?  $default,) {final _that = this;
switch (_that) {
case _TeamInvitation() when $default != null:
return $default(_that.id,_that.teamId,_that.email,_that.role,_that.token,_that.status,_that.invitedBy,_that.expiresAt,_that.createdAt,_that.team);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamInvitation implements TeamInvitation {
  const _TeamInvitation({required this.id, required this.teamId, required this.email, required this.role, required this.token, required this.status, required this.invitedBy, required this.expiresAt, required this.createdAt, this.team});
  factory _TeamInvitation.fromJson(Map<String, dynamic> json) => _$TeamInvitationFromJson(json);

@override final  String id;
@override final  String teamId;
@override final  String email;
@override final  TeamMemberRole role;
@override final  String token;
@override final  InvitationStatus status;
@override final  String invitedBy;
@override final  String expiresAt;
@override final  String createdAt;
@override final  Team? team;

/// Create a copy of TeamInvitation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamInvitationCopyWith<_TeamInvitation> get copyWith => __$TeamInvitationCopyWithImpl<_TeamInvitation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamInvitationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamInvitation&&(identical(other.id, id) || other.id == id)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.token, token) || other.token == token)&&(identical(other.status, status) || other.status == status)&&(identical(other.invitedBy, invitedBy) || other.invitedBy == invitedBy)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.team, team) || other.team == team));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,teamId,email,role,token,status,invitedBy,expiresAt,createdAt,team);

@override
String toString() {
  return 'TeamInvitation(id: $id, teamId: $teamId, email: $email, role: $role, token: $token, status: $status, invitedBy: $invitedBy, expiresAt: $expiresAt, createdAt: $createdAt, team: $team)';
}


}

/// @nodoc
abstract mixin class _$TeamInvitationCopyWith<$Res> implements $TeamInvitationCopyWith<$Res> {
  factory _$TeamInvitationCopyWith(_TeamInvitation value, $Res Function(_TeamInvitation) _then) = __$TeamInvitationCopyWithImpl;
@override @useResult
$Res call({
 String id, String teamId, String email, TeamMemberRole role, String token, InvitationStatus status, String invitedBy, String expiresAt, String createdAt, Team? team
});


@override $TeamCopyWith<$Res>? get team;

}
/// @nodoc
class __$TeamInvitationCopyWithImpl<$Res>
    implements _$TeamInvitationCopyWith<$Res> {
  __$TeamInvitationCopyWithImpl(this._self, this._then);

  final _TeamInvitation _self;
  final $Res Function(_TeamInvitation) _then;

/// Create a copy of TeamInvitation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? teamId = null,Object? email = null,Object? role = null,Object? token = null,Object? status = null,Object? invitedBy = null,Object? expiresAt = null,Object? createdAt = null,Object? team = freezed,}) {
  return _then(_TeamInvitation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as TeamMemberRole,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvitationStatus,invitedBy: null == invitedBy ? _self.invitedBy : invitedBy // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,team: freezed == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as Team?,
  ));
}

/// Create a copy of TeamInvitation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamCopyWith<$Res>? get team {
    if (_self.team == null) {
    return null;
  }

  return $TeamCopyWith<$Res>(_self.team!, (value) {
    return _then(_self.copyWith(team: value));
  });
}
}

// dart format on
