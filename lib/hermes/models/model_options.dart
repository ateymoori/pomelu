import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';
import 'json_parse.dart';

part 'model_options.freezed.dart';
part 'model_options.g.dart';

/// One provider row from `model.options`.
@freezed
abstract class ModelProvider with _$ModelProvider {
  const ModelProvider._();

  const factory ModelProvider({
    @LooseString() @Default('') String slug,
    @LooseString() @Default('') String name,
    @JsonKey(name: 'is_current') @LooseBool() @Default(false) bool isCurrent,
    @LooseBool() @Default(true) bool authenticated,
    @JsonKey(fromJson: _stringsFromJson)
    @Default(<String>[])
    List<String> models,
    @LooseMap() Map<String, dynamic>? capabilities,
  }) = _ModelProvider;

  factory ModelProvider.fromJson(Map<String, dynamic> json) =>
      _$ModelProviderFromJson(json);
}

/// Result of `model.options`: providers with their models, plus the current
/// selection.
@freezed
abstract class ModelOptions with _$ModelOptions {
  const ModelOptions._();

  const factory ModelOptions({
    @JsonKey(fromJson: _providersFromJson)
    @Default(<ModelProvider>[])
    List<ModelProvider> providers,
    @LooseString() @Default('') String model,
    @LooseString() @Default('') String provider,
  }) = _ModelOptions;

  factory ModelOptions.fromJson(Map<String, dynamic> json) =>
      _$ModelOptionsFromJson(json);

  List<ModelProvider> get usable => [
    ...providers.where((p) => p.models.isNotEmpty && p.authenticated),
    ...providers.where((p) => p.models.isNotEmpty && !p.authenticated),
  ];
}

List<String> _stringsFromJson(Object? json) =>
    const LooseStringList().fromJson(json) ?? const <String>[];

/// The rows of `providers`; a malformed row is left out.
List<ModelProvider> _providersFromJson(Object? json) =>
    parseRows(json, ModelProvider.fromJson, what: 'provider');
