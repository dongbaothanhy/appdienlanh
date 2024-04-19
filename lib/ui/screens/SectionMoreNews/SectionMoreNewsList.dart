// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/sectionByIdCubit.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/Settings/settingsLocalDataRepository.dart';
import 'package:news/ui/widgets/NewsItem.dart';
import 'package:news/ui/widgets/customAppBar.dart';
import 'package:news/ui/widgets/errorContainerWidget.dart';
import 'package:news/utils/ErrorMessageKeys.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/ui/widgets/shimmerNewsList.dart';
import 'package:news/ui/widgets/videoItem.dart';

class SectionMoreNewsList extends StatefulWidget {
  final String sectionId;
  final String title;

  const SectionMoreNewsList({super.key, required this.sectionId, required this.title});

  @override
  State<StatefulWidget> createState() {
    return _SectionNewsState();
  }

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
        builder: (_) => SectionMoreNewsList(
              sectionId: arguments['sectionId'],
              title: arguments['title'],
            ));
  }
}

class _SectionNewsState extends State<SectionMoreNewsList> {
  late final ScrollController controller = ScrollController();

  @override
  void initState() {
    getSectionByData();
    super.initState();
  }

  void getSectionByData() {
    Future.delayed(Duration.zero, () {
      context.read<SectionByIdCubit>().getSectionById(
          langId: context.read<AppLocalizationCubit>().state.id,
          sectionId: widget.sectionId,
          latitude: SettingsLocalDataRepository().getLocationCityValues().first,
          longitude: SettingsLocalDataRepository().getLocationCityValues().last);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  _buildSectionNewsContainer({required NewsModel model, required String type, required int index, required List<NewsModel> newsList}) {
    return (type == 'news' || type == 'user_choice') ? NewsItem(model: model, index: index, newslist: newsList, fromShowMore: false) : VideoItem(model: model);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: setCustomAppBar(height: 45, isBackBtn: true, label: widget.title, context: context, horizontalPad: 15, isConvertText: false),
      body: BlocBuilder<SectionByIdCubit, SectionByIdState>(
        builder: (context, state) {
          if (state is SectionByIdFetchSuccess) {
            return Padding(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<SectionByIdCubit>().getSectionById(
                      sectionId: widget.sectionId,
                      langId: context.read<AppLocalizationCubit>().state.id,
                      latitude: SettingsLocalDataRepository().getLocationCityValues().first,
                      longitude: SettingsLocalDataRepository().getLocationCityValues().last);
                },
                child: ListView.builder(
                    controller: controller,
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: state.newsModel.length,
                    itemBuilder: (context, index) {
                      return _buildSectionNewsContainer(
                          model: (state).newsModel[index], type: (state).type, index: index, newsList: ((state).type == 'news' || state.type == 'user_choice') ? state.newsModel : []);
                    }),
              ),
            );
          }
          if (state is SectionByIdFetchFailure) {
            return ErrorContainerWidget(
                errorMsg: (state.errorMessage.contains(ErrorMessageKeys.noInternet)) ? UiUtils.getTranslatedLabel(context, 'internetmsg') : state.errorMessage, onRetry: getSectionByData);
          }
          //state is SectionByIdFetchInProgress || state is SectionByIdInitial
          return shimmerNewsList(context);
        },
      ),
    );
  }
}
