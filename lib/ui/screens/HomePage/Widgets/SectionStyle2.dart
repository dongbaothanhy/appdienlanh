// ignore_for_file: file_names, must_be_immutable

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:news/ui/screens/HomePage/Widgets/CommonSectionTitle.dart';
import 'package:news/app/routes.dart';
import 'package:news/data/models/BreakingNewsModel.dart';
import 'package:news/data/models/FeatureSectionModel.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/networkImage.dart';
import 'package:news/utils/uiUtils.dart';

class Style2Section extends StatelessWidget {
  final FeatureSectionModel model;
  bool isNews = true;

  Style2Section({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return style2Data(model, context);
  }

  Widget style2Data(FeatureSectionModel model, BuildContext context) {
    if (model.breakVideos!.isNotEmpty || model.breakNews!.isNotEmpty || model.videos!.isNotEmpty || model.news!.isNotEmpty) {
      if (model.newsType == 'news' || model.videosType == "news" || model.newsType == "user_choice") {
        if ((model.newsType == 'news' || model.newsType == "user_choice") ? model.news!.isNotEmpty : model.videos!.isNotEmpty) {
          isNews = true;
        }
      }

      if (model.newsType == 'breaking_news' || model.videosType == "breaking_news") {
        if (model.newsType == 'breaking_news' ? model.breakNews!.isNotEmpty : model.breakVideos!.isNotEmpty) {
          isNews = false;
        }
      }
      var totalCount = (isNews)
          ? ((model.newsType == 'news' || model.newsType == "user_choice") ? model.news!.length : model.videos!.length)
          : (model.newsType == 'breaking_news' ? model.breakNews!.length : model.breakVideos!.length);
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          commonSectionTitle(model, context),
          ListView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: totalCount,
              itemBuilder: (context, index) => (isNews)
                  ? setStyle2(context: context, index: index, model: model, newsModel: (model.newsType == 'news' || model.newsType == "user_choice") ? model.news![index] : model.videos![index])
                  : setStyle2(context: context, index: index, model: model, breakingNewsModel: (model.newsType == 'breaking_news') ? model.breakNews![index] : model.breakVideos![index])),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget setStyle2({required BuildContext context, required int index, required FeatureSectionModel model, NewsModel? newsModel, BreakingNewsModel? breakingNewsModel}) {
    return Padding(
      padding: EdgeInsets.only(top: index == 0 ? 0 : 15),
      child: InkWell(
        onTap: () {
          if (model.newsType == 'news' || model.newsType == "user_choice") {
            List<NewsModel> newsList = [];
            newsList.addAll(model.news!);
            newsList.removeAt(index);
            Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"model": newsModel, "newsList": newsList, "isFromBreak": false, "fromShowMore": false});
          } else if (model.newsType == 'breaking_news') {
            List<BreakingNewsModel> breakList = [];
            breakList.addAll(model.breakNews!);
            breakList.removeAt(index);
            Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"breakModel": breakingNewsModel, "breakNewsList": breakList, "isFromBreak": true, "fromShowMore": false});
          }
        },
        child: Stack(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: ShaderMask(
                  shaderCallback: (rect) => LinearGradient(begin: Alignment.center, end: Alignment.bottomCenter, colors: [Colors.transparent, darkSecondaryColor.withOpacity(0.9)]).createShader(rect),
                  blendMode: BlendMode.darken,
                  child: CustomNetworkImage(
                      networkImageUrl: (newsModel != null) ? newsModel.image! : breakingNewsModel!.image!,
                      fit: BoxFit.cover,
                      width: double.maxFinite,
                      height: MediaQuery.of(context).size.height / 3.3,
                      isVideo: model.newsType == 'videos' ? true : false),
                )),
            if (model.newsType == 'videos')
              Positioned.directional(
                  textDirection: Directionality.of(context),
                  top: MediaQuery.of(context).size.height * 0.12,
                  start: MediaQuery.of(context).size.width / 3,
                  end: MediaQuery.of(context).size.width / 3,
                  child: InkWell(
                      onTap: () => Navigator.of(context).pushNamed(Routes.newsVideo, arguments: {"from": 1, "model": (newsModel != null) ? newsModel : breakingNewsModel!}),
                      child: UiUtils.setPlayButton(context: context))),
            Positioned.directional(
                textDirection: Directionality.of(context),
                bottom: 10,
                start: 10,
                end: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (newsModel != null && newsModel.categoryName != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: CustomTextLabel(
                                  text: newsModel.categoryName!,
                                  textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: secondaryColor.withOpacity(0.6)),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true)),
                        ),
                      ),
                    Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: CustomTextLabel(
                            text: (newsModel != null) ? newsModel.title! : breakingNewsModel!.title!,
                            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: secondaryColor, fontWeight: FontWeight.normal),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true)),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
