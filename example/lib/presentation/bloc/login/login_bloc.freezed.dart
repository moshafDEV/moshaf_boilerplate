// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoginEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LoginEvent()';
}


}

/// @nodoc
class $LoginEventCopyWith<$Res>  {
$LoginEventCopyWith(LoginEvent _, $Res Function(LoginEvent) __);
}


/// Adds pattern-matching-related methods to [LoginEvent].
extension LoginEventPatterns on LoginEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _OnEmailChanged value)?  onEmailChanged,TResult Function( _OnPasswordChanged value)?  onPasswordChanged,TResult Function( _OnSubmit value)?  onSubmit,TResult Function( _GetInfoProfile value)?  getInfoProfile,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnEmailChanged() when onEmailChanged != null:
return onEmailChanged(_that);case _OnPasswordChanged() when onPasswordChanged != null:
return onPasswordChanged(_that);case _OnSubmit() when onSubmit != null:
return onSubmit(_that);case _GetInfoProfile() when getInfoProfile != null:
return getInfoProfile(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _OnEmailChanged value)  onEmailChanged,required TResult Function( _OnPasswordChanged value)  onPasswordChanged,required TResult Function( _OnSubmit value)  onSubmit,required TResult Function( _GetInfoProfile value)  getInfoProfile,}){
final _that = this;
switch (_that) {
case _OnEmailChanged():
return onEmailChanged(_that);case _OnPasswordChanged():
return onPasswordChanged(_that);case _OnSubmit():
return onSubmit(_that);case _GetInfoProfile():
return getInfoProfile(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _OnEmailChanged value)?  onEmailChanged,TResult? Function( _OnPasswordChanged value)?  onPasswordChanged,TResult? Function( _OnSubmit value)?  onSubmit,TResult? Function( _GetInfoProfile value)?  getInfoProfile,}){
final _that = this;
switch (_that) {
case _OnEmailChanged() when onEmailChanged != null:
return onEmailChanged(_that);case _OnPasswordChanged() when onPasswordChanged != null:
return onPasswordChanged(_that);case _OnSubmit() when onSubmit != null:
return onSubmit(_that);case _GetInfoProfile() when getInfoProfile != null:
return getInfoProfile(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String fieldValue)?  onEmailChanged,TResult Function( String fieldValue,  bool? togglePasswordVisibility)?  onPasswordChanged,TResult Function()?  onSubmit,TResult Function()?  getInfoProfile,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnEmailChanged() when onEmailChanged != null:
return onEmailChanged(_that.fieldValue);case _OnPasswordChanged() when onPasswordChanged != null:
return onPasswordChanged(_that.fieldValue,_that.togglePasswordVisibility);case _OnSubmit() when onSubmit != null:
return onSubmit();case _GetInfoProfile() when getInfoProfile != null:
return getInfoProfile();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String fieldValue)  onEmailChanged,required TResult Function( String fieldValue,  bool? togglePasswordVisibility)  onPasswordChanged,required TResult Function()  onSubmit,required TResult Function()  getInfoProfile,}) {final _that = this;
switch (_that) {
case _OnEmailChanged():
return onEmailChanged(_that.fieldValue);case _OnPasswordChanged():
return onPasswordChanged(_that.fieldValue,_that.togglePasswordVisibility);case _OnSubmit():
return onSubmit();case _GetInfoProfile():
return getInfoProfile();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String fieldValue)?  onEmailChanged,TResult? Function( String fieldValue,  bool? togglePasswordVisibility)?  onPasswordChanged,TResult? Function()?  onSubmit,TResult? Function()?  getInfoProfile,}) {final _that = this;
switch (_that) {
case _OnEmailChanged() when onEmailChanged != null:
return onEmailChanged(_that.fieldValue);case _OnPasswordChanged() when onPasswordChanged != null:
return onPasswordChanged(_that.fieldValue,_that.togglePasswordVisibility);case _OnSubmit() when onSubmit != null:
return onSubmit();case _GetInfoProfile() when getInfoProfile != null:
return getInfoProfile();case _:
  return null;

}
}

}

/// @nodoc


class _OnEmailChanged implements LoginEvent {
  const _OnEmailChanged(this.fieldValue);
  

 final  String fieldValue;

/// Create a copy of LoginEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnEmailChangedCopyWith<_OnEmailChanged> get copyWith => __$OnEmailChangedCopyWithImpl<_OnEmailChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnEmailChanged&&(identical(other.fieldValue, fieldValue) || other.fieldValue == fieldValue));
}


@override
int get hashCode => Object.hash(runtimeType,fieldValue);

@override
String toString() {
  return 'LoginEvent.onEmailChanged(fieldValue: $fieldValue)';
}


}

