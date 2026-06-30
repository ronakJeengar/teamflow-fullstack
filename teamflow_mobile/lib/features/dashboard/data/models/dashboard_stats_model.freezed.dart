// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DashboardStatsModel {

 int get tasksDueToday; int get inProgress; int get inReview; int get blocked; int get completedThisWeek; Map<String, List<int>>? get sparklines; int? get project_count; int? get member_count; int? get team_count; int? get task_count; Map<String, dynamic>? get sprintProgress; int? get sprintVelocity;
/// Create a copy of DashboardStatsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardStatsModelCopyWith<DashboardStatsModel> get copyWith => _$DashboardStatsModelCopyWithImpl<DashboardStatsModel>(this as DashboardStatsModel, _$identity);

  /// Serializes this DashboardStatsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardStatsModel&&(identical(other.tasksDueToday, tasksDueToday) || other.tasksDueToday == tasksDueToday)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.inReview, inReview) || other.inReview == inReview)&&(identical(other.blocked, blocked) || other.blocked == blocked)&&(identical(other.completedThisWeek, completedThisWeek) || other.completedThisWeek == completedThisWeek)&&const DeepCollectionEquality().equals(other.sparklines, sparklines)&&(identical(other.project_count, project_count) || other.project_count == project_count)&&(identical(other.member_count, member_count) || other.member_count == member_count)&&(identical(other.team_count, team_count) || other.team_count == team_count)&&(identical(other.task_count, task_count) || other.task_count == task_count)&&const DeepCollectionEquality().equals(other.sprintProgress, sprintProgress)&&(identical(other.sprintVelocity, sprintVelocity) || other.sprintVelocity == sprintVelocity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tasksDueToday,inProgress,inReview,blocked,completedThisWeek,const DeepCollectionEquality().hash(sparklines),project_count,member_count,team_count,task_count,const DeepCollectionEquality().hash(sprintProgress),sprintVelocity);

@override
String toString() {
  return 'DashboardStatsModel(tasksDueToday: $tasksDueToday, inProgress: $inProgress, inReview: $inReview, blocked: $blocked, completedThisWeek: $completedThisWeek, sparklines: $sparklines, project_count: $project_count, member_count: $member_count, team_count: $team_count, task_count: $task_count, sprintProgress: $sprintProgress, sprintVelocity: $sprintVelocity)';
}


}

