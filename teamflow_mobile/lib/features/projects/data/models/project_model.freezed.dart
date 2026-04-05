// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProjectCount {

 int get tasks;
/// Create a copy of ProjectCount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectCountCopyWith<ProjectCount> get copyWith => _$ProjectCountCopyWithImpl<ProjectCount>(this as ProjectCount, _$identity);

  /// Serializes this ProjectCount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectCount&&(identical(other.tasks, tasks) || other.tasks == tasks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tasks);

@override
String toString() {
  return 'ProjectCount(tasks: $tasks)';
}


}

/// @nodoc
abstract mixin class $ProjectCountCopyWith<$Res>  {
  factory $ProjectCountCopyWith(ProjectCount value, $Res Function(ProjectCount) _then) = _$ProjectCountCopyWithImpl;
@useResult
$Res call({
 int tasks
});




}
/// @nodoc
class _$ProjectCountCopyWithImpl<$Res>
    implements $ProjectCountCopyWith<$Res> {
  _$ProjectCountCopyWithImpl(this._self, this._then);

  final ProjectCount _self;
  final $Res Function(ProjectCount) _then;

/// Create a copy of ProjectCount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tasks = null,}) {
  return _then(_self.copyWith(
tasks: null == tasks ? _self.tasks : tasks // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectCount].
extension ProjectCountPatterns on ProjectCount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectCount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectCount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectCount value)  $default,){
final _that = this;
switch (_that) {
case _ProjectCount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectCount value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectCount() when $default != null:
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
case _ProjectCount() when $default != null:
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
case _ProjectCount():
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
case _ProjectCount() when $default != null:
return $default(_that.tasks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectCount implements ProjectCount {
  const _ProjectCount({required this.tasks});
  factory _ProjectCount.fromJson(Map<String, dynamic> json) => _$ProjectCountFromJson(json);

@override final  int tasks;

/// Create a copy of ProjectCount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectCountCopyWith<_ProjectCount> get copyWith => __$ProjectCountCopyWithImpl<_ProjectCount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectCountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectCount&&(identical(other.tasks, tasks) || other.tasks == tasks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tasks);

@override
String toString() {
  return 'ProjectCount(tasks: $tasks)';
}


}

/// @nodoc
abstract mixin class _$ProjectCountCopyWith<$Res> implements $ProjectCountCopyWith<$Res> {
  factory _$ProjectCountCopyWith(_ProjectCount value, $Res Function(_ProjectCount) _then) = __$ProjectCountCopyWithImpl;
@override @useResult
$Res call({
 int tasks
});




}
/// @nodoc
class __$ProjectCountCopyWithImpl<$Res>
    implements _$ProjectCountCopyWith<$Res> {
  __$ProjectCountCopyWithImpl(this._self, this._then);

  final _ProjectCount _self;
  final $Res Function(_ProjectCount) _then;

/// Create a copy of ProjectCount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tasks = null,}) {
  return _then(_ProjectCount(
tasks: null == tasks ? _self.tasks : tasks // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Project {

 String get id; String get name; String get ownerId; String get createdAt;@JsonKey(name: '_count') ProjectCount? get count;
/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectCopyWith<Project> get copyWith => _$ProjectCopyWithImpl<Project>(this as Project, _$identity);

  /// Serializes this Project to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Project&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,ownerId,createdAt,count);

@override
String toString() {
  return 'Project(id: $id, name: $name, ownerId: $ownerId, createdAt: $createdAt, count: $count)';
}


}

/// @nodoc
abstract mixin class $ProjectCopyWith<$Res>  {
  factory $ProjectCopyWith(Project value, $Res Function(Project) _then) = _$ProjectCopyWithImpl;
@useResult
$Res call({
 String id, String name, String ownerId, String createdAt,@JsonKey(name: '_count') ProjectCount? count
});


$ProjectCountCopyWith<$Res>? get count;

}
/// @nodoc
class _$ProjectCopyWithImpl<$Res>
    implements $ProjectCopyWith<$Res> {
  _$ProjectCopyWithImpl(this._self, this._then);

  final Project _self;
  final $Res Function(Project) _then;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? ownerId = null,Object? createdAt = null,Object? count = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as ProjectCount?,
  ));
}
/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProjectCountCopyWith<$Res>? get count {
    if (_self.count == null) {
    return null;
  }

  return $ProjectCountCopyWith<$Res>(_self.count!, (value) {
    return _then(_self.copyWith(count: value));
  });
}
}


/// Adds pattern-matching-related methods to [Project].
extension ProjectPatterns on Project {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Project value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Project() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Project value)  $default,){
final _that = this;
switch (_that) {
case _Project():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Project value)?  $default,){
final _that = this;
switch (_that) {
case _Project() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String ownerId,  String createdAt, @JsonKey(name: '_count')  ProjectCount? count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Project() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String ownerId,  String createdAt, @JsonKey(name: '_count')  ProjectCount? count)  $default,) {final _that = this;
switch (_that) {
case _Project():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String ownerId,  String createdAt, @JsonKey(name: '_count')  ProjectCount? count)?  $default,) {final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that.id,_that.name,_that.ownerId,_that.createdAt,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Project implements Project {
  const _Project({required this.id, required this.name, required this.ownerId, required this.createdAt, @JsonKey(name: '_count') this.count});
  factory _Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

@override final  String id;
@override final  String name;
@override final  String ownerId;
@override final  String createdAt;
@override@JsonKey(name: '_count') final  ProjectCount? count;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectCopyWith<_Project> get copyWith => __$ProjectCopyWithImpl<_Project>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Project&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,ownerId,createdAt,count);

@override
String toString() {
  return 'Project(id: $id, name: $name, ownerId: $ownerId, createdAt: $createdAt, count: $count)';
}


}

/// @nodoc
abstract mixin class _$ProjectCopyWith<$Res> implements $ProjectCopyWith<$Res> {
  factory _$ProjectCopyWith(_Project value, $Res Function(_Project) _then) = __$ProjectCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String ownerId, String createdAt,@JsonKey(name: '_count') ProjectCount? count
});


@override $ProjectCountCopyWith<$Res>? get count;

}
/// @nodoc
class __$ProjectCopyWithImpl<$Res>
    implements _$ProjectCopyWith<$Res> {
  __$ProjectCopyWithImpl(this._self, this._then);

  final _Project _self;
  final $Res Function(_Project) _then;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? ownerId = null,Object? createdAt = null,Object? count = freezed,}) {
  return _then(_Project(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as ProjectCount?,
  ));
}

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProjectCountCopyWith<$Res>? get count {
    if (_self.count == null) {
    return null;
  }

  return $ProjectCountCopyWith<$Res>(_self.count!, (value) {
    return _then(_self.copyWith(count: value));
  });
}
}

// dart format on