/// @nodoc
abstract mixin class _$OnEmailChangedCopyWith<$Res> implements $LoginEventCopyWith<$Res> {
  factory _$OnEmailChangedCopyWith(_OnEmailChanged value, $Res Function(_OnEmailChanged) _then) = __$OnEmailChangedCopyWithImpl;
@useResult
$Res call({
 String fieldValue
});




}
/// @nodoc
class __$OnEmailChangedCopyWithImpl<$Res>
    implements _$OnEmailChangedCopyWith<$Res> {
  __$OnEmailChangedCopyWithImpl(this._self, this._then);

  final _OnEmailChanged _self;
  final $Res Function(_OnEmailChanged) _then;

/// Create a copy of LoginEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fieldValue = null,}) {
  return _then(_OnEmailChanged(
null == fieldValue ? _self.fieldValue : fieldValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _OnPasswordChanged implements LoginEvent {
  const _OnPasswordChanged(this.fieldValue, {this.togglePasswordVisibility});
  

 final  String fieldValue;
 final  bool? togglePasswordVisibility;

/// Create a copy of LoginEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnPasswordChangedCopyWith<_OnPasswordChanged> get copyWith => __$OnPasswordChangedCopyWithImpl<_OnPasswordChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnPasswordChanged&&(identical(other.fieldValue, fieldValue) || other.fieldValue == fieldValue)&&(identical(other.togglePasswordVisibility, togglePasswordVisibility) || other.togglePasswordVisibility == togglePasswordVisibility));
}


@override
int get hashCode => Object.hash(runtimeType,fieldValue,togglePasswordVisibility);

@override
String toString() {
  return 'LoginEvent.onPasswordChanged(fieldValue: $fieldValue, togglePasswordVisibility: $togglePasswordVisibility)';
}


}

/// @nodoc
abstract mixin class _$OnPasswordChangedCopyWith<$Res> implements $LoginEventCopyWith<$Res> {
  factory _$OnPasswordChangedCopyWith(_OnPasswordChanged value, $Res Function(_OnPasswordChanged) _then) = __$OnPasswordChangedCopyWithImpl;
@useResult
$Res call({
 String fieldValue, bool? togglePasswordVisibility
});




}
/// @nodoc
class __$OnPasswordChangedCopyWithImpl<$Res>
    implements _$OnPasswordChangedCopyWith<$Res> {
  __$OnPasswordChangedCopyWithImpl(this._self, this._then);

  final _OnPasswordChanged _self;
  final $Res Function(_OnPasswordChanged) _then;

/// Create a copy of LoginEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fieldValue = null,Object? togglePasswordVisibility = freezed,}) {
  return _then(_OnPasswordChanged(
null == fieldValue ? _self.fieldValue : fieldValue // ignore: cast_nullable_to_non_nullable
as String,togglePasswordVisibility: freezed == togglePasswordVisibility ? _self.togglePasswordVisibility : togglePasswordVisibility // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

/// @nodoc


class _OnSubmit implements LoginEvent {
  const _OnSubmit();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnSubmit);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LoginEvent.onSubmit()';
}


}




/// @nodoc


class _GetInfoProfile implements LoginEvent {
  const _GetInfoProfile();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetInfoProfile);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LoginEvent.getInfoProfile()';
}


}




/// @nodoc
mixin _$LoginState {

 TextInputFieldEntity get email; TextInputFieldEntity get password; bool get isLoading; bool get successLogin; String get errorResponseMessage;
/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginStateCopyWith<LoginState> get copyWith => _$LoginStateCopyWithImpl<LoginState>(this as LoginState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginState&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.successLogin, successLogin) || other.successLogin == successLogin)&&(identical(other.errorResponseMessage, errorResponseMessage) || other.errorResponseMessage == errorResponseMessage));
}


@override
int get hashCode => Object.hash(runtimeType,email,password,isLoading,successLogin,errorResponseMessage);

@override
String toString() {
  return 'LoginState(email: $email, password: $password, isLoading: $isLoading, successLogin: $successLogin, errorResponseMessage: $errorResponseMessage)';
}


}

