// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/repositories/Settings/settingsLocalDataRepository.dart';
import 'package:news/ui/widgets/breakingVideoItem.dart';
import 'package:news/ui/widgets/errorContainerWidget.dart';
import 'package:news/ui/widgets/shimmerNewsList.dart';
import 'package:news/utils/ErrorMessageKeys.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/sectionByIdCubit.dart';
import 'package:news/data/models/BreakingNewsModel.dart';
import 'package:news/ui/widgets/breakingNewsItem.dart';
import 'package:news/ui/widgets/customAppBar.dart';

class SectionMoreBreakingNewsList extends StatefulWidget {
  final String sectionId;
  final String title;

  const SectionMoreBreakingNewsList({super.key, required this.sectionId, required this.title});

  @override
  State<StatefulWidget> createState() {
    return _SectionBreakingNewsState();
  }

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(builder: (_) => SectionMoreBreakingNewsList(sectionId: arguments['sectionId'], title: arguments['title']));
  }
}

class _SectionBreakingNewsState extends State<SectionMoreBreakingNewsList> {
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

  _buildSectionBreakingNewsContainer({required BreakingNewsModel model, required String type, required int index, required List<BreakingNewsModel> newsList}) {
    return type == 'breaking_news' ? BreakNewsItem(model: model, index: index, breakNewsList: newsList) : BreakVideoItem(model: model);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: setCustomAppBar(height: 45, isBackBtn: true, label: widget.title, context: context, horizontalPad: 15, isConvertText: false),
      body: BlocBuilder<SectionByIdCubit, SectionByIdState>(
        builder: (context, state) {
          if (state is SectionByIdFetchSuccess) {
            return Padding(
              padding: const EdgeInsetsDirectional.all(10.0),
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
                    itemCount: state.breakNewsModel.length,
                    itemBuilder: (context, index) {
                      return _buildSectionBreakingNewsContainer(
                          model: (state).breakNewsModel[index], type: (state).type, index: index, newsList: (state).type == 'breaking_news' ? state.breakNewsModel : []);
                    }),
              ),
            );
          }
          if (state is SectionByIdFetchFailure) {
            return ErrorContainerWidget(
                errorMsg: (state.errorMessage.contains(ErrorMessageKeys.noInternet)) ? UiUtils.getTranslatedLabel(context, 'internetmsg') : state.errorMessage, onRetry: getSectionByData);
          }
          //state is SectionByIdFetchInProgress || state is SectionByIdInitial
          return shimmerNewsList(context, isNews: false);
        },
      ),
    );
  }
}
