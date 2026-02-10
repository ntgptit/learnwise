// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tts_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TtsStatus {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TtsStatus);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TtsStatus()';
}


}

/// @nodoc
class $TtsStatusCopyWith<$Res>  {
$TtsStatusCopyWith(TtsStatus _, $Res Function(TtsStatus) __);
}


/// Adds pattern-matching-related methods to [TtsStatus].
extension TtsStatusPatterns on TtsStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _TtsStatusIdle value)?  idle,TResult Function( _TtsStatusInitializing value)?  initializing,TResult Function( _TtsStatusLoadingVoices value)?  loadingVoices,TResult Function( _TtsStatusReading value)?  reading,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TtsStatusIdle() when idle != null:
return idle(_that);case _TtsStatusInitializing() when initializing != null:
return initializing(_that);case _TtsStatusLoadingVoices() when loadingVoices != null:
return loadingVoices(_that);case _TtsStatusReading() when reading != null:
return reading(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _TtsStatusIdle value)  idle,required TResult Function( _TtsStatusInitializing value)  initializing,required TResult Function( _TtsStatusLoadingVoices value)  loadingVoices,required TResult Function( _TtsStatusReading value)  reading,}){
final _that = this;
switch (_that) {
case _TtsStatusIdle():
return idle(_that);case _TtsStatusInitializing():
return initializing(_that);case _TtsStatusLoadingVoices():
return loadingVoices(_that);case _TtsStatusReading():
return reading(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _TtsStatusIdle value)?  idle,TResult? Function( _TtsStatusInitializing value)?  initializing,TResult? Function( _TtsStatusLoadingVoices value)?  loadingVoices,TResult? Function( _TtsStatusReading value)?  reading,}){
final _that = this;
switch (_that) {
case _TtsStatusIdle() when idle != null:
return idle(_that);case _TtsStatusInitializing() when initializing != null:
return initializing(_that);case _TtsStatusLoadingVoices() when loadingVoices != null:
return loadingVoices(_that);case _TtsStatusReading() when reading != null:
return reading(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  initializing,TResult Function()?  loadingVoices,TResult Function()?  reading,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TtsStatusIdle() when idle != null:
return idle();case _TtsStatusInitializing() when initializing != null:
return initializing();case _TtsStatusLoadingVoices() when loadingVoices != null:
return loadingVoices();case _TtsStatusReading() when reading != null:
return reading();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  initializing,required TResult Function()  loadingVoices,required TResult Function()  reading,}) {final _that = this;
switch (_that) {
case _TtsStatusIdle():
return idle();case _TtsStatusInitializing():
return initializing();case _TtsStatusLoadingVoices():
return loadingVoices();case _TtsStatusReading():
return reading();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  initializing,TResult? Function()?  loadingVoices,TResult? Function()?  reading,}) {final _that = this;
switch (_that) {
case _TtsStatusIdle() when idle != null:
return idle();case _TtsStatusInitializing() when initializing != null:
return initializing();case _TtsStatusLoadingVoices() when loadingVoices != null:
return loadingVoices();case _TtsStatusReading() when reading != null:
return reading();case _:
  return null;

}
}

}

/// @nodoc


class _TtsStatusIdle implements TtsStatus {
  const _TtsStatusIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TtsStatusIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TtsStatus.idle()';
}


}




/// @nodoc


class _TtsStatusInitializing implements TtsStatus {
  const _TtsStatusInitializing();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TtsStatusInitializing);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TtsStatus.initializing()';
}


}




/// @nodoc


class _TtsStatusLoadingVoices implements TtsStatus {
  const _TtsStatusLoadingVoices();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TtsStatusLoadingVoices);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TtsStatus.loadingVoices()';
}


}




/// @nodoc


class _TtsStatusReading implements TtsStatus {
  const _TtsStatusReading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TtsStatusReading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TtsStatus.reading()';
}


}




