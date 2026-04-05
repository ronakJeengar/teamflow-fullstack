// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProjectCountEntity {

 int get tasks;
/// Create a copy of ProjectCountEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectCountEntityCopyWith<ProjectCountEntity> get copyWith => _$ProjectCountEntityCopyWithImpl<ProjectCountEntity>(this as ProjectCountEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectCountEntity&&(identical(other.tasks, tasks) || other.tasks == tasks));
}


@override
int get hashCode => Object.hash(runtimeType,tasks);

@override
String toString() {
  return 'ProjectCountEntity(tasks: $tasks)';
}


}

/// @nodoc
abstract mixin class $ProjectCountEntityCopyWith<$Res>  {
  factory $ProjectCountEntityCopyWith(ProjectCountEntity value, $Res Function(ProjectCountEntity) _then) = _$ProjectCountEntityCopyWithImpl;
@useResult
$Res call({
 int tasks
});




}
/// @nodoc
class _$ProjectCountEntityCopyWithImpl<$Res>
    implements $ProjectCountEntityCopyWith<$Res> {
  _$ProjectCountEntityCopyWithImpl(this._self, this._then);

  final ProjectCountEntity _self;
  final $Res Function(ProjectCountEntity) _then;

/// Create a copy of ProjectCountEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tasks = null,}) {
  return _then(_self.copyWith(
tasks: null == tasks ? _self.tasks : tasks // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectCountEntity].
extension ProjectCountEntityPatterns on ProjectCountEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectCountEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectCountEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectCountEntity value)  $default,){
final _that = this;
switch (_that) {
case _ProjectCountEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectCountEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectCountEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int tasks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectCountEntity() when $default != null:
return $default(_that.tasks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int tasks)  $default,) {final _that = this;
switch (_that) {
case _ProjectCountEntity():
return $default(_that.tasks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int tasks)?  $default,) {final _that = this;
switch (_that) {
case _ProjectCountEntity() when $default != null:
return $default(_that.tasks);case _:
  return null;

}
}

}

/// @nodoc


class _ProjectCountEntity implements ProjectCountEntity {
  const _ProjectCountEntity({required this.tasks});
  

@override final  int tasks;

/// Create a copy of ProjectCountEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectCountEntityCopyWith<_ProjectCountEntity> get copyWith => __$ProjectCountEntityCopyWithImpl<_ProjectCountEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectCountEntity&&(identical(other.tasks, tasks) || other.tasks == tasks));
}


@override
int get hashCode => Object.hash(runtimeType,tasks);

@override
String toString() {
  return 'ProjectCountEntity(tasks: $tasks)';
}


}

/// @nodoc
abstract mixin class _$ProjectCountEntityCopyWith<$Res> implements $ProjectCountEntityCopyWith<$Res> {
  factory _$ProjectCountEntityCopyWith(_ProjectCountEntity value, $Res Function(_ProjectCountEntity) _then) = __$ProjectCountEntityCopyWithImpl;
@override @useResult
$Res call({
 int tasks
});




}
/// @nodoc
class __$ProjectCountEntityCopyWithImpl<$Res>
    implements _$ProjectCountEntityCopyWith<$Res> {
  __$ProjectCountEntityCopyWithImpl(this._self, this._then);

  final _ProjectCountEntity _self;
  final $Res Function(_ProjectCountEntity) _then;

/// Create a copy of ProjectCountEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tasks = null,}) {
  return _then(_ProjectCountEntity(
tasks: null == tasks ? _self.tasks : tasks // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ProjectEntity {

 String get id; String get name; String get ownerId; String get createdAt; ProjectCountEntity? get count;
/// Create a copy of ProjectEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectEntityCopyWith<ProjectEntity> get copyWith => _$ProjectEntityCopyWithImpl<ProjectEntity>(this as ProjectEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,ownerId,createdAt,count);

@override
String toString() {
  return 'ProjectEntity(id: $id, name: $name, ownerId: $ownerId, createdAt: $createdAt, count: $count)';
}


}

/// @nodoc
abstract mixin class $ProjectEntityCopyWith<$Res>  {
  factory $ProjectEntityCopyWith(ProjectEntity value, $Res Function(ProjectEntity) _then) = _$ProjectEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String ownerId, String createdAt, ProjectCountEntity? count
});


$ProjectCountEntityCopyWith<$Res>? get count;

}
/// @nodoc
class _$ProjectEntityCopyWithImpl<$Res>
    implements $ProjectEntityCopyWith<$Res> {
  _$ProjectEntityCopyWithImpl(this._self, this._then);

  final ProjectEntity _self;
  final $Res Function(ProjectEntity) _then;

/// Create a copy of ProjectEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? ownerId = null,Object? createdAt = null,Object? count = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as ProjectCountEntity?,
  ));
}
/// Create a copy of ProjectEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProjectCountEntityCopyWith<$Res>? get count {
    if (_self.count == null) {
    return null;
  }

  return $ProjectCountEntityCopyWith<$Res>(_self.count!, (value) {
    return _then(_self.copyWith(count: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProjectEntity].
extension ProjectEntityPatterns on ProjectEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectEntity value)  $default,){
final _that = this;
switch (_that) {
case _ProjectEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String ownerId,  String createdAt,  ProjectCountEntity? count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectEntity() when $default != null:
return $default(_that.id,_that.name,_that.ownerId,_that.createdAt,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String ownerId,  String createdAt,  ProjectCountEntity? count)  $default,) {final _that = this;
switch (_that) {
case _ProjectEntity():
return $default(_that.id,_that.name,_that.ownerId,_that.createdAt,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String ownerId,  String createdAt,  ProjectCountEntity? count)?  $default,) {final _that = this;
switch (_that) {
case _ProjectEntity() when $default != null:
return $default(_that.id,_that.name,_that.ownerId,_that.createdAt,_that.count);case _:
  return null;

}
}

}

/// @nodoc


class _ProjectEntity implements ProjectEntity {
  const _ProjectEntity({required this.id, required this.name, required this.ownerId, required this.createdAt, this.count});
  

@override final  String id;
@override final  String name;
@override final  String ownerId;
@override final  String createdAt;
@override final  ProjectCountEntity? count;

/// Create a copy of ProjectEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectEntityCopyWith<_ProjectEntity> get copyWith => __$ProjectEntityCopyWithImpl<_ProjectEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,ownerId,createdAt,count);

@override
String toString() {
  return 'ProjectEntity(id: $id, name: $name, ownerId: $ownerId, createdAt: $createdAt, count: $count)';
}


}

/// @nodoc
abstract mixin class _$ProjectEntityCopyWith<$Res> implements $ProjectEntityCopyWith<$Res> {
  factory _$ProjectEntityCopyWith(_ProjectEntity value, $Res Function(_ProjectEntity) _then) = __$ProjectEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String ownerId, String createdAt, ProjectCountEntity? count
});


@override $ProjectCountEntityCopyWith<$Res>? get count;

}
/// @nodoc
class __$ProjectEntityCopyWithImpl<$Res>
    implements _$ProjectEntityCopyWith<$Res> {
  __$ProjectEntityCopyWithImpl(this._self, this._then);

  final _ProjectEntity _self;
  final $Res Function(_ProjectEntity) _then;

/// Create a copy of ProjectEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? ownerId = null,Object? createdAt = null,Object? count = freezed,}) {
  return _then(_ProjectEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as ProjectCountEntity?,
  ));
}

/// Create a copy of ProjectEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProjectCountEntityCopyWith<$Res>? get count {
    if (_self.count == null) {
    return null;
  }

  return $ProjectCountEntityCopyWith<$Res>(_self.count!, (value) {
    return _then(_self.copyWith(count: value));
  });
}
}

// dart format on
