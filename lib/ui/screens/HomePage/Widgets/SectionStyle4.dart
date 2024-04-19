// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:news/ui/screens/HomePage/Widgets/CommonSectionTitle.dart';
import 'package:news/app/routes.dart';
import 'package:news/data/models/BreakingNewsModel.dart';
import 'package:news/data/models/FeatureSectionModel.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/networkImage.dart';

class Style4Section extends StatelessWidget {
  final FeatureSectionModel model;

  const Style4Section({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return style4Data(model, context);
  }

  Widget style4Data(FeatureSectionModel model, BuildContext context) {
    if (model.breakVideos!.isNotEmpty || model.breakNews!.isNotEmpty || model.videos!.isNotEmpty || model.news!.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          commonSectionTitle(model, context),
          if (model.newsType == 'news' || model.videosType == "news" || model.newsType == "user_choice")
            if ((model.newsType == 'news' || model.newsType == "user_choice") ? model.news!.isNotEmpty : model.videos!.isNotEmpty)
              setGridLayout(
                  context: context,
                  totalCount: (model.newsType == 'news' || model.newsType == "user_choice") ? model.news!.length : model.videos!.length,
                  childWidget: (context, index) {
                    NewsModel data = (model.newsType == 'news' || model.newsType == "user_choice") ? model.news![index] : model.videos![index];
                    return InkWell(
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: UiUtils.getColorScheme(context).background),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(children: [
                              setNewsImage(context: context, imageURL: data.image!),
                              if (data.categoryName != null && data.categoryName != "")
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                      margin: const EdgeInsetsDirectional.only(start: 7.0, top: 7.0),
                                      height: 18.0,
                                      padding: const EdgeInsetsDirectional.only(start: 6.0, end: 6.0, top: 2.5),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Theme.of(context).primaryColor),
                                      child: CustomTextLabel(
                                          text: data.categoryName!,
                                          textAlign: TextAlign.center,
                                          textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondaryColor),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true)),
                                ),
                              if (model.newsType == 'videos')
                                Positioned.directional(
                                  textDirection: Directionality.of(context),
                                  top: MediaQuery.of(context).size.height * 0.065,
                                  start: MediaQuery.of(context).size.width / 6,
                                  end: MediaQuery.of(context).size.width / 6,
                                  child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(Routes.newsVideo, arguments: {"from": 1, "model": data});
                                      },
                                      child: UiUtils.setPlayButton(context: context)),
                                ),
                            ]),
                            Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: CustomTextLabel(
                                    text: data.title!,
                                    textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer),
                                    softWrap: true,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                      onTap: () {
                        if (model.newsType == 'news' || model.newsType == "user_choice") {
                          List<NewsModel> newsList = [];
                          newsList.addAll(model.news!);
                          newsList.removeAt(index);
                          Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"model": data, "newsList": newsList, "isFromBreak": false, "fromShowMore": false});
                        }
                      },
                    );
                  }),
          if (model.newsType == 'breaking_news' || model.videosType == "breaking_news")
            if (model.newsType == 'breaking_news' ? model.breakNews!.isNotEmpty : model.breakVideos!.isNotEmpty)
              setGridLayout(
                  context: context,
                  totalCount: model.newsType == 'breaking_news' ? model.breakNews!.length : model.breakVideos!.length,
                  childWidget: (context, index) {
                    BreakingNewsModel data = model.newsType == 'breaking_news' ? model.breakNews![index] : model.breakVideos![index];
                    return InkWell(
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: UiUtils.getColorScheme(context).background),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(children: [
                              setNewsImage(context: context, imageURL: data.image!),
                              if (model.newsType == 'videos')
                                Positioned.directional(
                                  textDirection: Directionality.of(context),
                                  top: MediaQuery.of(context).size.height * 0.065,
                                  start: MediaQuery.of(context).size.width / 6,
                                  end: MediaQuery.of(context).size.width / 6,
                                  child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(Routes.newsVideo, arguments: {"from": 3, "breakModel": data});
                                      },
                                      child: UiUtils.setPlayButton(context: context)),
                                ),
                            ]),
                            Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: CustomTextLabel(
                                    text: data.title!,
                                    textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer),
                                    softWrap: true,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                      onTap: () {
                        if (model.newsType == 'breaking_news') {
                          List<BreakingNewsModel> breakList = [];
                          breakList.addAll(model.breakNews!);
                          breakList.removeAt(index);
                          Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"breakModel": data, "breakNewsList": breakList, "isFromBreak": true, "fromShowMore": false});
                        }
                      },
                    );
                  })
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget setGridLayout({required BuildContext context, required int totalCount, required Widget? Function(BuildContext, int) childWidget}) {
    return GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(mainAxisExtent: MediaQuery.of(context).size.height * 0.27, crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 13),
        shrinkWrap: true,
        itemCount: totalCount,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: childWidget);
  }

  Widget setNewsImage({required BuildContext context, required String imageURL}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CustomNetworkImage(
          networkImageUrl: imageURL,
          height: MediaQuery.of(context).size.height * 0.175,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
          isVideo: model.newsType == 'videos' ? true : false),
    );
  }
}