/// @nodoc
mixin _$TtsState {

 String get inputText; TtsLanguageMode get languageMode; double get speechRate; double get pitch; double get volume; List<TtsVoiceOption> get voices; String? get selectedVoiceId; TtsStatus get status; bool get isInitialized;
/// Create a copy of TtsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TtsStateCopyWith<TtsState> get copyWith => _$TtsStateCopyWithImpl<TtsState>(this as TtsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TtsState&&(identical(other.inputText, inputText) || other.inputText == inputText)&&(identical(other.languageMode, languageMode) || other.languageMode == languageMode)&&(identical(other.speechRate, speechRate) || other.speechRate == speechRate)&&(identical(other.pitch, pitch) || other.pitch == pitch)&&(identical(other.volume, volume) || other.volume == volume)&&const DeepCollectionEquality().equals(other.voices, voices)&&(identical(other.selectedVoiceId, selectedVoiceId) || other.selectedVoiceId == selectedVoiceId)&&(identical(other.status, status) || other.status == status)&&(identical(other.isInitialized, isInitialized) || other.isInitialized == isInitialized));
}


@override
int get hashCode => Object.hash(runtimeType,inputText,languageMode,speechRate,pitch,volume,const DeepCollectionEquality().hash(voices),selectedVoiceId,status,isInitialized);

@override
String toString() {
  return 'TtsState(inputText: $inputText, languageMode: $languageMode, speechRate: $speechRate, pitch: $pitch, volume: $volume, voices: $voices, selectedVoiceId: $selectedVoiceId, status: $status, isInitialized: $isInitialized)';
}


}

/// @nodoc
abstract mixin class $TtsStateCopyWith<$Res>  {
  factory $TtsStateCopyWith(TtsState value, $Res Function(TtsState) _then) = _$TtsStateCopyWithImpl;
@useResult
$Res call({
 String inputText, TtsLanguageMode languageMode, double speechRate, double pitch, double volume, List<TtsVoiceOption> voices, String? selectedVoiceId, TtsStatus status, bool isInitialized
});


$TtsStatusCopyWith<$Res> get status;

}
/// @nodoc
class _$TtsStateCopyWithImpl<$Res>
    implements $TtsStateCopyWith<$Res> {
  _$TtsStateCopyWithImpl(this._self, this._then);

  final TtsState _self;
  final $Res Function(TtsState) _then;

/// Create a copy of TtsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? inputText = null,Object? languageMode = null,Object? speechRate = null,Object? pitch = null,Object? volume = null,Object? voices = null,Object? selectedVoiceId = freezed,Object? status = null,Object? isInitialized = null,}) {
  return _then(_self.copyWith(
inputText: null == inputText ? _self.inputText : inputText // ignore: cast_nullable_to_non_nullable
as String,languageMode: null == languageMode ? _self.languageMode : languageMode // ignore: cast_nullable_to_non_nullable
as TtsLanguageMode,speechRate: null == speechRate ? _self.speechRate : speechRate // ignore: cast_nullable_to_non_nullable
as double,pitch: null == pitch ? _self.pitch : pitch // ignore: cast_nullable_to_non_nullable
as double,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,voices: null == voices ? _self.voices : voices // ignore: cast_nullable_to_non_nullable
as List<TtsVoiceOption>,selectedVoiceId: freezed == selectedVoiceId ? _self.selectedVoiceId : selectedVoiceId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TtsStatus,isInitialized: null == isInitialized ? _self.isInitialized : isInitialized // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of TtsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TtsStatusCopyWith<$Res> get status {
  
  return $TtsStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}


/// Adds pattern-matching-related methods to [TtsState].
extension TtsStatePatterns on TtsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TtsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TtsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TtsState value)  $default,){
final _that = this;
switch (_that) {
case _TtsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TtsState value)?  $default,){
final _that = this;
switch (_that) {
case _TtsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String inputText,  TtsLanguageMode languageMode,  double speechRate,  double pitch,  double volume,  List<TtsVoiceOption> voices,  String? selectedVoiceId,  TtsStatus status,  bool isInitialized)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TtsState() when $default != null:
return $default(_that.inputText,_that.languageMode,_that.speechRate,_that.pitch,_that.volume,_that.voices,_that.selectedVoiceId,_that.status,_that.isInitialized);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String inputText,  TtsLanguageMode languageMode,  double speechRate,  double pitch,  double volume,  List<TtsVoiceOption> voices,  String? selectedVoiceId,  TtsStatus status,  bool isInitialized)  $default,) {final _that = this;
switch (_that) {
case _TtsState():
return $default(_that.inputText,_that.languageMode,_that.speechRate,_that.pitch,_that.volume,_that.voices,_that.selectedVoiceId,_that.status,_that.isInitialized);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String inputText,  TtsLanguageMode languageMode,  double speechRate,  double pitch,  double volume,  List<TtsVoiceOption> voices,  String? selectedVoiceId,  TtsStatus status,  bool isInitialized)?  $default,) {final _that = this;
switch (_that) {
case _TtsState() when $default != null:
return $default(_that.inputText,_that.languageMode,_that.speechRate,_that.pitch,_that.volume,_that.voices,_that.selectedVoiceId,_that.status,_that.isInitialized);case _:
  return null;

}
}

}

