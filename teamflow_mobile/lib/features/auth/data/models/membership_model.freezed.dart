// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MembershipModel {

 String get role; MembershipTeamModel get team;
/// Create a copy of MembershipModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembershipModelCopyWith<MembershipModel> get copyWith => _$MembershipModelCopyWithImpl<MembershipModel>(this as MembershipModel, _$identity);

  /// Serializes this MembershipModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MembershipModel&&(identical(other.role, role) || other.role == role)&&(identical(other.team, team) || other.team == team));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role,team);

@override
String toString() {
  return 'MembershipModel(role: $role, team: $team)';
}


}

/// @nodoc
abstract mixin class $MembershipModelCopyWith<$Res>  {
  factory $MembershipModelCopyWith(MembershipModel value, $Res Function(MembershipModel) _then) = _$MembershipModelCopyWithImpl;
@useResult
$Res call({
 String role, MembershipTeamModel team
});


$MembershipTeamModelCopyWith<$Res> get team;

}
/// @nodoc
class _$MembershipModelCopyWithImpl<$Res>
    implements $MembershipModelCopyWith<$Res> {
  _$MembershipModelCopyWithImpl(this._self, this._then);

  final MembershipModel _self;
  final $Res Function(MembershipModel) _then;

/// Create a copy of MembershipModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = null,Object? team = null,}) {
  return _then(_self.copyWith(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as MembershipTeamModel,
  ));
}
/// Create a copy of MembershipModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MembershipTeamModelCopyWith<$Res> get team {
  
  return $MembershipTeamModelCopyWith<$Res>(_self.team, (value) {
    return _then(_self.copyWith(team: value));
  });
}
}


/// Adds pattern-matching-related methods to [MembershipModel].
extension MembershipModelPatterns on MembershipModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MembershipModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MembershipModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MembershipModel value)  $default,){
final _that = this;
switch (_that) {
case _MembershipModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MembershipModel value)?  $default,){
final _that = this;
switch (_that) {
case _MembershipModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String role,  MembershipTeamModel team)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MembershipModel() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String role,  MembershipTeamModel team)  $default,) {final _that = this;
switch (_that) {
case _MembershipModel():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String role,  MembershipTeamModel team)?  $default,) {final _that = this;
switch (_that) {
case _MembershipModel() when $default != null:
return $default(_that.role,_that.team);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MembershipModel implements MembershipModel {
  const _MembershipModel({required this.role, required this.team});
  factory _MembershipModel.fromJson(Map<String, dynamic> json) => _$MembershipModelFromJson(json);

@override final  String role;
@override final  MembershipTeamModel team;

/// Create a copy of MembershipModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembershipModelCopyWith<_MembershipModel> get copyWith => __$MembershipModelCopyWithImpl<_MembershipModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MembershipModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MembershipModel&&(identical(other.role, role) || other.role == role)&&(identical(other.team, team) || other.team == team));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role,team);

@override
String toString() {
  return 'MembershipModel(role: $role, team: $team)';
}


}

/// @nodoc
abstract mixin class _$MembershipModelCopyWith<$Res> implements $MembershipModelCopyWith<$Res> {
  factory _$MembershipModelCopyWith(_MembershipModel value, $Res Function(_MembershipModel) _then) = __$MembershipModelCopyWithImpl;
@override @useResult
$Res call({
 String role, MembershipTeamModel team
});


@override $MembershipTeamModelCopyWith<$Res> get team;

}
/// @nodoc
class __$MembershipModelCopyWithImpl<$Res>
    implements _$MembershipModelCopyWith<$Res> {
  __$MembershipModelCopyWithImpl(this._self, this._then);

  final _MembershipModel _self;
  final $Res Function(_MembershipModel) _then;

/// Create a copy of MembershipModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = null,Object? team = null,}) {
  return _then(_MembershipModel(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as MembershipTeamModel,
  ));
}

/// Create a copy of MembershipModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MembershipTeamModelCopyWith<$Res> get team {
  
  return $MembershipTeamModelCopyWith<$Res>(_self.team, (value) {
    return _then(_self.copyWith(team: value));
  });
}
}


/// @nodoc
mixin _$MembershipTeamModel {

 String get id; String get name; String? get avatar;
/// Create a copy of MembershipTeamModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembershipTeamModelCopyWith<MembershipTeamModel> get copyWith => _$MembershipTeamModelCopyWithImpl<MembershipTeamModel>(this as MembershipTeamModel, _$identity);

  /// Serializes this MembershipTeamModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MembershipTeamModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatar, avatar) || other.avatar == avatar));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatar);

@override
String toString() {
  return 'MembershipTeamModel(id: $id, name: $name, avatar: $avatar)';
}


}

/// @nodoc
abstract mixin class $MembershipTeamModelCopyWith<$Res>  {
  factory $MembershipTeamModelCopyWith(MembershipTeamModel value, $Res Function(MembershipTeamModel) _then) = _$MembershipTeamModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? avatar
});




}
/// @nodoc
class _$MembershipTeamModelCopyWithImpl<$Res>
    implements $MembershipTeamModelCopyWith<$Res> {
  _$MembershipTeamModelCopyWithImpl(this._self, this._then);

  final MembershipTeamModel _self;
  final $Res Function(MembershipTeamModel) _then;

/// Create a copy of MembershipTeamModel
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


/// Adds pattern-matching-related methods to [MembershipTeamModel].
extension MembershipTeamModelPatterns on MembershipTeamModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MembershipTeamModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MembershipTeamModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MembershipTeamModel value)  $default,){
final _that = this;
switch (_that) {
case _MembershipTeamModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MembershipTeamModel value)?  $default,){
final _that = this;
switch (_that) {
case _MembershipTeamModel() when $default != null:
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
case _MembershipTeamModel() when $default != null:
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
case _MembershipTeamModel():
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
case _MembershipTeamModel() when $default != null:
return $default(_that.id,_that.name,_that.avatar);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MembershipTeamModel implements MembershipTeamModel {
  const _MembershipTeamModel({required this.id, required this.name, this.avatar});
  factory _MembershipTeamModel.fromJson(Map<String, dynamic> json) => _$MembershipTeamModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? avatar;

/// Create a copy of MembershipTeamModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembershipTeamModelCopyWith<_MembershipTeamModel> get copyWith => __$MembershipTeamModelCopyWithImpl<_MembershipTeamModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MembershipTeamModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MembershipTeamModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatar, avatar) || other.avatar == avatar));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatar);

@override
String toString() {
  return 'MembershipTeamModel(id: $id, name: $name, avatar: $avatar)';
}


}

/// @nodoc
abstract mixin class _$MembershipTeamModelCopyWith<$Res> implements $MembershipTeamModelCopyWith<$Res> {
  factory _$MembershipTeamModelCopyWith(_MembershipTeamModel value, $Res Function(_MembershipTeamModel) _then) = __$MembershipTeamModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? avatar
});




}
/// @nodoc
class __$MembershipTeamModelCopyWithImpl<$Res>
    implements _$MembershipTeamModelCopyWith<$Res> {
  __$MembershipTeamModelCopyWithImpl(this._self, this._then);

  final _MembershipTeamModel _self;
  final $Res Function(_MembershipTeamModel) _then;

/// Create a copy of MembershipTeamModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? avatar = freezed,}) {
  return _then(_MembershipTeamModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
