// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invitation_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InvitationEntity {

 String get id; String get teamId; String get email; String get invitedById; String get role; String get token; String get status; DateTime get expiresAt; DateTime get createdAt; DateTime get updatedAt; TeamEntity get team;
/// Create a copy of InvitationEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvitationEntityCopyWith<InvitationEntity> get copyWith => _$InvitationEntityCopyWithImpl<InvitationEntity>(this as InvitationEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvitationEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.email, email) || other.email == email)&&(identical(other.invitedById, invitedById) || other.invitedById == invitedById)&&(identical(other.role, role) || other.role == role)&&(identical(other.token, token) || other.token == token)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.team, team) || other.team == team));
}


@override
int get hashCode => Object.hash(runtimeType,id,teamId,email,invitedById,role,token,status,expiresAt,createdAt,updatedAt,team);

@override
String toString() {
  return 'InvitationEntity(id: $id, teamId: $teamId, email: $email, invitedById: $invitedById, role: $role, token: $token, status: $status, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt, team: $team)';
}


}

/// @nodoc
abstract mixin class $InvitationEntityCopyWith<$Res>  {
  factory $InvitationEntityCopyWith(InvitationEntity value, $Res Function(InvitationEntity) _then) = _$InvitationEntityCopyWithImpl;
@useResult
$Res call({
 String id, String teamId, String email, String invitedById, String role, String token, String status, DateTime expiresAt, DateTime createdAt, DateTime updatedAt, TeamEntity team
});


$TeamEntityCopyWith<$Res> get team;

}
/// @nodoc
class _$InvitationEntityCopyWithImpl<$Res>
    implements $InvitationEntityCopyWith<$Res> {
  _$InvitationEntityCopyWithImpl(this._self, this._then);

  final InvitationEntity _self;
  final $Res Function(InvitationEntity) _then;

/// Create a copy of InvitationEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? teamId = null,Object? email = null,Object? invitedById = null,Object? role = null,Object? token = null,Object? status = null,Object? expiresAt = null,Object? createdAt = null,Object? updatedAt = null,Object? team = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,invitedById: null == invitedById ? _self.invitedById : invitedById // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as TeamEntity,
  ));
}
/// Create a copy of InvitationEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamEntityCopyWith<$Res> get team {
  
  return $TeamEntityCopyWith<$Res>(_self.team, (value) {
    return _then(_self.copyWith(team: value));
  });
}
}


/// Adds pattern-matching-related methods to [InvitationEntity].
extension InvitationEntityPatterns on InvitationEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvitationEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvitationEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvitationEntity value)  $default,){
final _that = this;
switch (_that) {
case _InvitationEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvitationEntity value)?  $default,){
final _that = this;
switch (_that) {
case _InvitationEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String teamId,  String email,  String invitedById,  String role,  String token,  String status,  DateTime expiresAt,  DateTime createdAt,  DateTime updatedAt,  TeamEntity team)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvitationEntity() when $default != null:
return $default(_that.id,_that.teamId,_that.email,_that.invitedById,_that.role,_that.token,_that.status,_that.expiresAt,_that.createdAt,_that.updatedAt,_that.team);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String teamId,  String email,  String invitedById,  String role,  String token,  String status,  DateTime expiresAt,  DateTime createdAt,  DateTime updatedAt,  TeamEntity team)  $default,) {final _that = this;
switch (_that) {
case _InvitationEntity():
return $default(_that.id,_that.teamId,_that.email,_that.invitedById,_that.role,_that.token,_that.status,_that.expiresAt,_that.createdAt,_that.updatedAt,_that.team);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String teamId,  String email,  String invitedById,  String role,  String token,  String status,  DateTime expiresAt,  DateTime createdAt,  DateTime updatedAt,  TeamEntity team)?  $default,) {final _that = this;
switch (_that) {
case _InvitationEntity() when $default != null:
return $default(_that.id,_that.teamId,_that.email,_that.invitedById,_that.role,_that.token,_that.status,_that.expiresAt,_that.createdAt,_that.updatedAt,_that.team);case _:
  return null;

}
}

}

/// @nodoc


class _InvitationEntity implements InvitationEntity {
  const _InvitationEntity({required this.id, required this.teamId, required this.email, required this.invitedById, required this.role, required this.token, required this.status, required this.expiresAt, required this.createdAt, required this.updatedAt, required this.team});
  

@override final  String id;
@override final  String teamId;
@override final  String email;
@override final  String invitedById;
@override final  String role;
@override final  String token;
@override final  String status;
@override final  DateTime expiresAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  TeamEntity team;

/// Create a copy of InvitationEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvitationEntityCopyWith<_InvitationEntity> get copyWith => __$InvitationEntityCopyWithImpl<_InvitationEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvitationEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.email, email) || other.email == email)&&(identical(other.invitedById, invitedById) || other.invitedById == invitedById)&&(identical(other.role, role) || other.role == role)&&(identical(other.token, token) || other.token == token)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.team, team) || other.team == team));
}


