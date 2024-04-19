// ignore_for_file: file_names

import 'package:news/utils/strings.dart';

class AuthModel {
  String? id;
  String? name;
  String? email;
  String? mobile;
  String? profile;
  String? type;
  String? status;
  String? isFirstLogin;
  String? role;
  String? jwtToken;

  AuthModel({this.id, this.name, this.email, this.mobile, this.profile, this.type, this.status, this.isFirstLogin, this.role, this.jwtToken});

  AuthModel.fromJson(Map<String, dynamic> json) {
    id = json[ID].toString();
    name = json[NAME] ?? "";
    email = json[EMAIL] ?? "";
    mobile = json[MOBILE] ?? "";
    profile = json[PROFILE] ?? "";
    type = json[TYPE] ?? "";
    status = json[STATUS].toString();
    isFirstLogin = (json[IS_LOGIN] != null) ? json[IS_LOGIN].toString() : "";
    role = json[ROLE].toString();
    jwtToken = json[TOKEN] ?? "";
  }
}
