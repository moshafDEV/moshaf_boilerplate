// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_param_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoginParamEntity {

 String get email; String get password; int? get forceLogin;
/// Create a copy of LoginParamEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginParamEntityCopyWith<LoginParamEntity> get copyWith => _$LoginParamEntityCopyWithImpl<LoginParamEntity>(this as LoginParamEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginParamEntity&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.forceLogin, forceLogin) || other.forceLogin == forceLogin));
}


@override
int get hashCode => Object.hash(runtimeType,email,password,forceLogin);

@override
String toString() {
  return 'LoginParamEntity(email: $email, password: $password, forceLogin: $forceLogin)';
}


}

/// @nodoc
abstract mixin class $LoginParamEntityCopyWith<$Res>  {
  factory $LoginParamEntityCopyWith(LoginParamEntity value, $Res Function(LoginParamEntity) _then) = _$LoginParamEntityCopyWithImpl;
@useResult
$Res call({
 String email, String password, int? forceLogin
});




}
/// @nodoc
class _$LoginParamEntityCopyWithImpl<$Res>
    implements $LoginParamEntityCopyWith<$Res> {
  _$LoginParamEntityCopyWithImpl(this._self, this._then);

  final LoginParamEntity _self;
  final $Res Function(LoginParamEntity) _then;

/// Create a copy of LoginParamEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,Object? forceLogin = freezed,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,forceLogin: freezed == forceLogin ? _self.forceLogin : forceLogin // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginParamEntity].
extension LoginParamEntityPatterns on LoginParamEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginParamEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginParamEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginParamEntity value)  $default,){
final _that = this;
switch (_that) {
case _LoginParamEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginParamEntity value)?  $default,){
final _that = this;
switch (_that) {
case _LoginParamEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String password,  int? forceLogin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginParamEntity() when $default != null:
return $default(_that.email,_that.password,_that.forceLogin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String password,  int? forceLogin)  $default,) {final _that = this;
switch (_that) {
case _LoginParamEntity():
return $default(_that.email,_that.password,_that.forceLogin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String password,  int? forceLogin)?  $default,) {final _that = this;
switch (_that) {
case _LoginParamEntity() when $default != null:
return $default(_that.email,_that.password,_that.forceLogin);case _:
  return null;

}
}

}

/// @nodoc


class _LoginParamEntity implements LoginParamEntity {
  const _LoginParamEntity({required this.email, required this.password, this.forceLogin});
  

@override final  String email;
@override final  String password;
@override final  int? forceLogin;

/// Create a copy of LoginParamEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginParamEntityCopyWith<_LoginParamEntity> get copyWith => __$LoginParamEntityCopyWithImpl<_LoginParamEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginParamEntity&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.forceLogin, forceLogin) || other.forceLogin == forceLogin));
}


@override
int get hashCode => Object.hash(runtimeType,email,password,forceLogin);

@override
String toString() {
  return 'LoginParamEntity(email: $email, password: $password, forceLogin: $forceLogin)';
}


}

/// @nodoc
abstract mixin class _$LoginParamEntityCopyWith<$Res> implements $LoginParamEntityCopyWith<$Res> {
  factory _$LoginParamEntityCopyWith(_LoginParamEntity value, $Res Function(_LoginParamEntity) _then) = __$LoginParamEntityCopyWithImpl;
@override @useResult
$Res call({
 String email, String password, int? forceLogin
});




}
/// @nodoc
class __$LoginParamEntityCopyWithImpl<$Res>
    implements _$LoginParamEntityCopyWith<$Res> {
  __$LoginParamEntityCopyWithImpl(this._self, this._then);

  final _LoginParamEntity _self;
  final $Res Function(_LoginParamEntity) _then;

/// Create a copy of LoginParamEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,Object? forceLogin = freezed,}) {
  return _then(_LoginParamEntity(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,forceLogin: freezed == forceLogin ? _self.forceLogin : forceLogin // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
