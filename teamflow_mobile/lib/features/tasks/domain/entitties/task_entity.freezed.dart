// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskEntity {

 String get id; String get title; String? get description; TaskStatus get status; String get projectId; String get createdById; String? get assignedToId; DateTime get createdAt; DateTime get updatedAt; String? get priority; DateTime? get dueDate; List<String>? get tags; String? get sprintId; int? get storyPoints; String? get backlogStatus; bool get isRecurring; String? get recurrence; String? get parentId;
/// Create a copy of TaskEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskEntityCopyWith<TaskEntity> get copyWith => _$TaskEntityCopyWithImpl<TaskEntity>(this as TaskEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.createdById, createdById) || other.createdById == createdById)&&(identical(other.assignedToId, assignedToId) || other.assignedToId == assignedToId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.sprintId, sprintId) || other.sprintId == sprintId)&&(identical(other.storyPoints, storyPoints) || other.storyPoints == storyPoints)&&(identical(other.backlogStatus, backlogStatus) || other.backlogStatus == backlogStatus)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.recurrence, recurrence) || other.recurrence == recurrence)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,status,projectId,createdById,assignedToId,createdAt,updatedAt,priority,dueDate,const DeepCollectionEquality().hash(tags),sprintId,storyPoints,backlogStatus,isRecurring,recurrence,parentId);

@override
String toString() {
  return 'TaskEntity(id: $id, title: $title, description: $description, status: $status, projectId: $projectId, createdById: $createdById, assignedToId: $assignedToId, createdAt: $createdAt, updatedAt: $updatedAt, priority: $priority, dueDate: $dueDate, tags: $tags, sprintId: $sprintId, storyPoints: $storyPoints, backlogStatus: $backlogStatus, isRecurring: $isRecurring, recurrence: $recurrence, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class $TaskEntityCopyWith<$Res>  {
  factory $TaskEntityCopyWith(TaskEntity value, $Res Function(TaskEntity) _then) = _$TaskEntityCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, TaskStatus status, String projectId, String createdById, String? assignedToId, DateTime createdAt, DateTime updatedAt, String? priority, DateTime? dueDate, List<String>? tags, String? sprintId, int? storyPoints, String? backlogStatus, bool isRecurring, String? recurrence, String? parentId
});




}
/// @nodoc
class _$TaskEntityCopyWithImpl<$Res>
    implements $TaskEntityCopyWith<$Res> {
  _$TaskEntityCopyWithImpl(this._self, this._then);

  final TaskEntity _self;
  final $Res Function(TaskEntity) _then;

/// Create a copy of TaskEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? status = null,Object? projectId = null,Object? createdById = null,Object? assignedToId = freezed,Object? createdAt = null,Object? updatedAt = null,Object? priority = freezed,Object? dueDate = freezed,Object? tags = freezed,Object? sprintId = freezed,Object? storyPoints = freezed,Object? backlogStatus = freezed,Object? isRecurring = null,Object? recurrence = freezed,Object? parentId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,createdById: null == createdById ? _self.createdById : createdById // ignore: cast_nullable_to_non_nullable
as String,assignedToId: freezed == assignedToId ? _self.assignedToId : assignedToId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,tags: freezed == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,sprintId: freezed == sprintId ? _self.sprintId : sprintId // ignore: cast_nullable_to_non_nullable
as String?,storyPoints: freezed == storyPoints ? _self.storyPoints : storyPoints // ignore: cast_nullable_to_non_nullable
as int?,backlogStatus: freezed == backlogStatus ? _self.backlogStatus : backlogStatus // ignore: cast_nullable_to_non_nullable
as String?,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurrence: freezed == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as String?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskEntity].
extension TaskEntityPatterns on TaskEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskEntity value)  $default,){
final _that = this;
switch (_that) {
case _TaskEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TaskEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  TaskStatus status,  String projectId,  String createdById,  String? assignedToId,  DateTime createdAt,  DateTime updatedAt,  String? priority,  DateTime? dueDate,  List<String>? tags,  String? sprintId,  int? storyPoints,  String? backlogStatus,  bool isRecurring,  String? recurrence,  String? parentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskEntity() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.status,_that.projectId,_that.createdById,_that.assignedToId,_that.createdAt,_that.updatedAt,_that.priority,_that.dueDate,_that.tags,_that.sprintId,_that.storyPoints,_that.backlogStatus,_that.isRecurring,_that.recurrence,_that.parentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  TaskStatus status,  String projectId,  String createdById,  String? assignedToId,  DateTime createdAt,  DateTime updatedAt,  String? priority,  DateTime? dueDate,  List<String>? tags,  String? sprintId,  int? storyPoints,  String? backlogStatus,  bool isRecurring,  String? recurrence,  String? parentId)  $default,) {final _that = this;
switch (_that) {
case _TaskEntity():
return $default(_that.id,_that.title,_that.description,_that.status,_that.projectId,_that.createdById,_that.assignedToId,_that.createdAt,_that.updatedAt,_that.priority,_that.dueDate,_that.tags,_that.sprintId,_that.storyPoints,_that.backlogStatus,_that.isRecurring,_that.recurrence,_that.parentId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description,  TaskStatus status,  String projectId,  String createdById,  String? assignedToId,  DateTime createdAt,  DateTime updatedAt,  String? priority,  DateTime? dueDate,  List<String>? tags,  String? sprintId,  int? storyPoints,  String? backlogStatus,  bool isRecurring,  String? recurrence,  String? parentId)?  $default,) {final _that = this;
switch (_that) {
case _TaskEntity() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.status,_that.projectId,_that.createdById,_that.assignedToId,_that.createdAt,_that.updatedAt,_that.priority,_that.dueDate,_that.tags,_that.sprintId,_that.storyPoints,_that.backlogStatus,_that.isRecurring,_that.recurrence,_that.parentId);case _:
  return null;

}
}

}

