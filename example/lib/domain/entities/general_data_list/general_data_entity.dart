import 'package:freezed_annotation/freezed_annotation.dart';

part 'general_data_entity.freezed.dart';

@freezed
abstract class GeneralDataEntity with _$GeneralDataEntity {
  const factory GeneralDataEntity({
    required String label,
    required String value,
  }) = _GeneralDataEntity;

  factory GeneralDataEntity.initial() =>
      const GeneralDataEntity(label: '', value: '');
}
