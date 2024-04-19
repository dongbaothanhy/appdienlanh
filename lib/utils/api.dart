import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:news/data/repositories/Auth/authLocalDataSource.dart';
import 'package:news/utils/ErrorMessageKeys.dart';
import 'package:news/utils/internetConnectivity.dart';
import 'package:news/utils/strings.dart';
import 'package:news/utils/constant.dart';

class ApiMessageAndCodeException implements Exception {
  final String errorMessage;

  ApiMessageAndCodeException({required this.errorMessage});

  Map toError() => {"message": errorMessage};

  @override
  String toString() => errorMessage;
}

class ApiException implements Exception {
  String errorMessage;

  ApiException(this.errorMessage);

  @override
  String toString() {
    return errorMessage;
  }
}

class Api {
  static String getToken() {
    String token = AuthLocalDataSource().getJWTtoken();
    debugPrint("token $token");
    return (token.trim().isNotEmpty) ? token : "";
  }

  static Map<String, String> get headers => {"Authorization": 'Bearer ${getToken()}'};

//access key for access api
  static String accessKey = "5670";

  //all apis list
  static String getUserSignUpApi = 'user_signup';
  static String getNewsApi = 'get_news';
  static String getSettingApi = 'get_settings';
  static String getCatApi = 'get_category';
  static String setBookmarkApi = 'set_bookmark';
  static String getBookmarkApi = 'get_bookmark';
  static String setCommentApi = 'set_comment';
  static String getCommentByNewsApi = 'get_comment_by_news';
  static String getBreakingNewsApi = 'get_breaking_news';
  static String setUpdateProfileApi = 'update_profile';
  static String setRegisterToken = 'register_token';
  static String getNotificationApi = 'get_notification';
  static String setUserCatApi = 'set_user_category';
  static String getUserByIdApi = 'get_user_by_id';
  static String setCommentDeleteApi = 'delete_comment';
  static String setLikesDislikesApi = 'set_like_dislike';
  static String setFlagApi = 'set_flag';
  static String getLiveStreamingApi = 'get_live_streaming';
  static String getSubCategoryApi = 'get_subcategory_by_category';
  static String setLikeDislikeComApi = 'set_comment_like_dislike';
  static String getUserNotificationApi = 'get_user_notification';
  static String deleteUserNotiApi = 'delete_user_notification';
  static String getQueApi = 'get_question';
  static String getQueResultApi = 'get_question_result';
  static String setQueResultApi = 'set_question_result';
  static String userDeleteApi = 'delete_user';
  static String getTagsApi = 'get_tag';
  static String setNewsApi = 'set_news';
  static String setDeleteNewsApi = 'delete_news';
  static String setDeleteImageApi = 'delete_news_images';
  static String getVideosApi = 'get_videos';
  static String getLanguagesApi = 'get_languages_list';
  static String getLangJsonDataApi = 'get_language_json_data';
  static String getPagesApi = 'get_pages';
  static String getPolicyPagesApi = 'get_policy_pages';
  static String getFeatureSectionApi = 'get_featured_sections';
  static String getLikeNewsApi = 'get_like';
  static String getFeatureSectionByIdApi = 'get_featured_section_by_id';
  static String setNewsViewApi = 'set_news_view';
  static String setBreakingNewsViewApi = 'set_breaking_news_view';
  static String getAdsNewsDetailsApi = 'get_ad_space_news_details';
  static String getLocationCityApi = 'get_location';
  static String slugCheckApi = 'check_slug_availability';

  static Future<Map<String, dynamic>> sendApiRequest({bool isGet = false, required Map<String, dynamic> body, required String url}) async {
    try {
      if (await InternetConnectivity.isNetworkAvailable() == false) {
        throw const SocketException(ErrorMessageKeys.noInternet);
      }
      final Dio dio = Dio();
      body[ACCESS_KEY] = accessKey;
      final apiUrl = "$databaseUrl$url";
      final FormData formData = FormData.fromMap(body, ListFormat.multiCompatible);
      debugPrint("Requested APi - $url & is Get? $isGet & params are ${formData.fields}");

      final Response response;
      response = (isGet) ? await dio.get(apiUrl, queryParameters: body, options: Options(headers: headers)) : await dio.post(apiUrl, data: formData, options: Options(headers: headers));
      if (response.data['error'] == 'true') {
        debugPrint("APi exception for $url - msg - ${response.data['message']}");
        throw ApiException(response.data['message']);
      } else {
        debugPrint("APi response data for $url is ${response.data}");
      }
      return Map.from(response.data);
    } on DioException catch (e) {
      debugPrint("Dio Error - ${e.toString()}");
      if (e.response != null) debugPrint("Dio Error Status code - ${e.response!.statusCode}");
      if (e.response != null && e.response!.statusCode == 503) {
        throw ApiException(ErrorMessageKeys.serverDownMessage);
      } else if (e.response!.statusCode == 404) {
        throw ApiException(ErrorMessageKeys.requestAgainMessage);
      } else {
        throw ApiException(e.error is SocketException ? ErrorMessageKeys.noInternet : ErrorMessageKeys.defaultErrorMessage);
      }
    } on SocketException catch (e) {
      debugPrint("Socket Exception - ${e.toString()}");
      throw SocketException(e.message);
    } on ApiException catch (e) {
      debugPrint("APi Exception - ${e.toString()}");
      throw ApiException(e.errorMessage);
    } catch (e) {
      debugPrint("catch Exception- ${e.toString()}");
      throw ApiException(ErrorMessageKeys.defaultErrorMessage);
    }
  }
}
