// ignore_for_file: file_names

import 'package:news/data/repositories/UserByCategory/userByCatRemoteDataSource.dart';

class UserByCatRepository {
  static final UserByCatRepository _userByCatRepository = UserByCatRepository._internal();

  late UserByCatRemoteDataSource _userByCatRemoteDataSource;

  factory UserByCatRepository() {
    _userByCatRepository._userByCatRemoteDataSource = UserByCatRemoteDataSource();
    return _userByCatRepository;
  }

  UserByCatRepository._internal();

  Future<Map<String, dynamic>> getUserById() async {
    final result = await _userByCatRemoteDataSource.getUserById();

    return {"UserByCat": result['data']};
  }
}
