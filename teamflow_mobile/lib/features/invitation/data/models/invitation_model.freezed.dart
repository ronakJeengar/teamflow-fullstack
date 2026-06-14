// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invitation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InvitationModel {

 String get id; String get teamId; String get email; String get invitedById; String get role; String get token; String get status; DateTime get expiresAt; DateTime get createdAt; DateTime get updatedAt; TeamInfo get team;
/// Create a copy of InvitationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvitationModelCopyWith<InvitationModel> get copyWith => _$InvitationModelCopyWithImpl<InvitationModel>(this as InvitationModel, _$identity);

  /// Serializes this InvitationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvitationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.email, email) || other.email == email)&&(identical(other.invitedById, invitedById) || other.invitedById == invitedById)&&(identical(other.role, role) || other.role == role)&&(identical(other.token, token) || other.token == token)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.team, team) || other.team == team));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,teamId,email,invitedById,role,token,status,expiresAt,createdAt,updatedAt,team);

@override
String toString() {
  return 'InvitationModel(id: $id, teamId: $teamId, email: $email, invitedById: $invitedById, role: $role, token: $token, status: $status, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt, team: $team)';
}


}

/// @nodoc
abstract mixin class $InvitationModelCopyWith<$Res>  {
  factory $InvitationModelCopyWith(InvitationModel value, $Res Function(InvitationModel) _then) = _$InvitationModelCopyWithImpl;
@useResult
$Res call({
 String id, String teamId, String email, String invitedById, String role, String token, String status, DateTime expiresAt, DateTime createdAt, DateTime updatedAt, TeamInfo team
});


$TeamInfoCopyWith<$Res> get team;

}
/// @nodoc
class _$InvitationModelCopyWithImpl<$Res>
    implements $InvitationModelCopyWith<$Res> {
  _$InvitationModelCopyWithImpl(this._self, this._then);

  final InvitationModel _self;
  final $Res Function(InvitationModel) _then;

/// Create a copy of InvitationModel
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
as TeamInfo,
  ));
}
/// Create a copy of InvitationModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamInfoCopyWith<$Res> get team {
  
  return $TeamInfoCopyWith<$Res>(_self.team, (value) {
    return _then(_self.copyWith(team: value));
  });
}
}


/// Adds pattern-matching-related methods to [InvitationModel].
extension InvitationModelPatterns on InvitationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvitationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvitationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvitationModel value)  $default,){
final _that = this;
switch (_that) {
case _InvitationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvitationModel value)?  $default,){
final _that = this;
switch (_that) {
case _InvitationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String teamId,  String email,  String invitedById,  String role,  String token,  String status,  DateTime expiresAt,  DateTime createdAt,  DateTime updatedAt,  TeamInfo team)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvitationModel() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String teamId,  String email,  String invitedById,  String role,  String token,  String status,  DateTime expiresAt,  DateTime createdAt,  DateTime updatedAt,  TeamInfo team)  $default,) {final _that = this;
switch (_that) {
case _InvitationModel():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String teamId,  String email,  String invitedById,  String role,  String token,  String status,  DateTime expiresAt,  DateTime createdAt,  DateTime updatedAt,  TeamInfo team)?  $default,) {final _that = this;
switch (_that) {
case _InvitationModel() when $default != null:
return $default(_that.id,_that.teamId,_that.email,_that.invitedById,_that.role,_that.token,_that.status,_that.expiresAt,_that.createdAt,_that.updatedAt,_that.team);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvitationModel implements InvitationModel {
  const _InvitationModel({required this.id, required this.teamId, required this.email, required this.invitedById, required this.role, required this.token, required this.status, required this.expiresAt, required this.createdAt, required this.updatedAt, required this.team});
  factory _InvitationModel.fromJson(Map<String, dynamic> json) => _$InvitationModelFromJson(json);

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
@override final  TeamInfo team;

/// Create a copy of InvitationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvitationModelCopyWith<_InvitationModel> get copyWith => __$InvitationModelCopyWithImpl<_InvitationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvitationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvitationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.email, email) || other.email == email)&&(identical(other.invitedById, invitedById) || other.invitedById == invitedById)&&(identical(other.role, role) || other.role == role)&&(identical(other.token, token) || other.token == token)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.team, team) || other.team == team));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,teamId,email,invitedById,role,token,status,expiresAt,createdAt,updatedAt,team);

@override
String toString() {
  return 'InvitationModel(id: $id, teamId: $teamId, email: $email, invitedById: $invitedById, role: $role, token: $token, status: $status, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt, team: $team)';
}


}

/// @nodoc
abstract mixin class _$InvitationModelCopyWith<$Res> implements $InvitationModelCopyWith<$Res> {
  factory _$InvitationModelCopyWith(_InvitationModel value, $Res Function(_InvitationModel) _then) = __$InvitationModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String teamId, String email, String invitedById, String role, String token, String status, DateTime expiresAt, DateTime createdAt, DateTime updatedAt, TeamInfo team
});


@override $TeamInfoCopyWith<$Res> get team;

}
/// @nodoc
class __$InvitationModelCopyWithImpl<$Res>
    implements _$InvitationModelCopyWith<$Res> {
  __$InvitationModelCopyWithImpl(this._self, this._then);

  final _InvitationModel _self;
  final $Res Function(_InvitationModel) _then;

/// Create a copy of InvitationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? teamId = null,Object? email = null,Object? invitedById = null,Object? role = null,Object? token = null,Object? status = null,Object? expiresAt = null,Object? createdAt = null,Object? updatedAt = null,Object? team = null,}) {
  return _then(_InvitationModel(
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
as TeamInfo,
  ));
}

