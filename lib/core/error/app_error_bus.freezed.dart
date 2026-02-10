// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_error_bus.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppErrorEvent {

 int get id; AppErrorCode get code;
/// Create a copy of AppErrorEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppErrorEventCopyWith<AppErrorEvent> get copyWith => _$AppErrorEventCopyWithImpl<AppErrorEvent>(this as AppErrorEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppErrorEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,id,code);

@override
String toString() {
  return 'AppErrorEvent(id: $id, code: $code)';
}


}

/// @nodoc
abstract mixin class $AppErrorEventCopyWith<$Res>  {
  factory $AppErrorEventCopyWith(AppErrorEvent value, $Res Function(AppErrorEvent) _then) = _$AppErrorEventCopyWithImpl;
@useResult
$Res call({
 int id, AppErrorCode code
});




}
/// @nodoc
class _$AppErrorEventCopyWithImpl<$Res>
    implements $AppErrorEventCopyWith<$Res> {
  _$AppErrorEventCopyWithImpl(this._self, this._then);

  final AppErrorEvent _self;
  final $Res Function(AppErrorEvent) _then;

/// Create a copy of AppErrorEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as AppErrorCode,
  ));
}

}


/// Adds pattern-matching-related methods to [AppErrorEvent].
extension AppErrorEventPatterns on AppErrorEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppErrorEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppErrorEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppErrorEvent value)  $default,){
final _that = this;
switch (_that) {
case _AppErrorEvent():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppErrorEvent value)?  $default,){
final _that = this;
switch (_that) {
case _AppErrorEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  AppErrorCode code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppErrorEvent() when $default != null:
return $default(_that.id,_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  AppErrorCode code)  $default,) {final _that = this;
switch (_that) {
case _AppErrorEvent():
return $default(_that.id,_that.code);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  AppErrorCode code)?  $default,) {final _that = this;
switch (_that) {
case _AppErrorEvent() when $default != null:
return $default(_that.id,_that.code);case _:
  return null;

}
}

}

/// @nodoc


class _AppErrorEvent implements AppErrorEvent {
  const _AppErrorEvent({required this.id, required this.code});
  

@override final  int id;
@override final  AppErrorCode code;

/// Create a copy of AppErrorEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppErrorEventCopyWith<_AppErrorEvent> get copyWith => __$AppErrorEventCopyWithImpl<_AppErrorEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppErrorEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,id,code);

@override
String toString() {
  return 'AppErrorEvent(id: $id, code: $code)';
}


}

/// @nodoc
abstract mixin class _$AppErrorEventCopyWith<$Res> implements $AppErrorEventCopyWith<$Res> {
  factory _$AppErrorEventCopyWith(_AppErrorEvent value, $Res Function(_AppErrorEvent) _then) = __$AppErrorEventCopyWithImpl;
@override @useResult
$Res call({
 int id, AppErrorCode code
});




}
/// @nodoc
class __$AppErrorEventCopyWithImpl<$Res>
    implements _$AppErrorEventCopyWith<$Res> {
  __$AppErrorEventCopyWithImpl(this._self, this._then);

  final _AppErrorEvent _self;
  final $Res Function(_AppErrorEvent) _then;

/// Create a copy of AppErrorEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,}) {
  return _then(_AppErrorEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as AppErrorCode,
  ));
}


}

// dart format on
