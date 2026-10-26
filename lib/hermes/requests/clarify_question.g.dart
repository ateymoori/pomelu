// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clarify_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClarifyQuestion _$ClarifyQuestionFromJson(Map<String, dynamic> json) =>
    _ClarifyQuestion(
      qid: json['qid'] == null ? '' : const LooseString().fromJson(json['qid']),
      question: json['question'] == null
          ? ''
          : const LooseString().fromJson(json['question']),
      choices: const LooseStringList().fromJson(json['choices']),
      multiSelect: json['multi_select'] == null
          ? false
          : const LooseBool().fromJson(json['multi_select']),
    );

Map<String, dynamic> _$ClarifyQuestionToJson(_ClarifyQuestion instance) =>
    <String, dynamic>{
      'qid': const LooseString().toJson(instance.qid),
      'question': const LooseString().toJson(instance.question),
      'choices': const LooseStringList().toJson(instance.choices),
      'multi_select': const LooseBool().toJson(instance.multiSelect),
    };
