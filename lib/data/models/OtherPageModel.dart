// ignore_for_file: file_names

import 'package:news/utils/strings.dart';

class OtherPageModel {
  String? id, pageContent, title, image;
//slug,meta_description,meta_keywords not in use.
  OtherPageModel({this.id, this.pageContent, this.title, this.image});

  factory OtherPageModel.fromJson(Map<String, dynamic> json) {
    return OtherPageModel(id: json[ID].toString(), pageContent: json[PAGE_CONTENT], title: json[TITLE], image: json[PAGE_ICON]);
  }

  factory OtherPageModel.fromPrivacyTermsJson(Map<String, dynamic> json) {
    return OtherPageModel(id: json[ID].toString().toString(), pageContent: json[PAGE_CONTENT], title: json[TITLE]);
  }
}
