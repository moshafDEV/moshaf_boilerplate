import 'package:freezed_annotation/freezed_annotation.dart';

part 'text_input_field_entity.freezed.dart';

@freezed
abstract class TextInputFieldEntity with _$TextInputFieldEntity {
  const factory TextInputFieldEntity({
    @Default('') String value,
    String? invalidMessage,
    @Default(false) bool isVisiblePassword,
  }) = _TextInputFieldEntity;

  factory TextInputFieldEntity.initial() => const TextInputFieldEntity(
    value: '',
    invalidMessage: null,
    isVisiblePassword: false,
  );
}
