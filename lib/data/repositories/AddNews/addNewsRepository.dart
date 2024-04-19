// ignore_for_file: file_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:news/data/repositories/AddNews/addNewsRemoteDataSource.dart';

class AddNewsRepository {
  static final AddNewsRepository _addNewsRepository = AddNewsRepository._internal();

  late AddNewsRemoteDataSource _addNewsRemoteDataSource;

  factory AddNewsRepository() {
    _addNewsRepository._addNewsRemoteDataSource = AddNewsRemoteDataSource();
    return _addNewsRepository;
  }

  AddNewsRepository._internal();

  Future<Map<String, dynamic>> addNews(
      {required BuildContext context,
      required String actionType,
      required String catId,
      required String title,
      required String conTypeId,
      required String conType,
      required String langId,
      File? image,
      String? newsId,
      String? subCatId,
      String? showTill,
      String? tagId,
      String? url,
      String? desc,
      String? locationId,
      File? videoUpload,
      List<File>? otherImage,
      required String metaTitle,
      required String metaDescription,
      required String metaKeyword,
      required String slug}) async {
    final result = await _addNewsRemoteDataSource.addNewsData(
        context: context,
        actionType: actionType,
        newsId: newsId,
        catId: catId,
        langId: langId,
        conType: conType,
        conTypeId: conTypeId,
        image: image,
        title: title,
        subCatId: subCatId,
        showTill: showTill,
        desc: desc,
        otherImage: otherImage,
        tagId: tagId,
        url: url,
        videoUpload: videoUpload,
        locationId: locationId,
        metaTitle: metaTitle,
        metaDescription: metaDescription,
        metaKeyword: metaKeyword,
        slug: slug);

    return result;
  }
}
