// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_member_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TeamMember {

 String get id; String get teamId; String get userId; TeamMemberRole get role; String get joinedAt; Team? get team; UserModel? get user;
/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamMemberCopyWith<TeamMember> get copyWith => _$TeamMemberCopyWithImpl<TeamMember>(this as TeamMember, _$identity);

  /// Serializes this TeamMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamMember&&(identical(other.id, id) || other.id == id)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.team, team) || other.team == team)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,teamId,userId,role,joinedAt,team,user);

@override
String toString() {
  return 'TeamMember(id: $id, teamId: $teamId, userId: $userId, role: $role, joinedAt: $joinedAt, team: $team, user: $user)';
}


}

/// @nodoc
abstract mixin class $TeamMemberCopyWith<$Res>  {
  factory $TeamMemberCopyWith(TeamMember value, $Res Function(TeamMember) _then) = _$TeamMemberCopyWithImpl;
@useResult
$Res call({
 String id, String teamId, String userId, TeamMemberRole role, String joinedAt, Team? team, UserModel? user
});


$TeamCopyWith<$Res>? get team;$UserModelCopyWith<$Res>? get user;

}
/// @nodoc
class _$TeamMemberCopyWithImpl<$Res>
    implements $TeamMemberCopyWith<$Res> {
  _$TeamMemberCopyWithImpl(this._self, this._then);

  final TeamMember _self;
  final $Res Function(TeamMember) _then;

/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? teamId = null,Object? userId = null,Object? role = null,Object? joinedAt = null,Object? team = freezed,Object? user = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as TeamMemberRole,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as String,team: freezed == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as Team?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserModel?,
  ));
}
/// Create a copy of TeamMember
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
}/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserModelCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [TeamMember].
extension TeamMemberPatterns on TeamMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamMember value)  $default,){
final _that = this;
switch (_that) {
case _TeamMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamMember value)?  $default,){
final _that = this;
switch (_that) {
case _TeamMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String teamId,  String userId,  TeamMemberRole role,  String joinedAt,  Team? team,  UserModel? user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamMember() when $default != null:
return $default(_that.id,_that.teamId,_that.userId,_that.role,_that.joinedAt,_that.team,_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String teamId,  String userId,  TeamMemberRole role,  String joinedAt,  Team? team,  UserModel? user)  $default,) {final _that = this;
switch (_that) {
case _TeamMember():
return $default(_that.id,_that.teamId,_that.userId,_that.role,_that.joinedAt,_that.team,_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String teamId,  String userId,  TeamMemberRole role,  String joinedAt,  Team? team,  UserModel? user)?  $default,) {final _that = this;
switch (_that) {
case _TeamMember() when $default != null:
return $default(_that.id,_that.teamId,_that.userId,_that.role,_that.joinedAt,_that.team,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamMember implements TeamMember {
  const _TeamMember({required this.id, required this.teamId, required this.userId, required this.role, required this.joinedAt, this.team, this.user});
  factory _TeamMember.fromJson(Map<String, dynamic> json) => _$TeamMemberFromJson(json);

@override final  String id;
@override final  String teamId;
@override final  String userId;
@override final  TeamMemberRole role;
@override final  String joinedAt;
@override final  Team? team;
@override final  UserModel? user;

/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamMemberCopyWith<_TeamMember> get copyWith => __$TeamMemberCopyWithImpl<_TeamMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamMember&&(identical(other.id, id) || other.id == id)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.team, team) || other.team == team)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,teamId,userId,role,joinedAt,team,user);

@override
String toString() {
  return 'TeamMember(id: $id, teamId: $teamId, userId: $userId, role: $role, joinedAt: $joinedAt, team: $team, user: $user)';
}


}

/// @nodoc
abstract mixin class _$TeamMemberCopyWith<$Res> implements $TeamMemberCopyWith<$Res> {
  factory _$TeamMemberCopyWith(_TeamMember value, $Res Function(_TeamMember) _then) = __$TeamMemberCopyWithImpl;
@override @useResult
$Res call({
 String id, String teamId, String userId, TeamMemberRole role, String joinedAt, Team? team, UserModel? user
});


@override $TeamCopyWith<$Res>? get team;@override $UserModelCopyWith<$Res>? get user;

}
/// @nodoc
class __$TeamMemberCopyWithImpl<$Res>
    implements _$TeamMemberCopyWith<$Res> {
  __$TeamMemberCopyWithImpl(this._self, this._then);

  final _TeamMember _self;
  final $Res Function(_TeamMember) _then;

/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? teamId = null,Object? userId = null,Object? role = null,Object? joinedAt = null,Object? team = freezed,Object? user = freezed,}) {
  return _then(_TeamMember(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as TeamMemberRole,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as String,team: freezed == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as Team?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserModel?,
  ));
}

/// Create a copy of TeamMember
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
}/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserModelCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