/// @nodoc


class _TtsState implements TtsState {
  const _TtsState({required this.inputText, required this.languageMode, required this.speechRate, required this.pitch, required this.volume, required final  List<TtsVoiceOption> voices, required this.selectedVoiceId, required this.status, required this.isInitialized}): _voices = voices;
  

@override final  String inputText;
@override final  TtsLanguageMode languageMode;
@override final  double speechRate;
@override final  double pitch;
@override final  double volume;
 final  List<TtsVoiceOption> _voices;
@override List<TtsVoiceOption> get voices {
  if (_voices is EqualUnmodifiableListView) return _voices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_voices);
}

@override final  String? selectedVoiceId;
@override final  TtsStatus status;
@override final  bool isInitialized;

/// Create a copy of TtsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TtsStateCopyWith<_TtsState> get copyWith => __$TtsStateCopyWithImpl<_TtsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TtsState&&(identical(other.inputText, inputText) || other.inputText == inputText)&&(identical(other.languageMode, languageMode) || other.languageMode == languageMode)&&(identical(other.speechRate, speechRate) || other.speechRate == speechRate)&&(identical(other.pitch, pitch) || other.pitch == pitch)&&(identical(other.volume, volume) || other.volume == volume)&&const DeepCollectionEquality().equals(other._voices, _voices)&&(identical(other.selectedVoiceId, selectedVoiceId) || other.selectedVoiceId == selectedVoiceId)&&(identical(other.status, status) || other.status == status)&&(identical(other.isInitialized, isInitialized) || other.isInitialized == isInitialized));
}


@override
int get hashCode => Object.hash(runtimeType,inputText,languageMode,speechRate,pitch,volume,const DeepCollectionEquality().hash(_voices),selectedVoiceId,status,isInitialized);

@override
String toString() {
  return 'TtsState(inputText: $inputText, languageMode: $languageMode, speechRate: $speechRate, pitch: $pitch, volume: $volume, voices: $voices, selectedVoiceId: $selectedVoiceId, status: $status, isInitialized: $isInitialized)';
}


}

/// @nodoc
abstract mixin class _$TtsStateCopyWith<$Res> implements $TtsStateCopyWith<$Res> {
  factory _$TtsStateCopyWith(_TtsState value, $Res Function(_TtsState) _then) = __$TtsStateCopyWithImpl;
@override @useResult
$Res call({
 String inputText, TtsLanguageMode languageMode, double speechRate, double pitch, double volume, List<TtsVoiceOption> voices, String? selectedVoiceId, TtsStatus status, bool isInitialized
});


@override $TtsStatusCopyWith<$Res> get status;

}
/// @nodoc
class __$TtsStateCopyWithImpl<$Res>
    implements _$TtsStateCopyWith<$Res> {
  __$TtsStateCopyWithImpl(this._self, this._then);

  final _TtsState _self;
  final $Res Function(_TtsState) _then;

/// Create a copy of TtsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? inputText = null,Object? languageMode = null,Object? speechRate = null,Object? pitch = null,Object? volume = null,Object? voices = null,Object? selectedVoiceId = freezed,Object? status = null,Object? isInitialized = null,}) {
  return _then(_TtsState(
inputText: null == inputText ? _self.inputText : inputText // ignore: cast_nullable_to_non_nullable
as String,languageMode: null == languageMode ? _self.languageMode : languageMode // ignore: cast_nullable_to_non_nullable
as TtsLanguageMode,speechRate: null == speechRate ? _self.speechRate : speechRate // ignore: cast_nullable_to_non_nullable
as double,pitch: null == pitch ? _self.pitch : pitch // ignore: cast_nullable_to_non_nullable
as double,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,voices: null == voices ? _self._voices : voices // ignore: cast_nullable_to_non_nullable
as List<TtsVoiceOption>,selectedVoiceId: freezed == selectedVoiceId ? _self.selectedVoiceId : selectedVoiceId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TtsStatus,isInitialized: null == isInitialized ? _self.isInitialized : isInitialized // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of TtsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TtsStatusCopyWith<$Res> get status {
  
  return $TtsStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}

// dart format on
