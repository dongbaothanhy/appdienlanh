// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:news/data/models/FeatureSectionModel.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/app/routes.dart';
import 'package:news/utils/uiUtils.dart';

Widget commonSectionTitle(FeatureSectionModel model, BuildContext context) {
  return ListTile(
    minVerticalPadding: 5,
    contentPadding: EdgeInsets.zero,
    title: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
            child: CustomTextLabel(
                text: model.title!,
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.bold),
                softWrap: true,
                maxLines: 1,
                overflow: TextOverflow.ellipsis)),
        GestureDetector(
          onTap: () {
            //Interstitial Ad here
            UiUtils.showInterstitialAds(context: context);
            if ((model.newsType == 'news' || model.newsType == "user_choice") || model.videosType == 'news' && model.newsType != 'breaking_news') {
              Navigator.of(context).pushNamed(Routes.sectionNews, arguments: {"sectionId": model.id!, "title": model.title!});
            } else {
              Navigator.of(context).pushNamed(Routes.sectionBreakNews, arguments: {"sectionId": model.id!, "title": model.title!});
            }
          },
          child: CustomTextLabel(
              text: 'viewMore',
              textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(decoration: TextDecoration.underline, fontWeight: FontWeight.bold, color: UiUtils.getColorScheme(context).outline)),
        )
      ],
    ),
    subtitle: CustomTextLabel(
        text: model.shortDescription!,
        textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6)),
        softWrap: true,
        maxLines: 3,
        overflow: TextOverflow.ellipsis),
  );
}
