// ignore_for_file: unnecessary_null_comparison, file_names

import 'package:news/utils/strings.dart';

class OptionModel {
  String? id;
  String? options;
  String? counter;
  double? percentage;
  String? questionId;

  OptionModel({this.id, this.options, this.counter, this.percentage, this.questionId});

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
        id: json[ID].toString(),
        options: json[OPTIONS],
        counter: json[COUNTER].toString(),
        percentage: (json[PERCENTAGE].runtimeType == int) ? double.parse(json[PERCENTAGE].toString()) : json[PERCENTAGE],
        questionId: json[QUESTION_ID].toString());
  }
}
