// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MembershipEntity {

 String get role; MembershipTeamEntity get team;
/// Create a copy of MembershipEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembershipEntityCopyWith<MembershipEntity> get copyWith => _$MembershipEntityCopyWithImpl<MembershipEntity>(this as MembershipEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MembershipEntity&&(identical(other.role, role) || other.role == role)&&(identical(other.team, team) || other.team == team));
}


@override
int get hashCode => Object.hash(runtimeType,role,team);

@override
String toString() {
  return 'MembershipEntity(role: $role, team: $team)';
}


}

/// @nodoc
abstract mixin class $MembershipEntityCopyWith<$Res>  {
  factory $MembershipEntityCopyWith(MembershipEntity value, $Res Function(MembershipEntity) _then) = _$MembershipEntityCopyWithImpl;
@useResult
$Res call({
 String role, MembershipTeamEntity team
});


$MembershipTeamEntityCopyWith<$Res> get team;

}
/// @nodoc
class _$MembershipEntityCopyWithImpl<$Res>
    implements $MembershipEntityCopyWith<$Res> {
  _$MembershipEntityCopyWithImpl(this._self, this._then);

  final MembershipEntity _self;
  final $Res Function(MembershipEntity) _then;

/// Create a copy of MembershipEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = null,Object? team = null,}) {
  return _then(_self.copyWith(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as MembershipTeamEntity,
  ));
}
/// Create a copy of MembershipEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MembershipTeamEntityCopyWith<$Res> get team {
  
  return $MembershipTeamEntityCopyWith<$Res>(_self.team, (value) {
    return _then(_self.copyWith(team: value));
  });
}
}


/// Adds pattern-matching-related methods to [MembershipEntity].
extension MembershipEntityPatterns on MembershipEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MembershipEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MembershipEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MembershipEntity value)  $default,){
final _that = this;
switch (_that) {
case _MembershipEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MembershipEntity value)?  $default,){
final _that = this;
switch (_that) {
case _MembershipEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String role,  MembershipTeamEntity team)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MembershipEntity() when $default != null:
return $default(_that.role,_that.team);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String role,  MembershipTeamEntity team)  $default,) {final _that = this;
switch (_that) {
case _MembershipEntity():
return $default(_that.role,_that.team);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String role,  MembershipTeamEntity team)?  $default,) {final _that = this;
switch (_that) {
case _MembershipEntity() when $default != null:
return $default(_that.role,_that.team);case _:
  return null;

}
}

}

/// @nodoc


class _MembershipEntity implements MembershipEntity {
  const _MembershipEntity({required this.role, required this.team});
  

@override final  String role;
@override final  MembershipTeamEntity team;

/// Create a copy of MembershipEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembershipEntityCopyWith<_MembershipEntity> get copyWith => __$MembershipEntityCopyWithImpl<_MembershipEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MembershipEntity&&(identical(other.role, role) || other.role == role)&&(identical(other.team, team) || other.team == team));
}


@override
int get hashCode => Object.hash(runtimeType,role,team);

@override
String toString() {
  return 'MembershipEntity(role: $role, team: $team)';
}


}

/// @nodoc
abstract mixin class _$MembershipEntityCopyWith<$Res> implements $MembershipEntityCopyWith<$Res> {
  factory _$MembershipEntityCopyWith(_MembershipEntity value, $Res Function(_MembershipEntity) _then) = __$MembershipEntityCopyWithImpl;
@override @useResult
$Res call({
 String role, MembershipTeamEntity team
});


@override $MembershipTeamEntityCopyWith<$Res> get team;

}
/// @nodoc
class __$MembershipEntityCopyWithImpl<$Res>
    implements _$MembershipEntityCopyWith<$Res> {
  __$MembershipEntityCopyWithImpl(this._self, this._then);

  final _MembershipEntity _self;
  final $Res Function(_MembershipEntity) _then;

/// Create a copy of MembershipEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = null,Object? team = null,}) {
  return _then(_MembershipEntity(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as MembershipTeamEntity,
  ));
}

/// Create a copy of MembershipEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MembershipTeamEntityCopyWith<$Res> get team {
  
  return $MembershipTeamEntityCopyWith<$Res>(_self.team, (value) {
    return _then(_self.copyWith(team: value));
  });
}
}

/// @nodoc
mixin _$MembershipTeamEntity {

 String get id; String get name; String? get avatar;
/// Create a copy of MembershipTeamEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembershipTeamEntityCopyWith<MembershipTeamEntity> get copyWith => _$MembershipTeamEntityCopyWithImpl<MembershipTeamEntity>(this as MembershipTeamEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MembershipTeamEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatar, avatar) || other.avatar == avatar));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,avatar);

@override
String toString() {
  return 'MembershipTeamEntity(id: $id, name: $name, avatar: $avatar)';
}


}

/// @nodoc
abstract mixin class $MembershipTeamEntityCopyWith<$Res>  {
  factory $MembershipTeamEntityCopyWith(MembershipTeamEntity value, $Res Function(MembershipTeamEntity) _then) = _$MembershipTeamEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? avatar
});




}
/// @nodoc
class _$MembershipTeamEntityCopyWithImpl<$Res>
    implements $MembershipTeamEntityCopyWith<$Res> {
  _$MembershipTeamEntityCopyWithImpl(this._self, this._then);

  final MembershipTeamEntity _self;
  final $Res Function(MembershipTeamEntity) _then;

/// Create a copy of MembershipTeamEntity
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


/// Adds pattern-matching-related methods to [MembershipTeamEntity].
extension MembershipTeamEntityPatterns on MembershipTeamEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MembershipTeamEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MembershipTeamEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MembershipTeamEntity value)  $default,){
final _that = this;
switch (_that) {
case _MembershipTeamEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MembershipTeamEntity value)?  $default,){
final _that = this;
switch (_that) {
case _MembershipTeamEntity() when $default != null:
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
case _MembershipTeamEntity() when $default != null:
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
case _MembershipTeamEntity():
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
case _MembershipTeamEntity() when $default != null:
return $default(_that.id,_that.name,_that.avatar);case _:
  return null;

}
}

}

/// @nodoc


class _MembershipTeamEntity implements MembershipTeamEntity {
  const _MembershipTeamEntity({required this.id, required this.name, this.avatar});
  

@override final  String id;
@override final  String name;
@override final  String? avatar;

/// Create a copy of MembershipTeamEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembershipTeamEntityCopyWith<_MembershipTeamEntity> get copyWith => __$MembershipTeamEntityCopyWithImpl<_MembershipTeamEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MembershipTeamEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatar, avatar) || other.avatar == avatar));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,avatar);

@override
String toString() {
  return 'MembershipTeamEntity(id: $id, name: $name, avatar: $avatar)';
}


}

/// @nodoc
abstract mixin class _$MembershipTeamEntityCopyWith<$Res> implements $MembershipTeamEntityCopyWith<$Res> {
  factory _$MembershipTeamEntityCopyWith(_MembershipTeamEntity value, $Res Function(_MembershipTeamEntity) _then) = __$MembershipTeamEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? avatar
});




}
/// @nodoc
class __$MembershipTeamEntityCopyWithImpl<$Res>
    implements _$MembershipTeamEntityCopyWith<$Res> {
  __$MembershipTeamEntityCopyWithImpl(this._self, this._then);

  final _MembershipTeamEntity _self;
  final $Res Function(_MembershipTeamEntity) _then;

/// Create a copy of MembershipTeamEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? avatar = freezed,}) {
  return _then(_MembershipTeamEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