/// Create a copy of InvitationModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamInfoCopyWith<$Res> get team {
  
  return $TeamInfoCopyWith<$Res>(_self.team, (value) {
    return _then(_self.copyWith(team: value));
  });
}
}


/// @nodoc
mixin _$TeamInfo {

 String get id; String get name; String? get avatar;
/// Create a copy of TeamInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamInfoCopyWith<TeamInfo> get copyWith => _$TeamInfoCopyWithImpl<TeamInfo>(this as TeamInfo, _$identity);

  /// Serializes this TeamInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatar, avatar) || other.avatar == avatar));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatar);

@override
String toString() {
  return 'TeamInfo(id: $id, name: $name, avatar: $avatar)';
}


}

/// @nodoc
abstract mixin class $TeamInfoCopyWith<$Res>  {
  factory $TeamInfoCopyWith(TeamInfo value, $Res Function(TeamInfo) _then) = _$TeamInfoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? avatar
});




}
/// @nodoc
class _$TeamInfoCopyWithImpl<$Res>
    implements $TeamInfoCopyWith<$Res> {
  _$TeamInfoCopyWithImpl(this._self, this._then);

  final TeamInfo _self;
  final $Res Function(TeamInfo) _then;

/// Create a copy of TeamInfo
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


/// Adds pattern-matching-related methods to [TeamInfo].
extension TeamInfoPatterns on TeamInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamInfo value)  $default,){
final _that = this;
switch (_that) {
case _TeamInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamInfo value)?  $default,){
final _that = this;
switch (_that) {
case _TeamInfo() when $default != null:
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
case _TeamInfo() when $default != null:
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
case _TeamInfo():
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
case _TeamInfo() when $default != null:
return $default(_that.id,_that.name,_that.avatar);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamInfo implements TeamInfo {
  const _TeamInfo({required this.id, required this.name, this.avatar});
  factory _TeamInfo.fromJson(Map<String, dynamic> json) => _$TeamInfoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? avatar;

/// Create a copy of TeamInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamInfoCopyWith<_TeamInfo> get copyWith => __$TeamInfoCopyWithImpl<_TeamInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatar, avatar) || other.avatar == avatar));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatar);

@override
String toString() {
  return 'TeamInfo(id: $id, name: $name, avatar: $avatar)';
}


}

/// @nodoc
abstract mixin class _$TeamInfoCopyWith<$Res> implements $TeamInfoCopyWith<$Res> {
  factory _$TeamInfoCopyWith(_TeamInfo value, $Res Function(_TeamInfo) _then) = __$TeamInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? avatar
});




}
/// @nodoc
class __$TeamInfoCopyWithImpl<$Res>
    implements _$TeamInfoCopyWith<$Res> {
  __$TeamInfoCopyWithImpl(this._self, this._then);

  final _TeamInfo _self;
  final $Res Function(_TeamInfo) _then;

/// Create a copy of TeamInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? avatar = freezed,}) {
  return _then(_TeamInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