/// @nodoc
abstract mixin class $DashboardStatsModelCopyWith<$Res>  {
  factory $DashboardStatsModelCopyWith(DashboardStatsModel value, $Res Function(DashboardStatsModel) _then) = _$DashboardStatsModelCopyWithImpl;
@useResult
$Res call({
 int tasksDueToday, int inProgress, int inReview, int blocked, int completedThisWeek, Map<String, List<int>>? sparklines, int? project_count, int? member_count, int? team_count, int? task_count, Map<String, dynamic>? sprintProgress, int? sprintVelocity
});




}
/// @nodoc
class _$DashboardStatsModelCopyWithImpl<$Res>
    implements $DashboardStatsModelCopyWith<$Res> {
  _$DashboardStatsModelCopyWithImpl(this._self, this._then);

  final DashboardStatsModel _self;
  final $Res Function(DashboardStatsModel) _then;

/// Create a copy of DashboardStatsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tasksDueToday = null,Object? inProgress = null,Object? inReview = null,Object? blocked = null,Object? completedThisWeek = null,Object? sparklines = freezed,Object? project_count = freezed,Object? member_count = freezed,Object? team_count = freezed,Object? task_count = freezed,Object? sprintProgress = freezed,Object? sprintVelocity = freezed,}) {
  return _then(_self.copyWith(
tasksDueToday: null == tasksDueToday ? _self.tasksDueToday : tasksDueToday // ignore: cast_nullable_to_non_nullable
as int,inProgress: null == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as int,inReview: null == inReview ? _self.inReview : inReview // ignore: cast_nullable_to_non_nullable
as int,blocked: null == blocked ? _self.blocked : blocked // ignore: cast_nullable_to_non_nullable
as int,completedThisWeek: null == completedThisWeek ? _self.completedThisWeek : completedThisWeek // ignore: cast_nullable_to_non_nullable
as int,sparklines: freezed == sparklines ? _self.sparklines : sparklines // ignore: cast_nullable_to_non_nullable
as Map<String, List<int>>?,project_count: freezed == project_count ? _self.project_count : project_count // ignore: cast_nullable_to_non_nullable
as int?,member_count: freezed == member_count ? _self.member_count : member_count // ignore: cast_nullable_to_non_nullable
as int?,team_count: freezed == team_count ? _self.team_count : team_count // ignore: cast_nullable_to_non_nullable
as int?,task_count: freezed == task_count ? _self.task_count : task_count // ignore: cast_nullable_to_non_nullable
as int?,sprintProgress: freezed == sprintProgress ? _self.sprintProgress : sprintProgress // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,sprintVelocity: freezed == sprintVelocity ? _self.sprintVelocity : sprintVelocity // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardStatsModel].
extension DashboardStatsModelPatterns on DashboardStatsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardStatsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardStatsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardStatsModel value)  $default,){
final _that = this;
switch (_that) {
case _DashboardStatsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardStatsModel value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardStatsModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int tasksDueToday,  int inProgress,  int inReview,  int blocked,  int completedThisWeek,  Map<String, List<int>>? sparklines,  int? project_count,  int? member_count,  int? team_count,  int? task_count,  Map<String, dynamic>? sprintProgress,  int? sprintVelocity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardStatsModel() when $default != null:
return $default(_that.tasksDueToday,_that.inProgress,_that.inReview,_that.blocked,_that.completedThisWeek,_that.sparklines,_that.project_count,_that.member_count,_that.team_count,_that.task_count,_that.sprintProgress,_that.sprintVelocity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int tasksDueToday,  int inProgress,  int inReview,  int blocked,  int completedThisWeek,  Map<String, List<int>>? sparklines,  int? project_count,  int? member_count,  int? team_count,  int? task_count,  Map<String, dynamic>? sprintProgress,  int? sprintVelocity)  $default,) {final _that = this;
switch (_that) {
case _DashboardStatsModel():
return $default(_that.tasksDueToday,_that.inProgress,_that.inReview,_that.blocked,_that.completedThisWeek,_that.sparklines,_that.project_count,_that.member_count,_that.team_count,_that.task_count,_that.sprintProgress,_that.sprintVelocity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int tasksDueToday,  int inProgress,  int inReview,  int blocked,  int completedThisWeek,  Map<String, List<int>>? sparklines,  int? project_count,  int? member_count,  int? team_count,  int? task_count,  Map<String, dynamic>? sprintProgress,  int? sprintVelocity)?  $default,) {final _that = this;
switch (_that) {
case _DashboardStatsModel() when $default != null:
return $default(_that.tasksDueToday,_that.inProgress,_that.inReview,_that.blocked,_that.completedThisWeek,_that.sparklines,_that.project_count,_that.member_count,_that.team_count,_that.task_count,_that.sprintProgress,_that.sprintVelocity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardStatsModel implements DashboardStatsModel {
  const _DashboardStatsModel({required this.tasksDueToday, required this.inProgress, required this.inReview, required this.blocked, required this.completedThisWeek, final  Map<String, List<int>>? sparklines, this.project_count, this.member_count, this.team_count, this.task_count, final  Map<String, dynamic>? sprintProgress, this.sprintVelocity}): _sparklines = sparklines,_sprintProgress = sprintProgress;
  factory _DashboardStatsModel.fromJson(Map<String, dynamic> json) => _$DashboardStatsModelFromJson(json);

@override final  int tasksDueToday;
@override final  int inProgress;
@override final  int inReview;
@override final  int blocked;
@override final  int completedThisWeek;
 final  Map<String, List<int>>? _sparklines;
@override Map<String, List<int>>? get sparklines {
  final value = _sparklines;
  if (value == null) return null;
  if (_sparklines is EqualUnmodifiableMapView) return _sparklines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  int? project_count;
@override final  int? member_count;
@override final  int? team_count;
@override final  int? task_count;
 final  Map<String, dynamic>? _sprintProgress;
@override Map<String, dynamic>? get sprintProgress {
  final value = _sprintProgress;
  if (value == null) return null;
  if (_sprintProgress is EqualUnmodifiableMapView) return _sprintProgress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  int? sprintVelocity;

/// Create a copy of DashboardStatsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardStatsModelCopyWith<_DashboardStatsModel> get copyWith => __$DashboardStatsModelCopyWithImpl<_DashboardStatsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardStatsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardStatsModel&&(identical(other.tasksDueToday, tasksDueToday) || other.tasksDueToday == tasksDueToday)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.inReview, inReview) || other.inReview == inReview)&&(identical(other.blocked, blocked) || other.blocked == blocked)&&(identical(other.completedThisWeek, completedThisWeek) || other.completedThisWeek == completedThisWeek)&&const DeepCollectionEquality().equals(other._sparklines, _sparklines)&&(identical(other.project_count, project_count) || other.project_count == project_count)&&(identical(other.member_count, member_count) || other.member_count == member_count)&&(identical(other.team_count, team_count) || other.team_count == team_count)&&(identical(other.task_count, task_count) || other.task_count == task_count)&&const DeepCollectionEquality().equals(other._sprintProgress, _sprintProgress)&&(identical(other.sprintVelocity, sprintVelocity) || other.sprintVelocity == sprintVelocity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tasksDueToday,inProgress,inReview,blocked,completedThisWeek,const DeepCollectionEquality().hash(_sparklines),project_count,member_count,team_count,task_count,const DeepCollectionEquality().hash(_sprintProgress),sprintVelocity);

@override
String toString() {
  return 'DashboardStatsModel(tasksDueToday: $tasksDueToday, inProgress: $inProgress, inReview: $inReview, blocked: $blocked, completedThisWeek: $completedThisWeek, sparklines: $sparklines, project_count: $project_count, member_count: $member_count, team_count: $team_count, task_count: $task_count, sprintProgress: $sprintProgress, sprintVelocity: $sprintVelocity)';
}


}

/// @nodoc
abstract mixin class _$DashboardStatsModelCopyWith<$Res> implements $DashboardStatsModelCopyWith<$Res> {
  factory _$DashboardStatsModelCopyWith(_DashboardStatsModel value, $Res Function(_DashboardStatsModel) _then) = __$DashboardStatsModelCopyWithImpl;
@override @useResult
$Res call({
 int tasksDueToday, int inProgress, int inReview, int blocked, int completedThisWeek, Map<String, List<int>>? sparklines, int? project_count, int? member_count, int? team_count, int? task_count, Map<String, dynamic>? sprintProgress, int? sprintVelocity
});




}
/// @nodoc
class __$DashboardStatsModelCopyWithImpl<$Res>
    implements _$DashboardStatsModelCopyWith<$Res> {
  __$DashboardStatsModelCopyWithImpl(this._self, this._then);

  final _DashboardStatsModel _self;
  final $Res Function(_DashboardStatsModel) _then;

/// Create a copy of DashboardStatsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tasksDueToday = null,Object? inProgress = null,Object? inReview = null,Object? blocked = null,Object? completedThisWeek = null,Object? sparklines = freezed,Object? project_count = freezed,Object? member_count = freezed,Object? team_count = freezed,Object? task_count = freezed,Object? sprintProgress = freezed,Object? sprintVelocity = freezed,}) {
  return _then(_DashboardStatsModel(
tasksDueToday: null == tasksDueToday ? _self.tasksDueToday : tasksDueToday // ignore: cast_nullable_to_non_nullable
as int,inProgress: null == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as int,inReview: null == inReview ? _self.inReview : inReview // ignore: cast_nullable_to_non_nullable
as int,blocked: null == blocked ? _self.blocked : blocked // ignore: cast_nullable_to_non_nullable
as int,completedThisWeek: null == completedThisWeek ? _self.completedThisWeek : completedThisWeek // ignore: cast_nullable_to_non_nullable
as int,sparklines: freezed == sparklines ? _self._sparklines : sparklines // ignore: cast_nullable_to_non_nullable
as Map<String, List<int>>?,project_count: freezed == project_count ? _self.project_count : project_count // ignore: cast_nullable_to_non_nullable
as int?,member_count: freezed == member_count ? _self.member_count : member_count // ignore: cast_nullable_to_non_nullable
as int?,team_count: freezed == team_count ? _self.team_count : team_count // ignore: cast_nullable_to_non_nullable
as int?,task_count: freezed == task_count ? _self.task_count : task_count // ignore: cast_nullable_to_non_nullable
as int?,sprintProgress: freezed == sprintProgress ? _self._sprintProgress : sprintProgress // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,sprintVelocity: freezed == sprintVelocity ? _self.sprintVelocity : sprintVelocity // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
