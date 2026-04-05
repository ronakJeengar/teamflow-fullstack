// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TeamEntity {

 String get id; String get name; String? get description; String? get avatar; String get ownerId; List<TeamMemberEntity> get members; List<ProjectEntity> get projects; List<TeamInvitationEntity> get invitations; String get createdAt; String get updatedAt;
/// Create a copy of TeamEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamEntityCopyWith<TeamEntity> get copyWith => _$TeamEntityCopyWithImpl<TeamEntity>(this as TeamEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&const DeepCollectionEquality().equals(other.members, members)&&const DeepCollectionEquality().equals(other.projects, projects)&&const DeepCollectionEquality().equals(other.invitations, invitations)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,avatar,ownerId,const DeepCollectionEquality().hash(members),const DeepCollectionEquality().hash(projects),const DeepCollectionEquality().hash(invitations),createdAt,updatedAt);

@override
String toString() {
  return 'TeamEntity(id: $id, name: $name, description: $description, avatar: $avatar, ownerId: $ownerId, members: $members, projects: $projects, invitations: $invitations, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TeamEntityCopyWith<$Res>  {
  factory $TeamEntityCopyWith(TeamEntity value, $Res Function(TeamEntity) _then) = _$TeamEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, String? avatar, String ownerId, List<TeamMemberEntity> members, List<ProjectEntity> projects, List<TeamInvitationEntity> invitations, String createdAt, String updatedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? avatar = freezed,Object? ownerId = null,Object? members = null,Object? projects = null,Object? invitations = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<TeamMemberEntity>,projects: null == projects ? _self.projects : projects // ignore: cast_nullable_to_non_nullable
as List<ProjectEntity>,invitations: null == invitations ? _self.invitations : invitations // ignore: cast_nullable_to_non_nullable
as List<TeamInvitationEntity>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String? avatar,  String ownerId,  List<TeamMemberEntity> members,  List<ProjectEntity> projects,  List<TeamInvitationEntity> invitations,  String createdAt,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamEntity() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String? avatar,  String ownerId,  List<TeamMemberEntity> members,  List<ProjectEntity> projects,  List<TeamInvitationEntity> invitations,  String createdAt,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _TeamEntity():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  String? avatar,  String ownerId,  List<TeamMemberEntity> members,  List<ProjectEntity> projects,  List<TeamInvitationEntity> invitations,  String createdAt,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TeamEntity() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.avatar,_that.ownerId,_that.members,_that.projects,_that.invitations,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _TeamEntity implements TeamEntity {
  const _TeamEntity({required this.id, required this.name, this.description, this.avatar, required this.ownerId, final  List<TeamMemberEntity> members = const [], final  List<ProjectEntity> projects = const [], final  List<TeamInvitationEntity> invitations = const [], required this.createdAt, required this.updatedAt}): _members = members,_projects = projects,_invitations = invitations;
  

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  String? avatar;
@override final  String ownerId;
 final  List<TeamMemberEntity> _members;
@override@JsonKey() List<TeamMemberEntity> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

 final  List<ProjectEntity> _projects;
@override@JsonKey() List<ProjectEntity> get projects {
  if (_projects is EqualUnmodifiableListView) return _projects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_projects);
}

 final  List<TeamInvitationEntity> _invitations;
@override@JsonKey() List<TeamInvitationEntity> get invitations {
  if (_invitations is EqualUnmodifiableListView) return _invitations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_invitations);
}

@override final  String createdAt;
@override final  String updatedAt;

/// Create a copy of TeamEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamEntityCopyWith<_TeamEntity> get copyWith => __$TeamEntityCopyWithImpl<_TeamEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&const DeepCollectionEquality().equals(other._members, _members)&&const DeepCollectionEquality().equals(other._projects, _projects)&&const DeepCollectionEquality().equals(other._invitations, _invitations)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,avatar,ownerId,const DeepCollectionEquality().hash(_members),const DeepCollectionEquality().hash(_projects),const DeepCollectionEquality().hash(_invitations),createdAt,updatedAt);

@override
String toString() {
  return 'TeamEntity(id: $id, name: $name, description: $description, avatar: $avatar, ownerId: $ownerId, members: $members, projects: $projects, invitations: $invitations, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TeamEntityCopyWith<$Res> implements $TeamEntityCopyWith<$Res> {
  factory _$TeamEntityCopyWith(_TeamEntity value, $Res Function(_TeamEntity) _then) = __$TeamEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, String? avatar, String ownerId, List<TeamMemberEntity> members, List<ProjectEntity> projects, List<TeamInvitationEntity> invitations, String createdAt, String updatedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? avatar = freezed,Object? ownerId = null,Object? members = null,Object? projects = null,Object? invitations = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_TeamEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<TeamMemberEntity>,projects: null == projects ? _self._projects : projects // ignore: cast_nullable_to_non_nullable
as List<ProjectEntity>,invitations: null == invitations ? _self._invitations : invitations // ignore: cast_nullable_to_non_nullable
as List<TeamInvitationEntity>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
