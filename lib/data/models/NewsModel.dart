// ignore_for_file: unnecessary_null_comparison, file_names
import 'package:news/data/models/CategoryModel.dart';
import 'package:news/data/models/locationCityModel.dart';
import 'package:news/utils/strings.dart';
import 'package:news/data/models/OptionModel.dart';

class NewsModel {
  String? id,
      userId,
      newsId,
      categoryId,
      title,
      date,
      contentType,
      contentValue,
      image,
      desc,
      categoryName,
      dateSent,
      totalLikes,
      like;
  String? bookmark,
      keyName,
      tagId,
      tagName,
      dislike,
      totalDislike,
      subCatId,
      img,
      subCatName,
      showTill,
      langId,
      totalViews,
      locationId,
      locationName,
      metaKeyword,
      metaTitle,
      metaDescription,
      slug;

  List<ImageDataModel>? imageDataList;

  bool? history = false;
  String? question, status, type;
  List<OptionModel>? optionDataList;
  int? from, counter;

  NewsModel(
      {this.id,
      this.userId,
      this.newsId,
      this.categoryId,
      this.title,
      this.date,
      this.contentType,
      this.contentValue,
      this.image,
      this.desc,
      this.categoryName,
      this.counter,
      this.dateSent,
      this.imageDataList,
      this.totalLikes,
      this.like,
      this.keyName,
      this.tagName,
      this.dislike,
      this.subCatId,
      this.totalDislike,
      this.tagId,
      this.history,
      this.optionDataList,
      this.question,
      this.status,
      this.type,
      this.from,
      this.img,
      this.subCatName,
      this.showTill,
      this.bookmark,
      this.langId,
      this.totalViews,
      this.locationId,
      this.locationName,
      this.metaTitle,
      this.metaDescription,
      this.metaKeyword,
      this.slug});

  factory NewsModel.history(String history) {
    return NewsModel(title: history, history: true);
  }

  factory NewsModel.fromSurvey(Map<String, dynamic> json) {
    List<OptionModel> optionList = (json[OPTION] as List)
        .map((data) => OptionModel.fromJson(data))
        .toList();

    return NewsModel(
        id: json[ID].toString(),
        question: json[QUESTION],
        status: json[STATUS].toString(),
        optionDataList: optionList,
        type: "survey",
        from: 1);
  }

  factory NewsModel.fromVideos(Map<String, dynamic> json) {
    return NewsModel(
        id: json[ID].toString(),
        newsId: json[ID].toString(),
        //for bookmark get/set
        date: json[DATE],
        image: json[IMAGE],
        title: json[TITLE],
        contentType: json[CONTENT_TYPE],
        contentValue: json[CONTENT_VALUE]);
  }

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    String? tagName;

    tagName = (json[TAG] == null) ? "" : json[TAG];

    List<ImageDataModel> imageData = [];
    var imageList = (json.containsKey(IMAGES))
        ? json[IMAGES] as List<dynamic>
        : (json.containsKey(IMAGE_DATA))
            ? json[IMAGE_DATA] as List
            : [];
    imageList = (imageList == null || imageList.isEmpty)
        ? []
        : imageList.map((data) => ImageDataModel.fromJson(data)).toList();
    if (imageList != null && imageList.isNotEmpty)
      imageData = imageList as List<ImageDataModel>;

    var categoryName = (json.containsKey(CATEGORY_NAME))
        ? json[CATEGORY_NAME]
        : (json.containsKey(CATEGORY))
            ? CategoryModel.fromJson(json[CATEGORY]).categoryName
            : '';
    var subcategoryName = (json.containsKey(SUBCAT_NAME))
        ? json[SUBCAT_NAME]
        : ((json.containsKey(SUBCATEGORY) && json[SUBCATEGORY] != null)
            ? SubCategoryModel.fromJson(json[SUBCATEGORY]).subCatName
            : '');

    return NewsModel(
        id: json[ID].toString(),
        userId: json[USER_ID].toString(),
        newsId: (json[NEWS_ID] != null &&
                json[NEWS_ID].toString().trim().isNotEmpty)
            ? json[NEWS_ID].toString()
            : json[ID].toString(),
        //incase of null newsId in Response
        categoryId: json[CATEGORY_ID].toString(),
        title: json[TITLE],
        date: json[DATE],
        contentType: json[CONTENT_TYPE],
        contentValue: json[CONTENT_VALUE],
        image: json[IMAGE],
        desc: json[DESCRIPTION],
        categoryName: categoryName,
        counter: json[COUNTER],
        dateSent: json[DATE_SENT],
        imageDataList: imageData,
        totalLikes: json[TOTAL_LIKE].toString(),
        like: json[LIKE].toString(),
        bookmark: json[BOOKMARK].toString(),
        tagId: json[TAG_ID],
        tagName: tagName,
        dislike: json[DISLIKE].toString(),
        subCatId: json[SUBCAT_ID].toString(),
        totalDislike: json[TOTAL_DISLIKE].toString(),
        history: false,
        type: "news",
        img: "",
        subCatName: subcategoryName,
        showTill: json[SHOW_TILL],
        langId: json[LANGUAGE_ID].toString(),
        totalViews: json[TOTAL_VIEWS].toString(),
        locationId: (json.containsKey(LOCATION) && json[LOCATION] != null)
            ? LocationCityModel.fromJson(json[LOCATION]).id.toString()
            : json[LOCATION_ID].toString(),
        locationName: (json.containsKey(LOCATION) && json[LOCATION] != null)
            ? LocationCityModel.fromJson(json[LOCATION]).locationName
            : json[LOCATION_NAME],
        metaKeyword: json[META_KEYWORD],
        metaTitle: json[META_TITLE],
        metaDescription: json[META_DESC],
        slug: json[SLUG]);
  }
}

class ImageDataModel {
  String? id;
  String? otherImage;

  ImageDataModel({this.otherImage, this.id});

  factory ImageDataModel.fromJson(Map<String, dynamic> json) {
    return ImageDataModel(
        otherImage: json[OTHER_IMAGE], id: json[ID].toString());
  }
}