/// @nodoc
abstract mixin class $LoginStateCopyWith<$Res>  {
  factory $LoginStateCopyWith(LoginState value, $Res Function(LoginState) _then) = _$LoginStateCopyWithImpl;
@useResult
$Res call({
 TextInputFieldEntity email, TextInputFieldEntity password, bool isLoading, bool successLogin, String errorResponseMessage
});


$TextInputFieldEntityCopyWith<$Res> get email;$TextInputFieldEntityCopyWith<$Res> get password;

}
/// @nodoc
class _$LoginStateCopyWithImpl<$Res>
    implements $LoginStateCopyWith<$Res> {
  _$LoginStateCopyWithImpl(this._self, this._then);

  final LoginState _self;
  final $Res Function(LoginState) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,Object? isLoading = null,Object? successLogin = null,Object? errorResponseMessage = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as TextInputFieldEntity,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as TextInputFieldEntity,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,successLogin: null == successLogin ? _self.successLogin : successLogin // ignore: cast_nullable_to_non_nullable
as bool,errorResponseMessage: null == errorResponseMessage ? _self.errorResponseMessage : errorResponseMessage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextInputFieldEntityCopyWith<$Res> get email {
  
  return $TextInputFieldEntityCopyWith<$Res>(_self.email, (value) {
    return _then(_self.copyWith(email: value));
  });
}/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextInputFieldEntityCopyWith<$Res> get password {
  
  return $TextInputFieldEntityCopyWith<$Res>(_self.password, (value) {
    return _then(_self.copyWith(password: value));
  });
}
}


/// Adds pattern-matching-related methods to [LoginState].
extension LoginStatePatterns on LoginState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginState value)  $default,){
final _that = this;
switch (_that) {
case _LoginState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginState value)?  $default,){
final _that = this;
switch (_that) {
case _LoginState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TextInputFieldEntity email,  TextInputFieldEntity password,  bool isLoading,  bool successLogin,  String errorResponseMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginState() when $default != null:
return $default(_that.email,_that.password,_that.isLoading,_that.successLogin,_that.errorResponseMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TextInputFieldEntity email,  TextInputFieldEntity password,  bool isLoading,  bool successLogin,  String errorResponseMessage)  $default,) {final _that = this;
switch (_that) {
case _LoginState():
return $default(_that.email,_that.password,_that.isLoading,_that.successLogin,_that.errorResponseMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TextInputFieldEntity email,  TextInputFieldEntity password,  bool isLoading,  bool successLogin,  String errorResponseMessage)?  $default,) {final _that = this;
switch (_that) {
case _LoginState() when $default != null:
return $default(_that.email,_that.password,_that.isLoading,_that.successLogin,_that.errorResponseMessage);case _:
  return null;

}
}

}

/// @nodoc


class _LoginState implements LoginState {
   _LoginState({required this.email, required this.password, this.isLoading = false, this.successLogin = false, this.errorResponseMessage = ''});
  

@override final  TextInputFieldEntity email;
@override final  TextInputFieldEntity password;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool successLogin;
@override@JsonKey() final  String errorResponseMessage;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginStateCopyWith<_LoginState> get copyWith => __$LoginStateCopyWithImpl<_LoginState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginState&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.successLogin, successLogin) || other.successLogin == successLogin)&&(identical(other.errorResponseMessage, errorResponseMessage) || other.errorResponseMessage == errorResponseMessage));
}


@override
int get hashCode => Object.hash(runtimeType,email,password,isLoading,successLogin,errorResponseMessage);

@override
String toString() {
  return 'LoginState(email: $email, password: $password, isLoading: $isLoading, successLogin: $successLogin, errorResponseMessage: $errorResponseMessage)';
}


}

/// @nodoc
abstract mixin class _$LoginStateCopyWith<$Res> implements $LoginStateCopyWith<$Res> {
  factory _$LoginStateCopyWith(_LoginState value, $Res Function(_LoginState) _then) = __$LoginStateCopyWithImpl;
@override @useResult
$Res call({
 TextInputFieldEntity email, TextInputFieldEntity password, bool isLoading, bool successLogin, String errorResponseMessage
});


@override $TextInputFieldEntityCopyWith<$Res> get email;@override $TextInputFieldEntityCopyWith<$Res> get password;

}
/// @nodoc
class __$LoginStateCopyWithImpl<$Res>
    implements _$LoginStateCopyWith<$Res> {
  __$LoginStateCopyWithImpl(this._self, this._then);

  final _LoginState _self;
  final $Res Function(_LoginState) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,Object? isLoading = null,Object? successLogin = null,Object? errorResponseMessage = null,}) {
  return _then(_LoginState(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as TextInputFieldEntity,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as TextInputFieldEntity,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,successLogin: null == successLogin ? _self.successLogin : successLogin // ignore: cast_nullable_to_non_nullable
as bool,errorResponseMessage: null == errorResponseMessage ? _self.errorResponseMessage : errorResponseMessage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextInputFieldEntityCopyWith<$Res> get email {
  
  return $TextInputFieldEntityCopyWith<$Res>(_self.email, (value) {
    return _then(_self.copyWith(email: value));
  });
}/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextInputFieldEntityCopyWith<$Res> get password {
  
  return $TextInputFieldEntityCopyWith<$Res>(_self.password, (value) {
    return _then(_self.copyWith(password: value));
  });
}
}

// dart format on