/// @nodoc


class _TaskEntity implements TaskEntity {
  const _TaskEntity({required this.id, required this.title, this.description, required this.status, required this.projectId, required this.createdById, this.assignedToId, required this.createdAt, required this.updatedAt, this.priority, this.dueDate, final  List<String>? tags, this.sprintId, this.storyPoints, this.backlogStatus, this.isRecurring = false, this.recurrence, this.parentId}): _tags = tags;
  

@override final  String id;
@override final  String title;
@override final  String? description;
@override final  TaskStatus status;
@override final  String projectId;
@override final  String createdById;
@override final  String? assignedToId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? priority;
@override final  DateTime? dueDate;
 final  List<String>? _tags;
@override List<String>? get tags {
  final value = _tags;
  if (value == null) return null;
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? sprintId;
@override final  int? storyPoints;
@override final  String? backlogStatus;
@override@JsonKey() final  bool isRecurring;
@override final  String? recurrence;
@override final  String? parentId;

/// Create a copy of TaskEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskEntityCopyWith<_TaskEntity> get copyWith => __$TaskEntityCopyWithImpl<_TaskEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.createdById, createdById) || other.createdById == createdById)&&(identical(other.assignedToId, assignedToId) || other.assignedToId == assignedToId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.sprintId, sprintId) || other.sprintId == sprintId)&&(identical(other.storyPoints, storyPoints) || other.storyPoints == storyPoints)&&(identical(other.backlogStatus, backlogStatus) || other.backlogStatus == backlogStatus)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.recurrence, recurrence) || other.recurrence == recurrence)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,status,projectId,createdById,assignedToId,createdAt,updatedAt,priority,dueDate,const DeepCollectionEquality().hash(_tags),sprintId,storyPoints,backlogStatus,isRecurring,recurrence,parentId);

@override
String toString() {
  return 'TaskEntity(id: $id, title: $title, description: $description, status: $status, projectId: $projectId, createdById: $createdById, assignedToId: $assignedToId, createdAt: $createdAt, updatedAt: $updatedAt, priority: $priority, dueDate: $dueDate, tags: $tags, sprintId: $sprintId, storyPoints: $storyPoints, backlogStatus: $backlogStatus, isRecurring: $isRecurring, recurrence: $recurrence, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class _$TaskEntityCopyWith<$Res> implements $TaskEntityCopyWith<$Res> {
  factory _$TaskEntityCopyWith(_TaskEntity value, $Res Function(_TaskEntity) _then) = __$TaskEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, TaskStatus status, String projectId, String createdById, String? assignedToId, DateTime createdAt, DateTime updatedAt, String? priority, DateTime? dueDate, List<String>? tags, String? sprintId, int? storyPoints, String? backlogStatus, bool isRecurring, String? recurrence, String? parentId
});




}
/// @nodoc
class __$TaskEntityCopyWithImpl<$Res>
    implements _$TaskEntityCopyWith<$Res> {
  __$TaskEntityCopyWithImpl(this._self, this._then);

  final _TaskEntity _self;
  final $Res Function(_TaskEntity) _then;

/// Create a copy of TaskEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? status = null,Object? projectId = null,Object? createdById = null,Object? assignedToId = freezed,Object? createdAt = null,Object? updatedAt = null,Object? priority = freezed,Object? dueDate = freezed,Object? tags = freezed,Object? sprintId = freezed,Object? storyPoints = freezed,Object? backlogStatus = freezed,Object? isRecurring = null,Object? recurrence = freezed,Object? parentId = freezed,}) {
  return _then(_TaskEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,createdById: null == createdById ? _self.createdById : createdById // ignore: cast_nullable_to_non_nullable
as String,assignedToId: freezed == assignedToId ? _self.assignedToId : assignedToId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,tags: freezed == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,sprintId: freezed == sprintId ? _self.sprintId : sprintId // ignore: cast_nullable_to_non_nullable
as String?,storyPoints: freezed == storyPoints ? _self.storyPoints : storyPoints // ignore: cast_nullable_to_non_nullable
as int?,backlogStatus: freezed == backlogStatus ? _self.backlogStatus : backlogStatus // ignore: cast_nullable_to_non_nullable
as String?,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurrence: freezed == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as String?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
