// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Team {

 String get id; String get name; String? get description; String? get avatar; String get ownerId; List<TeamMember> get members; List<Project> get projects; List<TeamInvitation> get invitations; String get createdAt; String get updatedAt;
/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamCopyWith<Team> get copyWith => _$TeamCopyWithImpl<Team>(this as Team, _$identity);

  /// Serializes this Team to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Team&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&const DeepCollectionEquality().equals(other.members, members)&&const DeepCollectionEquality().equals(other.projects, projects)&&const DeepCollectionEquality().equals(other.invitations, invitations)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,avatar,ownerId,const DeepCollectionEquality().hash(members),const DeepCollectionEquality().hash(projects),const DeepCollectionEquality().hash(invitations),createdAt,updatedAt);

@override
String toString() {
  return 'Team(id: $id, name: $name, description: $description, avatar: $avatar, ownerId: $ownerId, members: $members, projects: $projects, invitations: $invitations, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TeamCopyWith<$Res>  {
  factory $TeamCopyWith(Team value, $Res Function(Team) _then) = _$TeamCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, String? avatar, String ownerId, List<TeamMember> members, List<Project> projects, List<TeamInvitation> invitations, String createdAt, String updatedAt
});




}
/// @nodoc
class _$TeamCopyWithImpl<$Res>
    implements $TeamCopyWith<$Res> {
  _$TeamCopyWithImpl(this._self, this._then);

  final Team _self;
  final $Res Function(Team) _then;

/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? avatar = freezed,Object? ownerId = null,Object? members = null,Object? projects = null,Object? invitations = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<TeamMember>,projects: null == projects ? _self.projects : projects // ignore: cast_nullable_to_non_nullable
as List<Project>,invitations: null == invitations ? _self.invitations : invitations // ignore: cast_nullable_to_non_nullable
as List<TeamInvitation>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Team].
extension TeamPatterns on Team {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Team value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Team() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Team value)  $default,){
final _that = this;
switch (_that) {
case _Team():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Team value)?  $default,){
final _that = this;
switch (_that) {
case _Team() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String? avatar,  String ownerId,  List<TeamMember> members,  List<Project> projects,  List<TeamInvitation> invitations,  String createdAt,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Team() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.avatar,_that.ownerId,_that.members,_that.projects,_that.invitations,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String? avatar,  String ownerId,  List<TeamMember> members,  List<Project> projects,  List<TeamInvitation> invitations,  String createdAt,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Team():
return $default(_that.id,_that.name,_that.description,_that.avatar,_that.ownerId,_that.members,_that.projects,_that.invitations,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  String? avatar,  String ownerId,  List<TeamMember> members,  List<Project> projects,  List<TeamInvitation> invitations,  String createdAt,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Team() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.avatar,_that.ownerId,_that.members,_that.projects,_that.invitations,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Team implements Team {
  const _Team({required this.id, required this.name, this.description, this.avatar, required this.ownerId, final  List<TeamMember> members = const [], final  List<Project> projects = const [], final  List<TeamInvitation> invitations = const [], required this.createdAt, required this.updatedAt}): _members = members,_projects = projects,_invitations = invitations;
  factory _Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  String? avatar;
@override final  String ownerId;
 final  List<TeamMember> _members;
@override@JsonKey() List<TeamMember> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

 final  List<Project> _projects;
@override@JsonKey() List<Project> get projects {
  if (_projects is EqualUnmodifiableListView) return _projects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_projects);
}

 final  List<TeamInvitation> _invitations;
@override@JsonKey() List<TeamInvitation> get invitations {
  if (_invitations is EqualUnmodifiableListView) return _invitations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_invitations);
}

@override final  String createdAt;
@override final  String updatedAt;

/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamCopyWith<_Team> get copyWith => __$TeamCopyWithImpl<_Team>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Team&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&const DeepCollectionEquality().equals(other._members, _members)&&const DeepCollectionEquality().equals(other._projects, _projects)&&const DeepCollectionEquality().equals(other._invitations, _invitations)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,avatar,ownerId,const DeepCollectionEquality().hash(_members),const DeepCollectionEquality().hash(_projects),const DeepCollectionEquality().hash(_invitations),createdAt,updatedAt);

@override
String toString() {
  return 'Team(id: $id, name: $name, description: $description, avatar: $avatar, ownerId: $ownerId, members: $members, projects: $projects, invitations: $invitations, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TeamCopyWith<$Res> implements $TeamCopyWith<$Res> {
  factory _$TeamCopyWith(_Team value, $Res Function(_Team) _then) = __$TeamCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, String? avatar, String ownerId, List<TeamMember> members, List<Project> projects, List<TeamInvitation> invitations, String createdAt, String updatedAt
});




}
/// @nodoc
class __$TeamCopyWithImpl<$Res>
    implements _$TeamCopyWith<$Res> {
  __$TeamCopyWithImpl(this._self, this._then);

  final _Team _self;
  final $Res Function(_Team) _then;

/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? avatar = freezed,Object? ownerId = null,Object? members = null,Object? projects = null,Object? invitations = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Team(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<TeamMember>,projects: null == projects ? _self._projects : projects // ignore: cast_nullable_to_non_nullable
as List<Project>,invitations: null == invitations ? _self._invitations : invitations // ignore: cast_nullable_to_non_nullable
as List<TeamInvitation>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