@override
int get hashCode => Object.hash(runtimeType,id,teamId,email,invitedById,role,token,status,expiresAt,createdAt,updatedAt,team);

@override
String toString() {
  return 'InvitationEntity(id: $id, teamId: $teamId, email: $email, invitedById: $invitedById, role: $role, token: $token, status: $status, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt, team: $team)';
}


}

/// @nodoc
abstract mixin class _$InvitationEntityCopyWith<$Res> implements $InvitationEntityCopyWith<$Res> {
  factory _$InvitationEntityCopyWith(_InvitationEntity value, $Res Function(_InvitationEntity) _then) = __$InvitationEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String teamId, String email, String invitedById, String role, String token, String status, DateTime expiresAt, DateTime createdAt, DateTime updatedAt, TeamEntity team
});


@override $TeamEntityCopyWith<$Res> get team;

}
/// @nodoc
class __$InvitationEntityCopyWithImpl<$Res>
    implements _$InvitationEntityCopyWith<$Res> {
  __$InvitationEntityCopyWithImpl(this._self, this._then);

  final _InvitationEntity _self;
  final $Res Function(_InvitationEntity) _then;

/// Create a copy of InvitationEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? teamId = null,Object? email = null,Object? invitedById = null,Object? role = null,Object? token = null,Object? status = null,Object? expiresAt = null,Object? createdAt = null,Object? updatedAt = null,Object? team = null,}) {
  return _then(_InvitationEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,invitedById: null == invitedById ? _self.invitedById : invitedById // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as TeamEntity,
  ));
}

/// Create a copy of InvitationEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamEntityCopyWith<$Res> get team {
  
  return $TeamEntityCopyWith<$Res>(_self.team, (value) {
    return _then(_self.copyWith(team: value));
  });
}
}

/// @nodoc
mixin _$TeamEntity {

 String get id; String get name; String? get avatar;
/// Create a copy of TeamEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamEntityCopyWith<TeamEntity> get copyWith => _$TeamEntityCopyWithImpl<TeamEntity>(this as TeamEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatar, avatar) || other.avatar == avatar));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,avatar);

@override
String toString() {
  return 'TeamEntity(id: $id, name: $name, avatar: $avatar)';
}


}

/// @nodoc
abstract mixin class $TeamEntityCopyWith<$Res>  {
  factory $TeamEntityCopyWith(TeamEntity value, $Res Function(TeamEntity) _then) = _$TeamEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? avatar
});




}
/// @nodoc
class _$TeamEntityCopyWithImpl<$Res>
    implements $TeamEntityCopyWith<$Res> {
  _$TeamEntityCopyWithImpl(this._self, this._then);

  final TeamEntity _self;
  final $Res Function(TeamEntity) _then;

/// Create a copy of TeamEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? avatar = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamEntity].
extension TeamEntityPatterns on TeamEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamEntity value)  $default,){
final _that = this;
switch (_that) {
case _TeamEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TeamEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? avatar)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamEntity() when $default != null:
return $default(_that.id,_that.name,_that.avatar);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? avatar)  $default,) {final _that = this;
switch (_that) {
case _TeamEntity():
return $default(_that.id,_that.name,_that.avatar);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? avatar)?  $default,) {final _that = this;
switch (_that) {
case _TeamEntity() when $default != null:
return $default(_that.id,_that.name,_that.avatar);case _:
  return null;

}
}

}

/// @nodoc


class _TeamEntity implements TeamEntity {
  const _TeamEntity({required this.id, required this.name, this.avatar});
  

@override final  String id;
@override final  String name;
@override final  String? avatar;

/// Create a copy of TeamEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamEntityCopyWith<_TeamEntity> get copyWith => __$TeamEntityCopyWithImpl<_TeamEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatar, avatar) || other.avatar == avatar));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,avatar);

@override
String toString() {
  return 'TeamEntity(id: $id, name: $name, avatar: $avatar)';
}


}

/// @nodoc
abstract mixin class _$TeamEntityCopyWith<$Res> implements $TeamEntityCopyWith<$Res> {
  factory _$TeamEntityCopyWith(_TeamEntity value, $Res Function(_TeamEntity) _then) = __$TeamEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? avatar
});




}
/// @nodoc
class __$TeamEntityCopyWithImpl<$Res>
    implements _$TeamEntityCopyWith<$Res> {
  __$TeamEntityCopyWithImpl(this._self, this._then);

  final _TeamEntity _self;
  final $Res Function(_TeamEntity) _then;

/// Create a copy of TeamEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? avatar = freezed,}) {
  return _then(_TeamEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
