// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'text_input_field_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TextInputFieldEntity {

 String get value; String? get invalidMessage; bool get isVisiblePassword;
/// Create a copy of TextInputFieldEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextInputFieldEntityCopyWith<TextInputFieldEntity> get copyWith => _$TextInputFieldEntityCopyWithImpl<TextInputFieldEntity>(this as TextInputFieldEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextInputFieldEntity&&(identical(other.value, value) || other.value == value)&&(identical(other.invalidMessage, invalidMessage) || other.invalidMessage == invalidMessage)&&(identical(other.isVisiblePassword, isVisiblePassword) || other.isVisiblePassword == isVisiblePassword));
}


@override
int get hashCode => Object.hash(runtimeType,value,invalidMessage,isVisiblePassword);

@override
String toString() {
  return 'TextInputFieldEntity(value: $value, invalidMessage: $invalidMessage, isVisiblePassword: $isVisiblePassword)';
}


}

/// @nodoc
abstract mixin class $TextInputFieldEntityCopyWith<$Res>  {
  factory $TextInputFieldEntityCopyWith(TextInputFieldEntity value, $Res Function(TextInputFieldEntity) _then) = _$TextInputFieldEntityCopyWithImpl;
@useResult
$Res call({
 String value, String? invalidMessage, bool isVisiblePassword
});




}
/// @nodoc
class _$TextInputFieldEntityCopyWithImpl<$Res>
    implements $TextInputFieldEntityCopyWith<$Res> {
  _$TextInputFieldEntityCopyWithImpl(this._self, this._then);

  final TextInputFieldEntity _self;
  final $Res Function(TextInputFieldEntity) _then;

/// Create a copy of TextInputFieldEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? invalidMessage = freezed,Object? isVisiblePassword = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,invalidMessage: freezed == invalidMessage ? _self.invalidMessage : invalidMessage // ignore: cast_nullable_to_non_nullable
as String?,isVisiblePassword: null == isVisiblePassword ? _self.isVisiblePassword : isVisiblePassword // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TextInputFieldEntity].
extension TextInputFieldEntityPatterns on TextInputFieldEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextInputFieldEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextInputFieldEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextInputFieldEntity value)  $default,){
final _that = this;
switch (_that) {
case _TextInputFieldEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextInputFieldEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TextInputFieldEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  String? invalidMessage,  bool isVisiblePassword)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextInputFieldEntity() when $default != null:
return $default(_that.value,_that.invalidMessage,_that.isVisiblePassword);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  String? invalidMessage,  bool isVisiblePassword)  $default,) {final _that = this;
switch (_that) {
case _TextInputFieldEntity():
return $default(_that.value,_that.invalidMessage,_that.isVisiblePassword);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  String? invalidMessage,  bool isVisiblePassword)?  $default,) {final _that = this;
switch (_that) {
case _TextInputFieldEntity() when $default != null:
return $default(_that.value,_that.invalidMessage,_that.isVisiblePassword);case _:
  return null;

}
}

}

/// @nodoc


class _TextInputFieldEntity implements TextInputFieldEntity {
  const _TextInputFieldEntity({this.value = '', this.invalidMessage, this.isVisiblePassword = false});
  

@override@JsonKey() final  String value;
@override final  String? invalidMessage;
@override@JsonKey() final  bool isVisiblePassword;

/// Create a copy of TextInputFieldEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextInputFieldEntityCopyWith<_TextInputFieldEntity> get copyWith => __$TextInputFieldEntityCopyWithImpl<_TextInputFieldEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextInputFieldEntity&&(identical(other.value, value) || other.value == value)&&(identical(other.invalidMessage, invalidMessage) || other.invalidMessage == invalidMessage)&&(identical(other.isVisiblePassword, isVisiblePassword) || other.isVisiblePassword == isVisiblePassword));
}


@override
int get hashCode => Object.hash(runtimeType,value,invalidMessage,isVisiblePassword);

@override
String toString() {
  return 'TextInputFieldEntity(value: $value, invalidMessage: $invalidMessage, isVisiblePassword: $isVisiblePassword)';
}


}

/// @nodoc
abstract mixin class _$TextInputFieldEntityCopyWith<$Res> implements $TextInputFieldEntityCopyWith<$Res> {
  factory _$TextInputFieldEntityCopyWith(_TextInputFieldEntity value, $Res Function(_TextInputFieldEntity) _then) = __$TextInputFieldEntityCopyWithImpl;
@override @useResult
$Res call({
 String value, String? invalidMessage, bool isVisiblePassword
});




}
/// @nodoc
class __$TextInputFieldEntityCopyWithImpl<$Res>
    implements _$TextInputFieldEntityCopyWith<$Res> {
  __$TextInputFieldEntityCopyWithImpl(this._self, this._then);

  final _TextInputFieldEntity _self;
  final $Res Function(_TextInputFieldEntity) _then;

/// Create a copy of TextInputFieldEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? invalidMessage = freezed,Object? isVisiblePassword = null,}) {
  return _then(_TextInputFieldEntity(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,invalidMessage: freezed == invalidMessage ? _self.invalidMessage : invalidMessage // ignore: cast_nullable_to_non_nullable
as String?,isVisiblePassword: null == isVisiblePassword ? _self.isVisiblePassword : isVisiblePassword // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
