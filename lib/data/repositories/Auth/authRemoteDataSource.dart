// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/data/repositories/Settings/settingsLocalDataRepository.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/ui/widgets/SnackBarWidget.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _facebookSignin = FacebookLogin();

  Future<dynamic> loginAuth({required String firebaseId, required String name, required String email, required String type, required String profile, required String mobile}) async {
    try {
      final body = {FIREBASE_ID: firebaseId, NAME: name, TYPE: type, EMAIL: email};
      if (profile != "") body[PROFILE] = profile;
      if (mobile != "") body[MOBILE] = mobile;

      var result = await Api.sendApiRequest(body: body, url: Api.getUserSignUpApi);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future<dynamic> deleteUserAcc() async {
    try {
      final result = await Api.sendApiRequest(body: {}, url: Api.userDeleteApi);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  //to update fcmId of user's
  Future<dynamic> updateUserData({String? name, String? mobile, String? email, String? filePath}) async {
    try {
      Map<String, dynamic> body = {};
      Map<String, dynamic> result = {};

      if (name != null) body[NAME] = name;
      if (mobile != null) body[MOBILE] = mobile;
      if (email != null) body[EMAIL] = email;
      if (filePath != null && filePath.isNotEmpty) body[PROFILE] = await MultipartFile.fromFile(filePath);

      result = await Api.sendApiRequest(body: body, url: Api.setUpdateProfileApi);

      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future<dynamic> registerToken({required String fcmId, required BuildContext context}) async {
    try {
      final body = {TOKEN: fcmId, LANGUAGE_ID: context.read<AppLocalizationCubit>().state.id}; //Pass languageId for specific language Notifications

      String latitude = SettingsLocalDataRepository().getLocationCityValues().first;
      String longitude = SettingsLocalDataRepository().getLocationCityValues().last;

      if (latitude != '' && latitude != "null") body[LATITUDE] = latitude;
      if (longitude != '' && longitude != "null") body[LONGITUDE] = longitude;

      final result = await Api.sendApiRequest(body: body, url: Api.setRegisterToken);
      return result;
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future<Map<String, dynamic>> socialSignInUser({required AuthProviders authProvider, required BuildContext context, String? email, String? password, String? otp, String? verifiedId}) async {
    Map<String, dynamic> result = {};

    try {
      switch (authProvider) {
        case AuthProviders.gmail:
          UserCredential? userCredential = await signInWithGoogle(context);
          if (userCredential != null) {
            result['user'] = userCredential.user!;
            return result;
          } else {
            throw ApiMessageAndCodeException(errorMessage: UiUtils.getTranslatedLabel(context, 'somethingMSg'));
          }

        case AuthProviders.mobile:
          UserCredential? userCredential = await signInWithPhone(context: context, otp: otp!, verifiedId: verifiedId!);
          if (userCredential != null) {
            result['user'] = userCredential.user!;
            return result;
          } else {
            throw ApiMessageAndCodeException(errorMessage: UiUtils.getTranslatedLabel(context, 'somethingMSg'));
          }
        case AuthProviders.fb:
          final faceBookAuthResult = await signInWithFacebook();
          if (faceBookAuthResult != null) {
            result['user'] = faceBookAuthResult.user!;
            return result;
          } else {
            throw ApiMessageAndCodeException(errorMessage: UiUtils.getTranslatedLabel(context, 'somethingMSg'));
          }
        case AuthProviders.apple:
          UserCredential? userCredential = await signInWithApple(context);
          if (userCredential != null) {
            result['user'] = userCredential.user!;
            return result;
          } else {
            throw ApiMessageAndCodeException(errorMessage: UiUtils.getTranslatedLabel(context, 'somethingMSg'));
          }
        case AuthProviders.email:
          final userCredential = await signInWithEmailPassword(email: email!, password: password!, context: context);
          if (userCredential != null) {
            result['user'] = userCredential.user!;
            return result;
          } else {
            return {};
          }
      }
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: UiUtils.getTranslatedLabel(context, 'internetmsg'));
    } on FirebaseAuthException catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future<UserCredential?> signInWithPhone({required BuildContext context, required String otp, required String verifiedId}) async {
    String code = otp.trim();

    if (code.length == 6) {
      //As OTP is of Fixed length 6
      try {
        final PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verifiedId, smsCode: otp);
        final UserCredential authResult = await _firebaseAuth.signInWithCredential(credential);
        final User? user = authResult.user;
        if (user != null) {
          assert(!user.isAnonymous);

          final User? currentUser = _firebaseAuth.currentUser;
          assert(user.uid == currentUser?.uid);
          showSnackBar(UiUtils.getTranslatedLabel(context, 'otpMsg'), context);
          return authResult;
        } else {
          showSnackBar(UiUtils.getTranslatedLabel(context, 'otpError'), context);
          return null;
        }
      } on FirebaseAuthException catch (authError) {
        if (authError.code == 'invalidVerificationCode') {
          showSnackBar(UiUtils.getTranslatedLabel(context, 'invalidVerificationCode'), context);
          return null;
        } else {
          showSnackBar(authError.message.toString(), context);
          return null;
        }
      } on FirebaseException catch (e) {
        showSnackBar(e.message.toString(), context);
        return null;
      } catch (e) {
        showSnackBar(e.toString(), context);
        return null;
      }
    } else {
      showSnackBar(UiUtils.getTranslatedLabel(context, 'enterOtpTxt'), context);
      return null;
    }
  }

  //sign in with email and password in firebase
  Future<UserCredential?> signInWithEmailPassword({required String email, required String password, required BuildContext context}) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      return userCredential;
    } on FirebaseAuthException catch (authError) {
      if (authError.code == 'userNotFound') {
        showSnackBar(UiUtils.getTranslatedLabel(context, 'userNotFound'), context);
      } else if (authError.code == 'wrongPassword') {
        showSnackBar(UiUtils.getTranslatedLabel(context, 'wrongPassword'), context);
      } else {
        throw ApiMessageAndCodeException(errorMessage: authError.message!);
      }
    } on FirebaseException catch (e) {
      showSnackBar(e.toString(), context);
    } catch (e) {
      String errorMessage = e.toString();
      showSnackBar(errorMessage, context);
    }
    return null;
  }

  //signIn using google account
  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      ApiMessageAndCodeException(errorMessage: UiUtils.getTranslatedLabel(context, 'somethingMSg'));
      return null;
    }
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
    return userCredential;
  }

  Future<UserCredential?> signInWithFacebook() async {
    final res = await _facebookSignin.logIn(permissions: [FacebookPermission.publicProfile, FacebookPermission.email]);

// Check result status
    switch (res.status) {
      case FacebookLoginStatus.success:
        // Send access token to server for validation and auth
        final FacebookAccessToken? accessToken = res.accessToken;
        AuthCredential authCredential = FacebookAuthProvider.credential(accessToken!.token);
        final UserCredential userCredential = await _firebaseAuth.signInWithCredential(authCredential);
        return userCredential;
      case FacebookLoginStatus.cancel:
        return null;

      case FacebookLoginStatus.error:
        return null;
      default:
        return null;
    }
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential?> signInWithApple(BuildContext context) async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName], nonce: nonce);

      final oauthCredential = OAuthProvider("apple.com").credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      final UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      return authResult;
    } on FirebaseAuthException catch (authError) {
      showSnackBar(authError.message!, context);
      return null;
    } on FirebaseException catch (e) {
      showSnackBar(e.toString(), context);
      return null;
    } catch (e) {
      String errorMessage = e.toString();

      if (errorMessage == "Null check operator used on a null value") {
        //if user goes back from selecting Account
        //in case of User gmail not selected & back to Login screen
        showSnackBar(UiUtils.getTranslatedLabel(context, 'cancelLogin'), context);
        return null;
      } else {
        showSnackBar(errorMessage, context);
        return null;
      }
    }
  }

  Future<void> signOut(AuthProviders? authProvider) async {
    _firebaseAuth.signOut();
    if (authProvider == AuthProviders.gmail) {
      _googleSignIn.signOut();
    } else if (authProvider == AuthProviders.fb) {
      _facebookSignin.logOut();
    } else {
      _firebaseAuth.signOut();
    }
  }
}
