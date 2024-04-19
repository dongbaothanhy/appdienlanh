// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart' as loc;
import 'package:marqueer/marqueer.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/Auth/registerTokenCubit.dart';
import 'package:news/cubits/Bookmark/bookmarkCubit.dart';
import 'package:news/cubits/LikeAndDislikeNews/LikeAndDislikeCubit.dart';
import 'package:news/cubits/appSystemSettingCubit.dart';
import 'package:news/cubits/breakingNewsCubit.dart';
import 'package:news/cubits/featureSectionCubit.dart';
import 'package:news/cubits/getUserDataByIdCubit.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/liveStreamCubit.dart';
import 'package:news/cubits/sectionByIdCubit.dart';
import 'package:news/cubits/settingCubit.dart';
import 'package:news/data/repositories/SectionById/sectionByIdRepository.dart';
import 'package:news/data/repositories/Settings/settingsLocalDataRepository.dart';
import 'package:news/ui/screens/HomePage/Widgets/LiveWithSearchView.dart';
import 'package:news/ui/screens/HomePage/Widgets/SectionShimmer.dart';
import 'package:news/ui/screens/HomePage/Widgets/WeatherData.dart';
import 'package:news/ui/screens/HomePage/Widgets/SectionStyle1.dart';
import 'package:news/ui/screens/HomePage/Widgets/SectionStyle2.dart';
import 'package:news/ui/screens/HomePage/Widgets/SectionStyle3.dart';
import 'package:news/ui/screens/HomePage/Widgets/SectionStyle4.dart';
import 'package:news/ui/screens/HomePage/Widgets/SectionStyle5.dart';
import 'package:news/ui/screens/HomePage/Widgets/SectionStyle6.dart';
import 'package:news/ui/widgets/SnackBarWidget.dart';
import 'package:news/ui/widgets/adSpaces.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/errorContainerWidget.dart';
import 'package:news/utils/ErrorMessageKeys.dart';
import 'package:news/utils/constant.dart';
import 'package:news/utils/strings.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/utils/hiveBoxKeys.dart';
import 'package:news/data/models/AuthModel.dart';
import 'package:news/data/models/FeatureSectionModel.dart';
import 'package:news/data/models/WeatherData.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  WeatherData? weatherData;
  bool weatherLoad = true;
  final loc.Location _location = loc.Location();
  bool? _serviceEnabled;
  loc.PermissionStatus? _permissionGranted;
  double? lat;
  double? lon;
  bool updateList = false;

  void getSections() {
    Future.delayed(Duration.zero, () {
      context.read<SectionCubit>().getSection(
          langId: context.read<AppLocalizationCubit>().state.id,
          latitude: SettingsLocalDataRepository().getLocationCityValues().first,
          longitude:
              SettingsLocalDataRepository().getLocationCityValues().last);
    });
  }

  void getLiveStreamData() {
    Future.delayed(Duration.zero, () {
      context
          .read<LiveStreamCubit>()
          .getLiveStream(langId: context.read<AppLocalizationCubit>().state.id);
    });
  }

  void getBookmark() {
    Future.delayed(Duration.zero, () {
      context
          .read<BookmarkCubit>()
          .getBookmark(langId: context.read<AppLocalizationCubit>().state.id);
    });
  }

  void getLikeNews() {
    Future.delayed(Duration.zero, () {
      context.read<LikeAndDisLikeCubit>().getLikeAndDisLike(
          langId: context.read<AppLocalizationCubit>().state.id);
    });
  }

  void getUserData() {
    Future.delayed(Duration.zero, () {
      context.read<GetUserByIdCubit>().getUserById();
    });
  }

  getLocationPermission(bool isRefresh) async {
    loc.LocationData locationData;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled!) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      SettingsLocalDataRepository().setLocationCityKeys(null, null);
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }
    locationData = await _location.getLocation();

    setState(() {
      lat = locationData.latitude;
      lon = locationData.longitude;
    });

    if (context.read<AppConfigurationCubit>().getLocationWiseNewsMode() ==
        "1") {
      SettingsLocalDataRepository().setLocationCityKeys(lat, lon);
      //update latitude,longitude - along with token
      if (context.read<SettingsCubit>().getSettings().token != '') {
        context.read<RegisterTokenCubit>().registerToken(
            fcmId: context.read<SettingsCubit>().getSettings().token,
            context: context);
        context
            .read<SettingsCubit>()
            .changeFcmToken(context.read<SettingsCubit>().getSettings().token);
      }
      if (isWeatherDataShow) {
        if (isRefresh) {
          setState(() {
            weatherLoad = true;
            weatherData = null;
          });
        }

        getWeatherData();
      }
    } else {
      SettingsLocalDataRepository().setLocationCityKeys(null, null);
    }
  }

  getWeatherData() async {
    if (lat != null && lon != null) {
      final langCode = Hive.box(settingsBoxKey).get(currentLanguageCodeKey);
      final Dio dio = Dio();

      final weatherResponse = await dio.get(
          'https://api.weatherapi.com/v1/forecast.json?key=d0f2f4dbecc043e78d6123135212408&q=${lat.toString()},${lon.toString()}&days=1&alerts=no&lang=$langCode');
      if (weatherResponse.statusCode == 200) {
        if (mounted) {
          setState(() {
            weatherData = WeatherData.fromJson(Map.from(weatherResponse.data));
            weatherLoad = false;
          });
        }
      }

      setState(() {
        weatherLoad = false;
      });
    }
  }

  void getBreakingNews() {
    Future.delayed(Duration.zero, () {
      context.read<BreakingNewsCubit>().getBreakingNews(
          langId: context.read<AppLocalizationCubit>().state.id);
    });
  }

  @override
  void initState() {
    getLocationPermission(false);
    if (context.read<AuthCubit>().getUserId() != "0") {
      getUserData();
    }
    getLiveStreamData();

    getSections();
    if (context.read<AppConfigurationCubit>().getBreakingNewsMode() == "1")
      getBreakingNews();

    super.initState();
  }

  Widget breakingNewsMarquee() {
    return BlocBuilder<BreakingNewsCubit, BreakingNewsState>(
        builder: ((context, state) {
      return (state is BreakingNewsFetchSuccess &&
              state.breakingNews.isNotEmpty)
          ? Container(
              margin: const EdgeInsets.only(top: 10),
              color: UiUtils.getColorScheme(context).primaryContainer,
              height: 32,
              child: Marqueer.builder(
                pps: 25.0,
                restartAfterInteractionDuration: const Duration(seconds: 1),
                separatorBuilder: (_, index) => Center(
                    child: Text(' ● ',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: UiUtils.getColorScheme(context).secondary,
                            fontWeight: FontWeight.normal))),
                itemBuilder: (context, index) {
                  var multiplier = index ~/ state.breakingNews.length;
                  var i = index;
                  if (multiplier > 0) {
                    i = index - (multiplier * state.breakingNews.length);
                  }
                  final item = state.breakingNews[i];
                  return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: CustomTextLabel(
                        text: item.title!,
                        textStyle: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(
                                color:
                                    UiUtils.getColorScheme(context).secondary,
                                fontWeight: FontWeight.normal),
                      ));
                },
              ),
            )
          : const SizedBox.shrink();
    }));
  }

  Widget getSectionList() {
    return BlocBuilder<SectionCubit, SectionState>(builder: (context, state) {
      if (state is SectionFetchSuccess) {
        return ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: ((context, index) {
              FeatureSectionModel model = state.section[index];
              return sectionData(index, model);
            }),
            itemCount: state.section.length);
      }
      if (state is SectionFetchFailure) {
        return ErrorContainerWidget(
            errorMsg: (state.errorMessage.contains(ErrorMessageKeys.noInternet))
                ? UiUtils.getTranslatedLabel(context, 'internetmsg')
                : state.errorMessage,
            onRetry: _refresh);
      }
      return sectionShimmer(
          context); //state is SectionFetchInProgress || state is SectionInitial
    });
  }

  Widget sectionData(int index, FeatureSectionModel model) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (model.adSpaceDetails != null)
            AdSpaces(adsModel: model.adSpaceDetails!), //sponsored ads
          if (model.styleApp == 'style_1') Style1Section(model: model),
          if (model.styleApp == 'style_2') Style2Section(model: model),
          if (model.styleApp == 'style_3') Style3Section(model: model),
          if (model.styleApp == 'style_4') Style4Section(model: model),
          if (model.styleApp == 'style_5') Style5Section(model: model),
          if (model.styleApp == 'style_6')
            BlocProvider(
                create: (context) => SectionByIdCubit(SectionByIdRepository()),
                child: Style6Section(model: model))
        ]);
  }

  //refresh function to refresh page
  Future<void> _refresh() async {
    getLocationPermission(true);
    if (context.read<AuthCubit>().getUserId() != "0") {
      getUserData();
      getBookmark();
      getLikeNews();
    }
    getLiveStreamData();

    getSections();
    if (context.read<AppConfigurationCubit>().getBreakingNewsMode() == "1")
      getBreakingNews();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () => _refresh(),
              child: BlocListener<GetUserByIdCubit, GetUserByIdState>(
                bloc: context.read<GetUserByIdCubit>(),
                listener: (context, state) {
                  if (state is GetUserByIdFetchSuccess) {
                    var data = state.result;
                    if (data[STATUS] == 0) {
                      showSnackBar(
                          UiUtils.getTranslatedLabel(context, 'deactiveMsg'),
                          context);
                      Future.delayed(const Duration(seconds: 2), () {
                        UiUtils.userLogOut(contxt: context);
                      });
                    } else {
                      context.read<AuthCubit>().updateDetails(
                          authModel: AuthModel(
                              id: data[ID].toString(),
                              name: data[NAME],
                              status: data[STATUS].toString(),
                              mobile: data[MOBILE],
                              email: data[EMAIL],
                              type: data[TYPE],
                              profile: data[PROFILE],
                              role: data[ROLE].toString(),
                              jwtToken: data[TOKEN]));
                    }
                  }
                },
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                        start: 15.0, end: 15.0, bottom: 10.0),
                    child: Column(
                      children: [
                        const LiveWithSearchView(),
                        if (weatherData != null)
                          WeatherDataView(
                              weatherData: weatherData!,
                              weatherLoad: weatherLoad),
                        breakingNewsMarquee(),
                        getSectionList(),
/*                        ListView(
                            shrinkWrap: true,

                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsetsDirectional.only(
                                start: 15.0, end: 15.0, bottom: 10.0),
                            children: [
                              const LiveWithSearchView(),
                              if (weatherData != null)
                                WeatherDataView(
                                    weatherData: weatherData!,
                                    weatherLoad: weatherLoad),
                              breakingNewsMarquee(),
                              getSectionList()
                            ]),*/
                      ],
                    ),
                  ),
                ),
              ))),
    );
  }
}
